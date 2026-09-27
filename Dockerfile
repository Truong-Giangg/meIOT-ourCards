# ---- Build stage (glibc, so sharp uses its prebuilt binary — no source compile) ----
FROM node:18-bullseye-slim AS build

WORKDIR /app

# Ensure sharp grabs its prebuilt binary instead of compiling libvips.
ENV SHARP_IGNORE_GLOBAL_LIBVIPS=1 \
    npm_config_build_from_source=false

COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY . .

# NAME/PIC are required by builder/init.js. Passed as build args so they can be
# baked in at build time (mirrors the .env used for local building).
ARG NAME="Stellar"
ARG PIC="sample-pic.jpeg"
ARG NICKNAME=""
ARG HBD_MSG=""
ARG SCROLL_MSG=""
ARG OPEN_DATE=""
ENV NAME=$NAME PIC=$PIC NICKNAME=$NICKNAME HBD_MSG=$HBD_MSG \
    SCROLL_MSG=$SCROLL_MSG OPEN_DATE=$OPEN_DATE

# Generate src/index.html + processed pic, then build static output to /app/dist
RUN npm run init-index-local \
    && npx parcel build src/index.html src/sleep.html src/nup.html src/fiting.html src/christmas.html src/newyear.html src/valentine.html src/halloween.html src/miss.html src/women.html src/game.html --public-url /

# ---- Production stage (tiny, non-root, no Node) ----
FROM nginxinc/nginx-unprivileged:alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf

# unprivileged image runs as uid 101 and binds 8080, not 80
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
