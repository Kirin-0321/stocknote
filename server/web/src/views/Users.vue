<script setup>
import { onMounted, ref } from 'vue'
import { api, fmtTime } from '../api'

const users = ref([])
const q = ref('')
const error = ref('')

async function load() {
  error.value = ''
  try {
    users.value = await api(`/api/admin/users?q=${encodeURIComponent(q.value)}`)
  } catch (e) {
    error.value = e.message
  }
}
onMounted(load)
</script>

<template>
  <h2>用户</h2>
  <div class="panel">
    <div class="row" style="margin-bottom: 12px">
      <input v-model="q" placeholder="搜索邮箱 / 昵称" @keyup.enter="load" />
      <button @click="load">搜索</button>
    </div>
    <p v-if="error" class="err">{{ error }}</p>
    <table>
      <thead>
        <tr><th>邮箱</th><th>昵称</th><th>角色</th><th>数据条数</th><th>注册</th><th>最近登录</th><th>最近同步</th></tr>
      </thead>
      <tbody>
        <tr v-for="u in users" :key="u.id" class="click" @click="location.hash = `#/users/${u.id}`">
          <td>{{ u.email }}</td>
          <td>{{ u.display_name || '—' }}</td>
          <td>
            <span v-if="u.role === 'admin'" class="tag admin">管理员</span>
            <span v-else class="tag">用户</span>
            <span v-if="u.disabled" class="tag off">已停用</span>
          </td>
          <td>{{ u.records }}</td>
          <td>{{ fmtTime(u.created_at) }}</td>
          <td>{{ fmtTime(u.last_login_at) }}</td>
          <td>{{ fmtTime(u.last_sync_at) }}</td>
        </tr>
      </tbody>
    </table>
    <p v-if="!users.length && !error" class="muted">没有用户</p>
  </div>
</template>

<script>
export default { computed: { location: () => window.location } }
</script>
