<script setup>
import { onMounted, ref } from 'vue'
import { api, fmtTime } from '../api'

const rows = ref([])
const error = ref('')
const ACTIONS = { 'user.update': '修改用户', 'record.update': '修改数据', 'record.delete': '删除数据', 'record.restore': '恢复数据' }

onMounted(async () => {
  try {
    rows.value = await api('/api/admin/audit?limit=200')
  } catch (e) {
    error.value = e.message
  }
})
</script>

<template>
  <h2>操作日志</h2>
  <p class="muted">管理员对用户与数据的全部修改都会记录在这里。</p>
  <p v-if="error" class="err">{{ error }}</p>
  <div class="panel">
    <table>
      <thead><tr><th>时间</th><th>管理员</th><th>操作</th><th>用户</th><th>表 / 记录</th><th>修改后</th></tr></thead>
      <tbody>
        <tr v-for="r in rows" :key="r.id">
          <td>{{ fmtTime(r.ts) }}</td>
          <td>{{ r.actor_email }}</td>
          <td>{{ ACTIONS[r.action] || r.action }}</td>
          <td><a v-if="r.target_user" :href="`#/users/${r.target_user}`">{{ r.target_email || r.target_user }}</a></td>
          <td class="muted">{{ r.tbl }} {{ r.record_id }}</td>
          <td class="wide muted">{{ r.after }}</td>
        </tr>
      </tbody>
    </table>
    <p v-if="!rows.length && !error" class="muted">暂无记录</p>
  </div>
</template>
