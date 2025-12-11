#!/bin/bash

# SSM Parameter Store からAWSクレデンシャルを取得して ~/.aws/credentials を作成
# パラメータが存在しない場合はスキップ（IAMロールのみで動作）

AWS_REGION=${AWS_REGION:-us-east-1}

# SSMからクレデンシャルを取得
ACCESS_KEY=$(aws ssm get-parameter --name "/genai/agentcore/aws-access-key-id" --with-decryption --query "Parameter.Value" --output text --region "$AWS_REGION" 2>/dev/null)
SECRET_KEY=$(aws ssm get-parameter --name "/genai/agentcore/aws-secret-access-key" --with-decryption --query "Parameter.Value" --output text --region "$AWS_REGION" 2>/dev/null)

if [ -n "$ACCESS_KEY" ] && [ -n "$SECRET_KEY" ] && [ "$ACCESS_KEY" != "None" ] && [ "$SECRET_KEY" != "None" ]; then
  echo "Setting up AWS credentials from SSM Parameter Store..."
  mkdir -p ~/.aws
  cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = $ACCESS_KEY
aws_secret_access_key = $SECRET_KEY
EOF
  echo "AWS credentials configured successfully."
else
  echo "SSM parameters not found or empty. Using IAM role credentials only."
fi

# 元のコマンドを実行
exec "$@"
