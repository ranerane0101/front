/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
/* ↓↓↓追加した部分↓↓↓ */
  output: 'standalone',
/* ↑↑↑追加した部分↑↑↑ */
}

module.exports = nextConfig