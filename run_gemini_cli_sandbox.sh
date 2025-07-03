#!/usr/bin/env bash

# このスクリプトは、AWS SSO認証情報とPerplexity APIキーを取得し、.envファイルに書き出した上で、
# wanileap-sandboxイメージを使ってgemini-cliをサンドボックスモードで起動します。

# --- 依存コマンドの存在チェック ---
for cmd in aws gemini docker; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: Command '$cmd' not found. Please install it." >&2
    exit 1
  fi
done

# エラー発生時は即時終了
set -euo pipefail

# --- AWS SSO認証情報の取得 ---
# AWS SSO認証情報を取得します。事前に 'aws sso login' を実行し、SSOセッションが有効であることを確認してください。
# aws configure export-credentials --format env の出力をパースして個別の変数に格納
eval $(aws configure export-credentials --format env | grep -E '^(export AWS_ACCESS_KEY_ID|export AWS_SECRET_ACCESS_KEY|export AWS_SESSION_TOKEN)=')

if [[ -z "$AWS_ACCESS_KEY_ID" ]] || [[ -z "$AWS_SECRET_ACCESS_KEY" ]] || [[ -z "$AWS_SESSION_TOKEN" ]]; then
  echo "Error: Failed to retrieve AWS SSO credentials. Ensure 'aws sso login' has been executed and AWS CLI is configured." >&2
  exit 1
fi

# --- Perplexity APIキーの取得 ---
# AWS Systems Manager Parameter StoreからPerplexity APIキーを取得します。
PERPLEXITY_API_KEY=$(aws ssm get-parameter --name /perplexity/apikey --with-decryption --query 'Parameter.Value' --output text)
if [[ $? -ne 0 ]] || [[ -z "$PERPLEXITY_API_KEY" ]]; then
  echo "Error: Failed to retrieve Perplexity API key from SSM Parameter Store." >&2
  exit 1
fi

# --- .envファイルへの書き込み ---
# 取得した認証情報とAPIキーを一時ファイルに書き込み、その後.envファイルを上書きします。
# これにより、常にクリーンな.envファイルが生成され、余分な空行がなくなります。
cat << EOF > .env.tmp
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
PERPLEXITY_API_KEY="$PERPLEXITY_API_KEY"
EOF

mv .env.tmp .env

# --- .envファイルの内容検証 ---
# .envファイルに必須なAWS認証情報とAPIキーが全て揃っているかをチェックします。
# 環境変数に設定せずにファイルの内容を直接検証します.
# AWS認証情報のチェック
if ! grep -E "^AWS_ACCESS_KEY_ID=[^[:space:]]+" .env >/dev/null; then
  echo "Error: AWS_ACCESS_KEY_ID is missing or empty in .env file." >&2
  exit 1
fi
if ! grep -E "^AWS_SECRET_ACCESS_KEY=[^[:space:]]+" .env >/dev/null; then
  echo "Error: AWS_SECRET_ACCESS_KEY is missing or empty in .env file." >&2
  exit 1
fi
if ! grep -E "^AWS_SESSION_TOKEN=[^[:space:]]+" .env >/dev/null; then
  echo "Error: AWS_SESSION_TOKEN is missing or empty in .env file." >&2
  exit 1
fi

# Perplexity APIキーのチェック
if ! grep -E "^PERPLEXITY_API_KEY=[^[:space:]]+" .env >/dev/null; then
  echo "Error: PERPLEXITY_API_KEY is missing or empty in .env file." >&2
  exit 1
fi

# --- gemini-cliのサンドボックス起動 ---
# 事前にビルドしたwanileap-sandboxイメージでgemini-cliをサンドボックスモードで起動します。
gemini -s --sandbox-image wanileap-sandbox -y

# Gemini CLIが終了したら.envファイルをクリア
echo "" > .env
echo ".env file content has been cleared."
