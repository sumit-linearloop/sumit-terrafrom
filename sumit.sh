#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt update -y

# Install AWS CLI via snap
echo "Installing AWS CLI..."
if ! command -v snap &>/dev/null; then
    echo "Snap is not installed. Installing snapd..."
    sudo apt install -y snapd
fi
sudo snap install aws-cli --classic

# Check AWS CLI installation
if ! command -v aws &>/dev/null; then
    echo "AWS CLI installation failed!"
    exit 1
fi
echo "AWS CLI installed successfully!"

# Configure AWS CLI credentials from environment variables
echo "Configuring AWS CLI..."
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
AWS_REGION="ap-south-1"

if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" ]]; then
    echo "AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY is not set. Please provide them as environment variables."
    exit 1
fi

# Optional: Write credentials to AWS configuration files
mkdir -p ~/.aws
cat > ~/.aws/credentials <<EOL
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOL

cat > ~/.aws/config <<EOL
[default]
region = ${AWS_REGION}
output = json
EOL

echo "AWS CLI configured successfully!"

# Retrieve secret from AWS Secrets Manager
SECRET_ID="sumit-ci-cd"
OUTPUT_FILE=".env"

echo "Retrieving secret from AWS Secrets Manager..."
aws secretsmanager get-secret-value --secret-id "${SECRET_ID}" --query 'SecretString' --output text > "${OUTPUT_FILE}"
if [[ $? -ne 0 ]]; then
    echo "Failed to retrieve secret!"
    exit 1
fi

echo "Secret retrieved and saved to ${OUTPUT_FILE}"