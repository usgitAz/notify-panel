# syntax=docker/dockerfile:1.10

# Stage 1: builder — Flutter SDK compiles the web bundle

FROM plugfox/flutter:3.47.8-web AS builder
WORKDIR /app

# Build-time API endpoint; must be reachable from the user's BROWSER,
# not from inside this container.
ARG API_BASE_URL=http://localhost:8000/api/v1

# Disable telemetry to keep builds deterministic and offline-friendly.
RUN flutter config --no-analytics && dart --disable-analytics

# Layer 1: dependency resolution (only invalidated by pubspec changes).
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get    


# Layer 2: source
COPY . .

# Code generation (produces *.g.dart files; not committed)
RUN dart run build_runner build --delete-conflicting-outputs

# Release build with PWA strategy disabled (admin panel doesn't need
# offline support; avoids stale-content issues after deploys).
RUN flutter build web --release \
    --dart-define=API_BASE_URL=${API_BASE_URL} \
    --pwa-strategy=none

# Stage 2: runtime — Nginx unprivileged image (already non-root)

FROM nginx/nginx-unprivileged:1.30.6-alpine3.24-perl AS runtime

# Our SPA config (listens on 8080 — non-root can't bind 80)
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Static build artifacts
COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:8080/ >/dev/null || exit 1