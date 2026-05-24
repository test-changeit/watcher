# syntax=docker/dockerfile:1
FROM node:20.11-bookworm-slim
ARG SERVICE_DIR=/app/services/watcher

LABEL maintainer="rosen-bridge team <team@rosen.tech>"
LABEL description="Docker image for the watcher service owned by rosen-bridge organization."
LABEL org.label-schema.vcs-url="https://github.com/rosen-bridge/watcher-service"

RUN --mount=type=cache,target=/root/.npm \
    --mount=type=cache,target=/tmp/node-compile-cache \
    npm i -g npm@11.6.2 && \
    adduser --disabled-password --home /app --no-create-home --uid 3000 --gecos "ErgoPlatform" ergo && \
    install -m 0740 -o ergo -g ergo -d ${SERVICE_DIR}/logs \
    && chown -R ergo:ergo /app/ && umask 0077
USER ergo

WORKDIR ${SERVICE_DIR}
# TODO: Add layer optimizations when at least one package is added to the monorepo
# https://git.ergopool.io/ergo/rosen-bridge/watcher/-/issues/131
COPY --chmod=700 --chown=ergo:ergo . .
ENV NODE_ENV=production
RUN --mount=type=cache,target=/app/.npm npm ci

ENV SERVICE_PORT=3000
EXPOSE 3000

ENTRYPOINT ["npm", "run", "start"]
