# ベースイメージとして最新のDebianを使用
FROM public.ecr.aws/docker/library/debian:latest

# 必要なパッケージ・Node.js・gemini-cliを一括インストールし、不要ファイルを削除
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g @google/gemini-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
