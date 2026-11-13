// API 封装：令牌存 sessionStorage（关闭标签页即退出），访问令牌过期时用刷新令牌续期。
import { reactive } from 'vue'

export const session = reactive({
  user: JSON.parse(sessionStorage.getItem('sn_user') || 'null'),
})

function save(t) {
  sessionStorage.setItem('sn_access', t.access_token)
  sessionStorage.setItem('sn_refresh', t.refresh_token)
  sessionStorage.setItem('sn_user', JSON.stringify(t.user))
  session.user = t.user
}

export function logout() {
  const rt = sessionStorage.getItem('sn_refresh')
  if (rt) fetch('/api/auth/logout', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ refresh_token: rt }) })
  sessionStorage.clear()
  session.user = null
}

export async function login(email, password) {
  const r = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password, device_name: '管理后台' }),
  })
  const body = await r.json().catch(() => ({}))
  if (!r.ok) throw new Error(body.detail || `登录失败（${r.status}）`)
  if (body.user.role !== 'admin') throw new Error('该账户不是管理员')
  save(body)
}

async function refresh() {
  const rt = sessionStorage.getItem('sn_refresh')
  if (!rt) return false
  const r = await fetch('/api/auth/refresh', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refresh_token: rt }),
  })
  if (!r.ok) return false
  save(await r.json())
  return true
}

export async function api(path, { method = 'GET', body } = {}) {
  const send = () =>
    fetch(path, {
      method,
      headers: {
        Authorization: `Bearer ${sessionStorage.getItem('sn_access') || ''}`,
        ...(body ? { 'Content-Type': 'application/json' } : {}),
      },
      body: body ? JSON.stringify(body) : undefined,
    })
  let r = await send()
  if (r.status === 401 && (await refresh())) r = await send()
  if (r.status === 401) {
    logout()
    throw new Error('登录已过期')
  }
  const data = await r.json().catch(() => ({}))
  if (!r.ok) throw new Error(data.detail || `请求失败（${r.status}）`)
  return data
}

export function fmtTime(ms) {
  if (!ms) return '—'
  const d = new Date(Number(ms))
  const p = (n) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}`
}
