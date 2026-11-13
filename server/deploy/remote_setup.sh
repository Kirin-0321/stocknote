#!/usr/bin/env bash
# 在服务器上执行（root）：安装 / 升级交易日记同步服务。可重复执行。
# 代码已解压在 /opt/stocknote/src（由 deploy.sh 上传）。
set -euo pipefail

SRC=/opt/stocknote/src
DOMAIN=stock.ainewstrding.top
PUBLIC_IP=121.199.17.162

id stocknote >/dev/null 2>&1 || useradd --system --home /var/lib/stocknote --shell /usr/sbin/nologin stocknote
mkdir -p /opt/stocknote/server /opt/stocknote/web /var/lib/stocknote/backups /etc/stocknote/tls
chown -R stocknote:stocknote /var/lib/stocknote
chmod 750 /var/lib/stocknote

# Python 环境
if ! python3 -m venv --help >/dev/null 2>&1 || ! dpkg -s python3-venv >/dev/null 2>&1; then
  apt-get update -qq && apt-get install -y -qq python3-venv
fi
[ -x /opt/stocknote/venv/bin/python ] || python3 -m venv /opt/stocknote/venv
/opt/stocknote/venv/bin/pip install -q --upgrade pip -i https://mirrors.aliyun.com/pypi/simple/
/opt/stocknote/venv/bin/pip install -q -r "$SRC/requirements.txt" -i https://mirrors.aliyun.com/pypi/simple/

# 代码与前端
rm -rf /opt/stocknote/server/app && cp -r "$SRC/app" /opt/stocknote/server/app
rm -rf /opt/stocknote/web && cp -r "$SRC/web" /opt/stocknote/web
chmod -R a+rX /opt/stocknote/server /opt/stocknote/web

# 配置（首次生成 JWT 密钥，之后保留）
if [ ! -f /etc/stocknote/stocknote.env ]; then
  umask 077
  cat > /etc/stocknote/stocknote.env <<EOF
STOCKNOTE_DB=/var/lib/stocknote/stocknote.db
STOCKNOTE_JWT_SECRET=$(openssl rand -hex 32)
STOCKNOTE_ALLOW_REGISTRATION=true
EOF
fi
chown root:stocknote /etc/stocknote/stocknote.env
chmod 640 /etc/stocknote/stocknote.env

# 自签证书（10 年，含域名与 IP），已有则保留以免 App 端指纹变化
if [ ! -f /etc/stocknote/tls/cert.pem ]; then
  openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
    -keyout /etc/stocknote/tls/key.pem -out /etc/stocknote/tls/cert.pem \
    -subj "/CN=$DOMAIN" -addext "subjectAltName=DNS:$DOMAIN,IP:$PUBLIC_IP" 2>/dev/null
  chmod 600 /etc/stocknote/tls/key.pem
fi

# systemd
cp "$SRC/deploy/stocknote.service" /etc/systemd/system/stocknote.service
systemctl daemon-reload
systemctl enable -q stocknote
systemctl restart stocknote

# nginx（独立 conf，不改动已有站点）
cp "$SRC/deploy/nginx-stocknote.conf" /etc/nginx/conf.d/stocknote.conf
nginx -t -q
systemctl reload nginx

# 每日备份数据库（保留 14 天）
cp "$SRC/deploy/backup.py" /opt/stocknote/backup.py
cat > /etc/cron.d/stocknote-backup <<'EOF'
30 3 * * * stocknote /opt/stocknote/venv/bin/python /opt/stocknote/backup.py
EOF

# 本机防火墙若启用则放行 8443（云安全组需在阿里云控制台放行）
if command -v ufw >/dev/null && ufw status | grep -q "Status: active"; then
  ufw allow 8443/tcp >/dev/null
fi

sleep 1
curl -sk https://127.0.0.1:8443/api/health && echo
echo "CERT_SHA256=$(openssl x509 -in /etc/stocknote/tls/cert.pem -outform der | sha256sum | cut -d' ' -f1)"
