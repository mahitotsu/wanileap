#!/bin/bash

# 依存コマンドの存在チェック
for cmd in aws gemini docker; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: $cmd command not found. Please install $cmd." >&2
    exit 1
  fi
done

# エラー発生時は即時終了
set -e

# --- AWS SSO認証情報の取得と検証 ---
# AWS SSO 認証情報を取得し、.envファイルに書き出します。
# 注意: このスクリプトを実行する前に、ホストマシンで 'aws sso login' を実行し、
#       SSOセッションがアクティブであることを確認してください。
echo "Retrieving AWS SSO credentials..."
AWS_CREDENTIALS=$(aws configure export-credentials --format env)

# 認証情報取得に失敗した場合はエラー終了
if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve AWS SSO credentials. Please ensure 'aws sso login' has been executed,"
  echo "and that AWS CLI is correctly configured."
  exit 1
fi

# 取得した認証情報を.envファイルに保存
cat <<EOF > .env
$AWS_CREDENTIALS
EOF

# .envファイルの内容を一時的に環境変数にも反映（スクリプト内で利用する場合）
eval "$AWS_CREDENTIALS"

# 必須なAWS認証情報が全て揃っているかをチェック
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
  echo "Error: Incomplete AWS credentials retrieved. Please verify your SSO session is active."
  exit 1
fi

echo "AWS credentials have been written to .env file."

# --- gemini-cliのサンドボックス起動 ---
# 事前にビルドしたwanileap-sandboxイメージでgemini-cliをサンドボックスモードで起動します。
gemini -s --sandbox-image wanileap-sandbox
