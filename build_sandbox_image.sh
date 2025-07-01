#!/bin/bash

# dockerコマンドの存在チェック
if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker command not found. Please install Docker." >&2
  exit 1
fi

# wanileap-sandbox環境用のDockerイメージをビルドします。
set -e

docker build -t wanileap-sandbox -f .gemini/sandbox.Dockerfile .gemini