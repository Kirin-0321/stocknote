#!/usr/bin/env bash
# 本地执行：构建管理后台、打包上传、在服务器上安装。
#   SSH_KEY=~/.ssh/stocknote_deploy bash server/deploy/deploy.sh
set -euo pipefail
cd "$(dirname "$0")/.."

HOST=${DEPLOY_HOST:-root@121.199.17.162}
KEY=${SSH_KEY:-$HOME/.ssh/stocknote_deploy}
SSH="ssh -i $KEY -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

(cd web && npm run build >/dev/null)

STAGE=$(mktemp -d)
cp -r app requirements.txt deploy "$STAGE/"
cp -r web/dist "$STAGE/web"
find "$STAGE" -name __pycache__ -prune -exec rm -rf {} +

tar -C "$STAGE" -czf - . | $SSH "$HOST" 'rm -rf /opt/stocknote/src && mkdir -p /opt/stocknote/src && tar -xzf - -C /opt/stocknote/src'
$SSH "$HOST" 'bash /opt/stocknote/src/deploy/remote_setup.sh'
rm -rf "$STAGE"
