<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { logout, session } from './api'
import Login from './views/Login.vue'
import Dashboard from './views/Dashboard.vue'
import Users from './views/Users.vue'
import UserDetail from './views/UserDetail.vue'
import Audit from './views/Audit.vue'

// 简易 hash 路由：#/、#/users、#/users/<id>、#/audit
const hash = ref(location.hash)
const onHash = () => (hash.value = location.hash)
onMounted(() => window.addEventListener('hashchange', onHash))
onUnmounted(() => window.removeEventListener('hashchange', onHash))

const route = computed(() => {
  const parts = hash.value.replace(/^#\/?/, '').split('/').filter(Boolean)
  if (parts[0] === 'users' && parts[1]) return { view: 'user', id: decodeURIComponent(parts[1]) }
  if (parts[0] === 'users') return { view: 'users' }
  if (parts[0] === 'audit') return { view: 'audit' }
  return { view: 'home' }
})
</script>

<template>
  <Login v-if="!session.user" />
  <div v-else class="layout">
    <nav class="nav">
      <h1>交易日记后台</h1>
      <a href="#/" :class="{ active: route.view === 'home' }">概览</a>
      <a href="#/users" :class="{ active: route.view === 'users' || route.view === 'user' }">用户</a>
      <a href="#/audit" :class="{ active: route.view === 'audit' }">操作日志</a>
      <a @click="logout">退出</a>
      <div class="foot">{{ session.user.email }}</div>
    </nav>
    <main class="main">
      <Dashboard v-if="route.view === 'home'" />
      <Users v-else-if="route.view === 'users'" />
      <UserDetail v-else-if="route.view === 'user'" :id="route.id" :key="route.id" />
      <Audit v-else-if="route.view === 'audit'" />
    </main>
  </div>
</template>
