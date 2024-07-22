ARG NODE_VERSION=20.10.0

FROM node:${NODE_VERSION}-alpine AS builder
WORKDIR /usr/src/app
COPY . .
RUN npm ci
RUN npm run build

FROM node:${NODE_VERSION}-alpine AS runner
ENV NODE_ENV production
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/node_modules ./node_modules
ENTRYPOINT ["node", "dist/app.js"]