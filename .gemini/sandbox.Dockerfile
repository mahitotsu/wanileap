# ベースイメージとして最新のDebianを使用
FROM public.ecr.aws/docker/library/debian:latest

# 必要なパッケージ、Node.js、gemini-cliをインストールし、不要ファイルを削除
# curl, ca-certificates, git をインストール
# Node.js 24.x をインストール
# gemini-cli をグローバルインストール
# aptキャッシュをクリーンアップ
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        git && \
    curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g @google/gemini-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# UV_INSTALL_DIR 環境変数を設定し、uv をインストール
ENV UV_INSTALL_DIR=/usr/local/bin
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV UV_CACHE_DIR=./.cache/uv