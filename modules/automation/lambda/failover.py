"""
Lambda Function: DR Failover Orchestration
Triggers: CloudWatch Alarm (Primary region unhealthy: ALARM) or (Primary region recovered: OK)
Purpose: Automatically scale secondary region up during disaster (Failover) or down (Failback).
"""

import json
import boto3
import os
import logging
import time
from datetime import datetime

# --- Environment Configuration ---
SECONDARY_REGION = os.environ['SECONDARY_REGION']
SECONDARY_ASG_NAME = os.environ['SECONDARY_ASG_NAME']
FAILOVER_CAPACITY = int(os.environ.get('DESIRED_CAPACITY', '2'))
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']
FAILBACK_CAPACITY = 0

# New optional environment variable for stabilization time (in seconds)
STABILIZATION_WAIT = int(os.environ.get('STABILIZATION_WAIT', '600'))  # default: 10 minutes

# AWS Clients
asg_client = boto3.client('autoscaling', region_name=SECONDARY_REGION)
sns_client = boto3.client('sns')
cloudwatch = boto3.client('cloudwatch', region_name=SECONDARY_REGION)


def lambda_handler(event, context):
    """
    Main orchestration entry point
    """
    print(f"Orchestration triggered at {datetime.utcnow().isoformat()}")
    print(f"Event: {json.dumps(event)}")

    alarm_state = event['detail']['state']['value']

    if alarm_state == 'ALARM':
        action_type = "FAILOVER"
        target_capacity = FAILOVER_CAPACITY
    elif alarm_state == 'OK':
        action_type = "FAILBACK"
        target_capacity = FAILBACK_CAPACITY
    else:
        print(f"Ignoring state: {alarm_state}")
        return {'statusCode': 200, 'body': json.dumps({'message': 'Ignored'})}

    print(f"=== {action_type} INITIATED ===")

    try:
        # --- Step 1: Check ASG state ---
        current_status = check_asg_status()

        # --- Step 2: Scale if needed ---
        if current_status['DesiredCapacity'] != target_capacity:
            scale_result = update_secondary_capacity(target_capacity)
        else:
            scale_result = {
                'status': 'already_at_target',
                'desired_capacity': current_status['DesiredCapacity']
            }
            print(f"Secondary ASG already at {target_capacity} capacity.")

        # --- Step 3: Stabilization delay after failover ---
        if action_type == "FAILOVER":
            print(f"🕐 Waiting {STABILIZATION_WAIT}s (≈{STABILIZATION_WAIT//60} min) for stabilization...")
            time.sleep(STABILIZATION_WAIT)
            print("✅ Stabilization period complete. Secondary region should now be stable.")

        # --- Step 4: Custom metric ---
        log_orchestration_metric(action_type)

        # --- Step 5: Notify ---
        send_notification(action_type, scale_result)

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'{action_type} completed',
                'timestamp': datetime.utcnow().isoformat(),
                'scale_result': scale_result
            })
        }

    except Exception as e:
        msg = f"{action_type} failed: {str(e)}"
        print(msg)
        send_failure_notification(action_type, msg)
        raise


def check_asg_status():
    response = asg_client.describe_auto_scaling_groups(
        AutoScalingGroupNames=[SECONDARY_ASG_NAME]
    )
    if not response['AutoScalingGroups']:
        raise Exception(f"ASG not found: {SECONDARY_ASG_NAME} in {SECONDARY_REGION}")

    asg = response['AutoScalingGroups'][0]
    return {
        'DesiredCapacity': asg['DesiredCapacity'],
        'MinSize': asg['MinSize'],
        'MaxSize': asg['MaxSize'],
        'InstanceCount': len(asg['Instances'])
    }


def update_secondary_capacity(capacity: int):
    action = "Scaling up" if capacity > 0 else "Scaling down"
    print(f"{action} {SECONDARY_ASG_NAME} → {capacity} instances")

    asg_client.set_desired_capacity(
        AutoScalingGroupName=SECONDARY_ASG_NAME,
        DesiredCapacity=capacity,
        HonorCooldown=False
    )

    return {'status': f'{action.lower().replace(" ", "_")}_initiated', 'desired_capacity': capacity}


def log_orchestration_metric(action_type: str):
    metric_name = 'FailoverTriggered' if action_type == 'FAILOVER' else 'FailbackTriggered'

    cloudwatch.put_metric_data(
        Namespace='DR/Orchestration',
        MetricData=[
            {
                'MetricName': metric_name,
                'Value': 1,
                'Unit': 'Count',
                'Timestamp': datetime.utcnow(),
                'Dimensions': [
                    {'Name': 'ActionType', 'Value': action_type},
                    {'Name': 'ASG', 'Value': SECONDARY_ASG_NAME}
                ]
            }
        ]
    )


def send_notification(action_type, scale_result):
    is_failover = action_type == 'FAILOVER'
    subject = f"🚨 {action_type} COMPLETED - SECONDARY REGION ACTIVE" if is_failover else f"✅ {action_type} COMPLETED - PRIMARY REGION RESTORED"

    message = f"""
{('🚨' if is_failover else '✅')} DISASTER RECOVERY {action_type} EXECUTED

Timestamp: {datetime.utcnow().isoformat()}

Action: {action_type}
Region: {SECONDARY_REGION}
ASG: {SECONDARY_ASG_NAME}
Result: {scale_result['status']}
Target Capacity: {scale_result['desired_capacity']}
Stabilization Wait: {STABILIZATION_WAIT if is_failover else 'N/A'} sec
"""

    sns_client.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject=subject,
        Message=message
    )


def send_failure_notification(action_type, error_msg):
    sns_client.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject=f"❌ CRITICAL: DR {action_type} FAILED",
        Message=f"""
❌ DISASTER RECOVERY {action_type} FAILED ❌

Timestamp: {datetime.utcnow().isoformat()}
Error: {error_msg}

Manual intervention required immediately.
"""
    )
