#!/bin/bash

# 事前にビルドしたwanileap-sandboxイメージでgemini-cliをサンドボックスモードで起動します。
set -e

gemini -s --sandbox-image wanileap-sandbox -d