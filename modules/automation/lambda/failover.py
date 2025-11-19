import os
import json
import boto3
import time


elbv2 = boto3.client('elbv2')
autoscaling_primary = boto3.client('autoscaling', region_name=os.environ['PRIMARY_REGION'])
autoscaling_secondary = boto3.client('autoscaling', region_name=os.environ['SECONDARY_REGION'])
sns = boto3.client('sns')
# Initialize EC2 client for the PRIMARY region to manage the EIP
ec2_primary = boto3.client('ec2', region_name=os.environ['PRIMARY_REGION'])
# Initialize EC2 client for the SECONDARY region to find the new instance
ec2_secondary = boto3.client('ec2', region_name=os.environ['SECONDARY_REGION'])


def lambda_handler(event, context):
    """Handles the CloudWatch alarm trigger for failover/failback using EIP."""

    alarm_state = event['detail']['state']['value']
    target_group_arn = os.environ['TARGET_GROUP_ARN']

    # Extract Target Health details for the notification
    target_health = get_target_health_details(target_group_arn)

    if alarm_state == 'ALARM':
        # --- FAILOVER ACTION ---
        print("ALARM state detected. Initiating EIP FAILOVER to secondary region.")

        # 1. Scale up Secondary ASG (Desired Capacity of 2, for example)
        desired_capacity = int(os.environ['DESIRED_CAPACITY'])
        scale_asg(os.environ['SECONDARY_ASG_NAME'], 2)

        # 2. Find a running instance in the Secondary ASG
        secondary_instance_id, found_instance = poll_for_instance(
            autoscaling_secondary,
            os.environ['SECONDARY_ASG_NAME'],
        desired_capacity,
            os.environ['SECONDARY_REGION']
        )

        if not found_instance:
            msg = "CRITICAL: Secondary instance not found after scale-up/polling. EIP FAILOVER failed."
            publish_sns_notification(msg, "CRITICAL: EIP Failover Failed")
            return {"status": msg}

        # 3. Move EIP to the Secondary Instance (This is the traffic switch)
        eip_status = associate_eip(secondary_instance_id, os.environ['EIP_ALLOCATION_ID'], os.environ['SECONDARY_REGION'])

        # 4. Publish Notification
        message = build_failover_message(target_health, 'FAILOVER', eip_status)
        publish_sns_notification(message, "CRITICAL: DR Failover Initiated (EIP Move)")

        return {"status": "Failover complete"}

    elif alarm_state == 'OK':
        # --- FAILBACK ACTION ---
        print("OK state detected. Initiating EIP FAILBACK / Primary recovery cleanup.")

        # The Primary instance should already be scaled up and healthy (per your test script)
        desired_capacity = int(os.environ['DESIRED_CAPACITY'])
        # 1. Find the running Primary instance
        primary_instance_id, found_instance = poll_for_primary_instance(
            autoscaling_primary,
            os.environ['PRIMARY_ASG_NAME'],
            desired_capacity,
            os.environ['PRIMARY_REGION']
        )

        if not primary_instance_id:
            msg = "CRITICAL: Primary instance not found for failback. EIP FAILBACK failed."
            publish_sns_notification(msg, "CRITICAL: EIP Failback Failed")
            return {"status": msg}

        # 2. Move EIP back to the Primary Instance (This is the traffic switch)
        primary_eip_id = os.environ['PRIMARY_EIP_ALLOCATION_ID']
        eip_status = associate_eip(primary_instance_id, primary_eip_id ,os.environ['PRIMARY_REGION'])

        # 3. Scale down Secondary ASG
        scale_asg(os.environ['SECONDARY_ASG_NAME'], 0)

        # 4. Publish Notification
        message = build_failover_message(target_health, 'FAILBACK', eip_status)
        publish_sns_notification(message, "INFO: DR Failback Completed (EIP Move)")

        return {"status": "Failback complete"}

    return {"status": f"State {alarm_state} received, no action taken."}

# Define the polling function (put this near the top of the script)
def poll_for_instance(asg_client, asg_name, desired_capacity, region_name):
    # This loop polls the ASG every 10 seconds for up to 30 attempts (5 minutes total)
    max_attempts = 30
    print(f"Polling secondary ASG ({asg_name}) for {desired_capacity} desired capacity...")

    for attempt in range(max_attempts):
        response = asg_client.describe_auto_scaling_groups(
            AutoScalingGroupNames=[asg_name]
        )

        if not response['AutoScalingGroups']:
            print(f"ASG {asg_name} not found.")
            return None, False

        group = response['AutoScalingGroups'][0]

        # Find instances that are Running AND InService
        running_instances = [
            i for i in group['Instances']
            if i['LifecycleState'] == 'InService' and i['HealthStatus'] == 'Healthy'
        ]

        if len(running_instances) >= desired_capacity:
            # Return the first running instance ID as the target
            target_instance_id = running_instances[0]['InstanceId']
            try:
                # 1. Get the Waiter object from the client
                waiter = ec2_secondary.get_waiter('instance_running')

                # 2. Use the waiter's wait() method
                print(f"Waiting for EC2 instance {target_instance_id} to be fully Running...")
                waiter.wait(
                    InstanceIds=[target_instance_id],
                    WaiterConfig={
                        'Delay': 15,     # Check every 15 seconds
                        'MaxAttempts': 10 # Total max wait time: 15 * 10 = 150 seconds (2.5 mins)
                    }
                )
                print(f"Target instance found: {target_instance_id}")
                return target_instance_id, True

            except Exception as ec2_e:
                # If the EC2 waiter fails, the instance is not fully ready. Wait and continue polling.
                print(f"EC2 Waiter failed for {target_instance_id}: {ec2_e}. Continuing ASG poll.")
                time.sleep(10)
                continue

        print(f"Attempt {attempt + 1}/{max_attempts}: Waiting for instance to become InService. Current count: {len(running_instances)}")
        time.sleep(10) # Wait 10 seconds before polling again

    print(f"Timeout: Instance did not reach InService state within allowed time.")
    return None, False

def poll_for_primary_instance(asg_client, asg_name, desired_capacity, region_name):
    # This loop polls the ASG every 10 seconds for up to 30 attempts (5 minutes total)
    max_attempts = 30
    print(f"Polling secondary ASG ({asg_name}) for {desired_capacity} desired capacity...")

    for attempt in range(max_attempts):
        response = asg_client.describe_auto_scaling_groups(
            AutoScalingGroupNames=[asg_name]
        )

        if not response['AutoScalingGroups']:
            print(f"ASG {asg_name} not found.")
            return None, False

        group = response['AutoScalingGroups'][0]

        # Find instances that are Running AND InService
        running_instances = [
            i for i in group['Instances']
            if i['LifecycleState'] == 'InService' and i['HealthStatus'] == 'Healthy'
        ]

        if len(running_instances) >= desired_capacity:
            # Return the first running instance ID as the target
            target_instance_id = running_instances[0]['InstanceId']
            try:
                # 1. Get the Waiter object from the client
                waiter = ec2_primary.get_waiter('instance_running')

                # 2. Use the waiter's wait() method
                print(f"Waiting for EC2 instance {target_instance_id} to be fully Running...")
                waiter.wait(
                    InstanceIds=[target_instance_id],
                    WaiterConfig={
                        'Delay': 15,     # Check every 15 seconds
                        'MaxAttempts': 10 # Total max wait time: 15 * 10 = 150 seconds (2.5 mins)
                    }
                )
                print(f"Target instance found: {target_instance_id}")
                return target_instance_id, True

            except Exception as ec2_e:
                # If the EC2 waiter fails, the instance is not fully ready. Wait and continue polling.
                print(f"EC2 Waiter failed for {target_instance_id}: {ec2_e}. Continuing ASG poll.")
                time.sleep(10)
                continue

        print(f"Attempt {attempt + 1}/{max_attempts}: Waiting for instance to become InService. Current count: {len(running_instances)}")
        time.sleep(10) # Wait 10 seconds before polling again

    print(f"Timeout: Primary instance did not reach InService state within allowed time.")
    return None, False

# --- Helper Functions ---

def find_primary_instance():
    """Finds a running instance ID in the primary ASG (using a tag or ASG name)."""
    # Requires custom logic based on how you tag/identify the current primary instance.
    # For simplicity here, we assume the primary ASG name is available in the environment.
    try:
        response = autoscaling.describe_auto_scaling_groups(AutoScalingGroupNames=[os.environ['PRIMARY_ASG_NAME']])
        if not response['AutoScalingGroups']:
            return None

        # Find the first Healthy instance
        for instance in response['AutoScalingGroups'][0]['Instances']:
            if instance['HealthStatus'] == 'Healthy':
                return instance['InstanceId']
        return None
    except Exception as e:
        print(f"Error finding primary instance: {e}")
        return None

def associate_eip(instance_id, allocation_id, target_region):
    """Associates the Elastic IP with the given instance ID."""
    print(f"Associating EIP {allocation_id} with instance {instance_id} in region {target_region}...")
    if target_region == os.environ['PRIMARY_REGION']:
        client = ec2_primary
    else:
        client = ec2_secondary
    try:
        client.associate_address(
            InstanceId=instance_id,
            AllocationId=allocation_id,
            AllowReassociation=True # Allows stealing the EIP from the old instance
        )
        return f"EIP {allocation_id} successfully associated with {instance_id}"
    except Exception as e:
        print(f"EIP association FAILED: {e}")
        return f"EIP association FAILED: {e}"

# The following functions (get_target_health_details, scale_asg,
# build_failover_message, publish_sns_notification) are the same as before.
# Note: scale_asg now uses the secondary region client initialized at the top.

# ... (Insert the four helper functions from the previous response here) ...

def get_target_health_details(target_group_arn):
    # ... (same implementation as before, uses elbv2 client)
    pass # Placeholder for brevity

def scale_asg(asg_name, desired_capacity):
    # ... (same implementation as before, uses autoscaling client)
    pass # Placeholder for brevity

def build_failover_message(health_details, action_type, eip_status):
    # ... (enhanced to include eip_status)
    message = f"--- DR {action_type} Notification ---\n"
    message += f"Source: CloudWatch Alarm {os.environ['CLOUDWATCH_ALARM_NAME']}\n"
    message += f"EIP Status: {eip_status}\n"

    if action_type == 'FAILOVER':
        message += "\nFAILOVER TRIGGERED: Primary targets are UNHEALTHY.\n"
        message += "Action: Secondary ASG scaled up, EIP moved to Secondary Instance.\n"

        if health_details:
            message += "\nUnhealthy Target Details:\n"
            for item in health_details:
                message += f"  - ID: {item['id']} | State: {item['state']}\n"
                message += f"    Reason: {item['reason']} | Description: {item['description']}\n"
        else:
            message += "No specific target health details retrieved.\n"

    elif action_type == 'FAILBACK':
        message += "\nFAILBACK TRIGGERED: Primary targets have recovered to OK state.\n"
        message += "Action: EIP moved back to Primary Instance, Secondary ASG scaled down.\n"

    return message

def publish_sns_notification(message, subject):
    # ... (same implementation as before, uses sns client)
    pass # Placeholder for brevity