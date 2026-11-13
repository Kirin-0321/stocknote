<script setup>
import { onMounted, ref } from 'vue'
import { api } from '../api'
import { TABLES } from '../tables'

const stats = ref(null)
const error = ref('')
const name = (t) => TABLES.find((x) => x.tbl === t)?.name ?? t

onMounted(async () => {
  try {
    stats.value = await api('/api/admin/stats')
  } catch (e) {
    error.value = e.message
  }
})
</script>

<template>
  <h2>概览</h2>
  <p v-if="error" class="err">{{ error }}</p>
  <template v-if="stats">
    <div class="cards" style="margin-bottom: 16px">
      <div class="card"><div class="muted">用户数</div><div class="v">{{ stats.users }}</div></div>
      <div class="card"><div class="muted">近 7 天同步过</div><div class="v">{{ stats.active_7d }}</div></div>
    </div>
    <div class="panel">
      <h3 style="margin-top: 0">各类数据（全部用户，不含已删除）</h3>
      <div class="cards">
        <div v-for="(n, t) in stats.tables" :key="t" class="card">
          <div class="muted">{{ name(t) }}</div>
          <div class="v">{{ n }}</div>
        </div>
      </div>
      <p v-if="!Object.keys(stats.tables).length" class="muted">暂无数据</p>
    </div>
  </template>
</template>
