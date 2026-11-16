# 交易日记 · 云同步服务与管理后台

- `app/`：FastAPI + SQLite 同步 API（注册登录、增量同步、管理员接口）
- `web/`：Vue 3 管理后台（管理员登录后查看 / 修改所有用户的数据，操作留审计日志）
- `deploy/`：nginx、systemd、部署脚本

## 同步协议

- App 中所有带 `id / created_at / updated_at / deleted_at / device_id` 的表参与同步，每行以原始列 JSON 保存在 `records(user_id, tbl, id)`。
- 推送：`POST /api/sync/push`，按 `updated_at` last-write-wins，旧版本被拒（`stale`），相同版本忽略。
- 拉取：`GET /api/sync/pull?since=<seq>`，服务器每次写入分配全局递增 `seq`。
- App 先推后拉；本地未同步的修改被服务器更新版本覆盖时，旧版本写入 App 的修改历史。
- 删除是软删除（`deleted_at`），会同步到所有设备。
- 管理员修改会把 `updated_at` 改为当前时间，用户设备下次同步时拉到。

## 本地开发

```bash
cd server
python -m venv .venv
.venv/Scripts/pip install -r requirements-dev.txt
.venv/Scripts/python -m pytest
.venv/Scripts/python -m uvicorn app.main:create_app --factory --port 8100
```

管理后台：`cd web && npm install && npm run dev`（/api 转发到 8100）。

App 端到端测试（会启动本地服务器）：在项目根目录运行 `flutter test test/live/cloud_sync_live_test.dart --run-skipped`。

## 部署

```bash
SSH_KEY=~/.ssh/stocknote_deploy bash server/deploy/deploy.sh
```

服务器上：nginx 监听 8443（自签证书，含域名与 IP；域名未备案前阿里云会按 SNI 拦截，只能用 IP 访问），API 只监听 127.0.0.1:8100，数据在 `/var/lib/stocknote`，每天 3:30 备份。
脚本最后输出证书 SHA-256 指纹，填到 App「账户与云同步 → 服务器设置」或 `.env` 的 `SYNC_CERT_SHA256`。

域名访问管理后台：`https://stocknote.ainewstrding.top`（`deploy/nginx-stocknote-domain.conf`，装在 `/etc/nginx/conf.d/stocknote-domain.conf`，Let's Encrypt 证书）。
证书用 acme.sh TLS-ALPN 签发（80 端口验证会被阿里云未备案拦截），续期时会短暂停 nginx 约 10 秒，与服务器上其他域名相同。
大陆网络直连该域名会被阿里云拦截（未备案），App 同步继续用 `https://121.199.17.162:8443` + 证书指纹。

创建管理员（密码在终端交互输入）：

```bash
sudo -u stocknote bash -c 'set -a; . /etc/stocknote/stocknote.env; cd /opt/stocknote/server; /opt/stocknote/venv/bin/python -m app.cli create-admin you@example.com'
```

关闭公开注册：把 `/etc/stocknote/stocknote.env` 中 `STOCKNOTE_ALLOW_REGISTRATION` 改为 `false` 后 `systemctl restart stocknote`。
