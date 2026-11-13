<script setup>
import { ref } from 'vue'
import { login } from '../api'

const email = ref('')
const password = ref('')
const error = ref('')
const busy = ref(false)

async function submit() {
  error.value = ''
  busy.value = true
  try {
    await login(email.value, password.value)
  } catch (e) {
    error.value = e.message
  } finally {
    busy.value = false
    password.value = ''
  }
}
</script>

<template>
  <form class="panel login" @submit.prevent="submit">
    <h2>交易日记 · 管理后台</h2>
    <p class="muted">仅限管理员账户登录</p>
    <input v-model="email" type="email" placeholder="邮箱" autocomplete="username" required />
    <input v-model="password" type="password" placeholder="密码" autocomplete="current-password" required />
    <p v-if="error" class="err">{{ error }}</p>
    <button class="primary" :disabled="busy" style="width: 100%">登录</button>
  </form>
</template>
