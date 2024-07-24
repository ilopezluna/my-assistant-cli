ARG NODE_VERSION=20.10.0

FROM node:${NODE_VERSION}-alpine AS deps
WORKDIR /usr/src/app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev

FROM node:${NODE_VERSION}-alpine AS builder
WORKDIR /usr/src/app
COPY . .
RUN npm ci
RUN npm run build

FROM node:${NODE_VERSION}-alpine AS runner
ENV NODE_ENV production
WORKDIR /usr/src/app
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist
ENTRYPOINT ["node", "dist/app.js"]