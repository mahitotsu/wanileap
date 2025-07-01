#!/bin/bash

# --- 依存コマンドの存在チェック ---
if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker command not found. Please install Docker." >&2
  exit 1
fi

# エラー発生時は即時終了
set -e

# --- Dockerイメージのビルド ---
# wanileap-sandbox環境用のDockerイメージをビルドします。
docker build -t wanileap-sandbox -f .gemini/sandbox.Dockerfile .gemini