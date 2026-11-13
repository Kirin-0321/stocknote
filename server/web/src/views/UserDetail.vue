<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { api, fmtTime, session } from '../api'
import { TABLES } from '../tables'

const props = defineProps({ id: String })
const user = ref(null)
const error = ref('')
const tbl = ref('journal_entries')
const q = ref('')
const includeDeleted = ref(false)
const page = ref(0)
const records = ref({ total: 0, items: [] })
const editing = ref(null) // { rec, text, error }
const PAGE = 50

const meta = computed(() => TABLES.find((t) => t.tbl === tbl.value))
const tabs = computed(() => TABLES.filter((t) => (user.value?.tables?.[t.tbl]?.alive ?? 0) + (user.value?.tables?.[t.tbl]?.deleted ?? 0) > 0 || ['journal_entries', 'trades'].includes(t.tbl)))

async function loadUser() {
  try {
    user.value = await api(`/api/admin/users/${props.id}`)
  } catch (e) {
    error.value = e.message
  }
}

async function loadRecords() {
  error.value = ''
  try {
    const p = new URLSearchParams({ tbl: tbl.value, q: q.value, include_deleted: includeDeleted.value, offset: page.value * PAGE, limit: PAGE })
    records.value = await api(`/api/admin/users/${props.id}/records?${p}`)
  } catch (e) {
    error.value = e.message
  }
}

watch([tbl, includeDeleted], () => {
  page.value = 0
  loadRecords()
})
watch(page, loadRecords)
onMounted(() => {
  loadUser()
  loadRecords()
})

function cell(rec, col) {
  const v = rec.data[col.key]
  return col.fmt ? col.fmt(v) : v ?? '—'
}

// ───────────── 用户操作 ─────────────

async function patch(body, confirmText) {
  if (confirmText && !confirm(confirmText)) return
  try {
    await api(`/api/admin/users/${props.id}`, { method: 'PATCH', body })
    await loadUser()
  } catch (e) {
    alert(e.message)
  }
}

function resetPassword() {
  const pw = prompt('输入新密码（至少 8 位）。该用户所有设备会被退出登录。')
  if (pw) patch({ password: pw })
}

// ───────────── 记录编辑 ─────────────

function openEditor(rec) {
  editing.value = { rec, text: JSON.stringify(rec.data, null, 2), error: '' }
}

async function saveEdit() {
  let data
  try {
    data = JSON.parse(editing.value.text)
  } catch {
    editing.value.error = 'JSON 格式错误'
    return
  }
  try {
    const r = editing.value.rec
    await api(`/api/admin/users/${props.id}/records/${tbl.value}/${encodeURIComponent(r.id)}`, { method: 'PUT', body: { data } })
    editing.value = null
    await loadRecords()
  } catch (e) {
    editing.value.error = e.message
  }
}

async function removeOrRestore(rec) {
  const deleted = rec.deleted_at != null
  if (!deleted && !confirm('删除这条记录？（软删除，可恢复；用户设备同步后也会删除）')) return
  try {
    const base = `/api/admin/users/${props.id}/records/${tbl.value}/${encodeURIComponent(rec.id)}`
    await api(deleted ? `${base}/restore` : base, { method: deleted ? 'POST' : 'DELETE' })
    editing.value = null
    await Promise.all([loadRecords(), loadUser()])
  } catch (e) {
    alert(e.message)
  }
}
</script>

<template>
  <p><a href="#/users">← 用户列表</a></p>
  <p v-if="error" class="err">{{ error }}</p>
  <div v-if="user" class="panel">
    <div class="row">
      <h2 style="margin: 0">{{ user.display_name || user.email }}</h2>
      <span v-if="user.role === 'admin'" class="tag admin">管理员</span>
      <span v-if="user.disabled" class="tag off">已停用</span>
      <span class="spacer" />
      <button @click="resetPassword">重置密码</button>
      <button v-if="user.id !== session.user.id" @click="patch({ role: user.role === 'admin' ? 'user' : 'admin' }, user.role === 'admin' ? '取消管理员权限？' : '设为管理员？管理员可查看和修改所有用户的数据。')">
        {{ user.role === 'admin' ? '取消管理员' : '设为管理员' }}
      </button>
      <button v-if="user.id !== session.user.id" :class="{ danger: !user.disabled }" @click="patch({ disabled: !user.disabled }, user.disabled ? null : '停用后该用户无法登录和同步，确定？')">
        {{ user.disabled ? '启用' : '停用' }}
      </button>
    </div>
    <p class="muted">
      {{ user.email }} · 注册 {{ fmtTime(user.created_at) }} · 最近登录 {{ fmtTime(user.last_login_at) }} · 最近同步 {{ fmtTime(user.last_sync_at) }}
    </p>
  </div>

  <div class="panel">
    <div class="tabs">
      <a v-for="t in tabs" :key="t.tbl" :class="{ active: t.tbl === tbl }" @click="tbl = t.tbl">
        {{ t.name }} <span class="muted" v-if="user?.tables?.[t.tbl]">{{ user.tables[t.tbl].alive }}</span>
      </a>
    </div>
    <div class="row" style="margin-bottom: 12px">
      <input v-model="q" placeholder="搜索内容" @keyup.enter="page = 0; loadRecords()" />
      <button @click="page = 0; loadRecords()">搜索</button>
      <label><input v-model="includeDeleted" type="checkbox" /> 显示已删除</label>
      <span class="spacer" />
      <span class="muted">共 {{ records.total }} 条</span>
    </div>
    <table>
      <thead>
        <tr><th v-for="c in meta.cols" :key="c.key">{{ c.label }}</th><th>更新</th></tr>
      </thead>
      <tbody>
        <tr v-for="r in records.items" :key="r.id" class="click" :style="{ opacity: r.deleted_at ? 0.5 : 1 }" @click="openEditor(r)">
          <td v-for="c in meta.cols" :key="c.key" :class="{ wide: c.wide }">{{ cell(r, c) }}</td>
          <td class="muted">{{ fmtTime(r.updated_at) }}<span v-if="r.deleted_at" class="tag off">已删除</span></td>
        </tr>
      </tbody>
    </table>
    <div class="row" style="margin-top: 12px">
      <button :disabled="page === 0" @click="page--">上一页</button>
      <span class="muted">第 {{ page + 1 }} / {{ Math.max(1, Math.ceil(records.total / PAGE)) }} 页</span>
      <button :disabled="(page + 1) * PAGE >= records.total" @click="page++">下一页</button>
    </div>
  </div>

  <div v-if="editing" class="modal" @click.self="editing = null">
    <div class="box">
      <div class="row">
        <h3 style="margin: 0">{{ meta.name }} · {{ editing.rec.id }}</h3>
        <span class="spacer" />
        <button @click="editing = null">关闭</button>
      </div>
      <p class="muted">直接编辑该行的全部字段。保存后用户的设备在下次同步时会拿到修改。JSON 类字段（如 tags）以字符串存储。</p>
      <textarea v-model="editing.text" rows="22" spellcheck="false" />
      <p v-if="editing.error" class="err">{{ editing.error }}</p>
      <div class="row">
        <button :class="{ danger: !editing.rec.deleted_at }" @click="removeOrRestore(editing.rec)">
          {{ editing.rec.deleted_at ? '恢复' : '删除' }}
        </button>
        <span class="spacer" />
        <button class="primary" @click="saveEdit">保存修改</button>
      </div>
    </div>
  </div>
</template>
