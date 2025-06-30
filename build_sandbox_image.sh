#!/bin/bash

# wanileap-sandbox環境用のDockerイメージをビルドします。
set -e

docker build -t wanileap-sandbox -f .gemini/sandbox.Dockerfile .gemini