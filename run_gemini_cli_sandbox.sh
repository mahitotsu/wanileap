#!/bin/bash

# 事前にビルドしたwanileap-sandboxイメージでgemini-cliをサンドボックスモードで起動します。
set -e

# AWS SSO 認証情報を取得し、.envファイルに書き出します。
# 注意: このスクリプトを実行する前に、ホストマシンで 'aws sso login' を実行し、
#       SSOセッションがアクティブであることを確認してください。
echo "Retrieving AWS SSO credentials..."
AWS_CREDENTIALS=$(aws configure export-credentials --format env)

if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve AWS SSO credentials. Please ensure 'aws sso login' has been executed,"
  echo "and that AWS CLI is correctly configured."
  exit 1
fi

# .envファイルに書き出し
cat <<EOF > .env
$AWS_CREDENTIALS
EOF

# .envファイルの内容を一時的に環境変数にも反映（スクリプト内で利用する場合）
eval "$AWS_CREDENTIALS"

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
  echo "Error: Incomplete AWS credentials retrieved. Please verify your SSO session is active."
  exit 1
fi

echo "AWS credentials have been written to .env file."

gemini -s --sandbox-image wanileap-sandbox -d
