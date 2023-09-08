# ステージ1: ベースイメージとしてNode.js 18を使用
FROM node:18-alpine AS base

# ステージ2: 依存関係をインストール
FROM base AS deps

# libc6-compatパッケージをインストール（必要に応じて）
RUN apk add --no-cache libc6-compat
WORKDIR /app

# プロジェクトの依存関係ファイルをコピーしてインストール
COPY package.json ./
COPY package-lock.json ./
RUN npm ci

# ステージ3: アプリケーションのビルド
FROM base AS builder
WORKDIR /app

# 依存関係をビルド用ステージからコピー
COPY --from=deps /app/mode_modules ./node_modules
COPY .

# アプリケーションのビルドを実行
RUN npm run build

# ステージ4: アプリケーションを実行するランタイムステージ
FROM base AS runner
WORKDIR /app

# 環境変数を設定（ここではNODE_ENVをproductionに設定）
ENV NODE_ENV production

# ユーザーとグループを作成
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# 静的ファイルやアプリケーションをコピー
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# ユーザーをnextjsに切り替え
USER nextjs

# ポート3000を公開
EXPOSE 3000

# コンテナ起動時に実行されるコマンド
CMD ["node", "server.js"]
