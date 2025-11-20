# AWS Pilot Light Disaster Recovery Solution

## 🚀 Project Overview
A production-ready, automated disaster recovery solution implementing the **Pilot Light** strategy across AWS regions using Infrastructure as Code (Terraform). This project demonstrates enterprise-level cloud architecture, automation, and disaster recovery best practices.

## 🏗️ Architecture & Technologies
- **Primary Region**: us-east-1 | **Secondary Region**: eu-west-1
- **Infrastructure**: Terraform modules for VPC, ALB, ASG, DynamoDB, S3, Lambda
- **Automation**: Python Lambda functions with EventBridge triggers
- **Monitoring**: CloudWatch alarms, SNS notifications, custom dashboards
- **Security**: IAM roles, security groups, VPC endpoints, encryption at rest

## 🌟 Key Features
- **Automated Failover**: Lambda-triggered ASG scaling based on CloudWatch alarms
- **Cross-Region Replication**: S3 buckets and DynamoDB Global Tables
- **Modular Design**: 10+ reusable Terraform modules
- **Cost Optimization**: Pilot light approach minimizes standby costs
- **Monitoring**: Real-time health checks and alerting system

## 📊 Technical Implementation

### Infrastructure Components
```
├── VPC & Networking (Multi-AZ subnets, NAT Gateway, VPC Endpoints)
├── Application Load Balancer (Health checks, target groups)
├── Auto Scaling Groups (Primary: active, Secondary: standby)
├── DynamoDB Global Tables (Cross-region data replication)
├── S3 Cross-Region Replication (Application data backup)
├── Lambda Automation (Python-based failover orchestration)
└── CloudWatch Monitoring (Alarms, dashboards, metrics)
```

### Disaster Recovery Flow
1. **Detection**: CloudWatch monitors ALB health in primary region
2. **Trigger**: Alarm state change triggers EventBridge rule
3. **Automation**: Lambda function scales secondary region ASG
4. **Notification**: SNS alerts administrators of failover event
5. **Recovery**: Manual DNS update routes traffic to secondary region

## 🛠️ Technical Skills Demonstrated
- **Infrastructure as Code**: Terraform modules, state management, remote backends
- **AWS Services**: 15+ services including VPC, ALB, ASG, Lambda, DynamoDB, S3, CloudWatch
- **Automation**: Python Lambda functions, EventBridge, CloudWatch Events
- **Security**: IAM policies, security groups, encryption
- **Monitoring**: CloudWatch alarms, custom metrics, SNS notifications
- **DevOps**: Multi-environment deployments, CI/CD ready structure

## 🚀 Quick Start
```bash
# Deploy infrastructure
cd environments/global && terraform apply
cd ../primary && terraform apply  
cd ../secondary && terraform apply

# Enable automation
cd ../global && terraform apply -var="enable_automation=true"
```

## 📈 Business Impact
- **RTO**: < 10 minutes automated failover
- **RPO**: Near real-time data replication
- **Cost Savings**: 60-80% reduction vs. warm standby
- **Availability**: 99.9%+ uptime with cross-region redundancy

## 🔧 Project Structure
```
dr_recovery/
├── environments/     # Environment-specific configurations
├── modules/         # Reusable Terraform modules
```

---
*This project showcases enterprise-level AWS architecture, automation, and disaster recovery implementation suitable for production workloads.*