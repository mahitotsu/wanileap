# ベースイメージとして最新のDebianを使用
FROM public.ecr.aws/docker/library/debian:bookworm-slim

# 必要なパッケージ、Node.js、gemini-cli、uvをインストールし、不要ファイルを削除
# 各処理の内容を詳細にコメントしています
RUN set -eux; \
    \
    # 1. パッケージリストの更新とシステムのアップグレード
    apt-get update -y; \
    apt-get upgrade -y; \
    \
    # 2. 必要なパッケージのインストール（curl, ca-certificates, git）
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        git; \
    \
    # 3. Node.js 24.x のインストール（公式スクリプトを利用）
    curl -fsSL https://deb.nodesource.com/setup_24.x | bash -; \
    apt-get install -y --no-install-recommends nodejs; \
    \
    # 4. gemini-cli をグローバルインストール（dev依存は除外）
    npm install -g --omit=dev @google/gemini-cli; \
    \
    # 5. uv をインストール（公式スクリプトのためcurl | shを許容）
    export UV_INSTALL_DIR=/usr/local/bin; \
    curl -LsSf https://astral.sh/uv/install.sh | sh; \
    \
    # 6. 不要なキャッシュ・一時ファイル・npmキャッシュを削除し、イメージを軽量化
    apt-get clean; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.npm

# uvのキャッシュディレクトリを環境変数で指定
ENV UV_CACHE_DIR=./.cache/uv