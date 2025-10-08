#!/bin/bash

# Simple setup for pilot light DR demo
yum update -y
yum install -y python3 aws-cli

# Environment setup
cat > /etc/profile.d/app-env.sh << 'EOF'
export ENVIRONMENT=${environment}
export PROJECT_NAME=${project_name}
export AWS_REGION=${region}
export S3_BUCKET=${s3_bucket}
EOF

# Simple health check page
mkdir -p /var/www/html
cat > /var/www/html/health << 'EOF'
{"status":"healthy","environment":"${environment}","region":"${region}"}
EOF

# Start web server for health checks
cd /var/www/html
nohup python3 -m http.server 80 > /var/log/webserver.log 2>&1 &

echo "Instance ready" > /var/log/user-data-complete.log