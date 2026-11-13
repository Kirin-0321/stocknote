import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  base: '/',
  server: {
    // 本地开发：API 转发到 uvicorn
    proxy: { '/api': 'http://127.0.0.1:8100' },
  },
})
