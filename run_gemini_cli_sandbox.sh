#!/bin/bash

# 事前にビルドしたwanileap-sandboxイメージでgemini-cliをサンドボックスモードで起動します。
set -e

gemini --sandbox-image wanileap-sandbox