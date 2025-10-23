#!/bin/bash

# Script to create EC2 instance for testing get-imds.sh
# Make sure AWS CLI is configured with: aws configure

set -euo pipefail

echo "Creating EC2 instance for IMDS testing..."

# Create EC2 instance with IMDS v2 required
# HttpTokens=required means only v2 is allowed (v1 is blocked)
# This tests the IMDS v2 functionality in get-imds.sh
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0341d95f75f311023 \
    --instance-type t3.micro \
    --region us-east-1 \
    --metadata-options HttpTokens=required,HttpPutResponseHopLimit=2,HttpEndpoint=enabled \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=get-imds-test}]' \
    --associate-public-ip-address \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Instance created: $INSTANCE_ID"

# Wait for instance to be running
echo "Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region us-east-1

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --region us-east-1 \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "Instance is running!"
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"
echo ""
echo "To connect:"
echo "1. Go to The AWS console"
echo "2. Navigate to the EC2 console"
echo "3. Select EC2 Instances connect"
echo "4. Click on Connect"
echo ""
echo "To test the script:"
echo "1. Run: sudo yum install -y git jq"
echo "2. Run: git clone https://github.com/noppadol26dw/get-imds.git"
echo "3. Run: cd get-imds"
echo "4. Run: ./get-imds.sh | jq"
echo "5. Run: ./get-imds.sh instance-id | jq"
echo ""
echo "Note: This instance requires IMDS v2 (tokens required)"
echo "IMDS v1 is blocked - only v2 will work"
echo ""
echo "To terminate the instance when done:"
echo "aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region us-east-1"