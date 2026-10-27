# Notify Panel

[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Web-blue?logo=googlechrome&logoColor=white)](https://flutter.dev/multi-platform/web)
[![Architecture](https://img.shields.io/badge/Architecture-Clean-success)](#architecture)
[![State Management](https://img.shields.io/badge/State-Riverpod-9C27B0)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](#docker)

**Admin panel for Notify Service (NaaS)** — a modern, production-ready Flutter web application for managing tenants, users, devices, and multi-channel notifications.

[Features](#features) ·
[Architecture](#architecture) ·
[Project Structure](#project-structure) ·
[Quick Start](#quick-start) ·
[Screens](#screens--capabilities) ·
[Development](#development) ·
[Docker](#docker) ·
[Testing](#testing) ·
[Configuration](#configuration)

---

## Overview

Notify Panel is the official web administration interface for [Notify Service](https://github.com/usgitAz/notify-service).  
It allows tenants to authenticate with their API key, manage end-users and devices, compose and track notifications, and monitor backend health — all from a clean, responsive Flutter web UI.

| Capability              | Status      |
|-------------------------|-------------|
| **API Key authentication** | Implemented |
| **Users management**       | Implemented |
| **Device registration**    | Implemented |
| **Email notifications**    | Implemented |
| **Notification tracking**  | Implemented |
| **Health dashboard**       | Implemented |
| **Push notifications**     | Future      |
| **SMS**                    | Future      |

**Stack highlights:** Flutter 3.x (Web) · Riverpod 3 · go_router · Dio · Freezed · Clean Architecture · Docker multi-stage · Nginx

---

## Features

* **Secure API-key login** — paste `sk_live_...` / `sk_test_...`; session persisted in secure storage and restored on boot
* **Auth-aware routing** — automatic redirect to login / dashboard based on session state
* **Multi-tenant isolation** — every request is scoped by the authenticated tenant’s API key
* **Users CRUD** — create, list, view, update email, soft-delete / reactivate
* **Device registration** — register push devices (platform + provider + token) under a user
* **Email composer** — send notifications with optional Idempotency-Key, title, body, and payload
* **Notification list & detail** — filter by status/channel, view attempts, last error, and raw JSON payload
* **Live status polling** — pending notifications are polled until final state (with timeout)
* **Health dashboard** — liveness + readiness probes with sub-checks (DB, Redis, …)
* **Light / Dark / System theme** — preference persisted across sessions
* **Clean Architecture** — domain / data / presentation layers per feature; use-cases, repositories, entities
* **Production Docker** — multi-stage build (Flutter → nginx-unprivileged), security headers, long-cache for hashed assets
* **Developer experience** — code generation (Freezed, Riverpod, JSON), strict analysis, shared UI kit

---

## Architecture

```
                    ┌─────────────────────────────────────────┐
                    │              Browser (User)              │
                    └───────────────────┬─────────────────────┘
                                        │  X-API-Key
                                        ▼
┌───────────────────────────────────────────────────────────────────────────┐
│  Flutter Web (Notify Panel)                                               │
│  MaterialApp.router + go_router + Riverpod                                │
│  Auth interceptor · Idempotency interceptor · Envelope parser             │
└───────────────┬─────────────────────────────┬─────────────────────────────┘
                │                             │
                ▼                             ▼
        ┌───────────────┐             ┌───────────────┐
        │   Features    │             │  Core Layer   │
        │  auth         │             │  network      │
        │  users        │             │  storage      │
        │  devices      │             │  providers    │
        │  notifications│             │  config       │
        │  dashboard    │             └───────────────┘
        └───────┬───────┘
                │
                ▼
        ┌───────────────┐
        │ Notify Service│  ← FastAPI backend
        │ (API + SMTP)  │
        └───────────────┘
```

### Layering (per feature)

| Layer          | Responsibility                                      |
|----------------|-----------------------------------------------------|
| **domain**     | Entities, repository contracts, use-cases           |
| **data**       | DTOs, remote/local data sources, repository impls   |
| **presentation** | Pages, widgets, Riverpod notifiers / providers    |

Core concerns (networking, storage, theming, routing) live under `lib/core` and `lib/app`.

---

## Project Structure

```
notify-panel/
├── assets/images/                 # Static assets
├── lib/
│   ├── app/
│   │   ├── router/                # go_router + route constants
│   │   ├── shell/                 # Authenticated app shell (nav)
│   │   ├── theme/                 # Light / Dark themes
│   │   └── app.dart
│   ├── core/
│   │   ├── config/                # Env (API_BASE_URL, timeouts…)
│   │   ├── constants/
│   │   ├── error/
│   │   ├── network/               # Dio client, interceptors, envelope
│   │   ├── providers/
│   │   ├── storage/               # Secure storage abstraction
│   │   ├── usecase/
│   │   └── utils/
│   ├── features/
│   │   ├── auth/                  # Login, session, tenant
│   │   ├── dashboard/             # Health probes
│   │   ├── users/                 # CRUD + soft-delete
│   │   ├── devices/               # Register / list devices
│   │   └── notifications/         # List, detail, compose email
│   ├── shared/widgets/            # Reusable UI components
│   └── main.dart
├── nginx/                         # SPA-friendly nginx config
├── test/                          # Unit & widget tests
├── web/
├── Dockerfile                     # Multi-stage (Flutter → nginx)
├── docker-compose.yml
├── docker-compose.dev.yml
├── docker-compose.prod.yml
├── pubspec.yaml
└── analysis_options.yaml
```

---

## Quick Start

### Prerequisites

* Flutter **3.24+** (or the version pinned in the Dockerfile)
* A running [Notify Service](https://github.com/usgitAz/notify-service) instance
* Docker & Docker Compose (optional but recommended)

### Option A — Docker (recommended)

```bash
# 1. Environment
cp .env.example .env
# Edit API_BASE_URL if needed (must be reachable from the browser)

# 2. Start
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build

# 3. Open
open http://localhost:8080
```

| Service     | URL                          |
|-------------|------------------------------|
| Panel       | http://localhost:8080        |
| Backend API | http://localhost:8000/docs   |

Stop:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml down
```

### Option B — Local development

```bash
# 1. Dependencies + code generation
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 2. Run (Chrome)
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

---

## Screens & Capabilities

### Authentication
- Login with API key (`sk_live_…` / `sk_test_…`)
- Session restored from secure storage on cold start
- Automatic logout on 401 responses

### Dashboard
- Liveness (`/health`) and Readiness (`/health/ready`) probes
- Sub-check status (database, redis, …)
- Last checked timestamp

### Users
- Paginated list
- Create user (external ID + optional email)
- Detail view
- Update email / soft-delete / reactivate

### Devices
- Register device under a user (platform, provider, token, name)
- List active devices of a user

### Notifications
- List with filters (status, channel) and pagination
- Detail page: status, attempts, last error, full JSON payload viewer
- Email composer with optional Idempotency-Key
- Automatic polling while status is `pending`

---

## Development

### Code generation

The project uses Freezed, json_serializable and riverpod_generator:

```bash
dart run build_runner build --delete-conflicting-outputs
# or watch mode
dart run build_runner watch --delete-conflicting-outputs
```

### Linting

```bash
flutter analyze
```

Strict analysis is enabled via `analysis_options.yaml` + `riverpod_lint`.

### Shared UI kit

Reusable components live under `lib/shared/widgets/`:

- `AppButton`, `AppTextField`
- `AsyncValueWidget`, `LoadingIndicator`, `ErrorView`, `EmptyState`
- `StatusBadge`, `JsonViewer`, `ConfirmDialog`, `AppSnackbar`

---

## Docker

### Multi-stage build

1. **Builder** — official Flutter image compiles the web release bundle  
2. **Runtime** — `nginx/nginx-unprivileged` serves static files on port 8080

Key points:
- `API_BASE_URL` is injected at **build time** via `--dart-define`
- PWA strategy disabled (admin panel does not need offline support)
- Non-root user, security headers, long-cache for hashed assets, SPA fallback

### Compose profiles

```bash
# Development (port 8080 exposed)
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build

# Production (loopback only + resource limits)
API_BASE_URL=https://api.example.com/api/v1 \
  docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

---

## Testing

```bash
# Unit & widget tests
flutter test
```

Test layout mirrors the feature structure:

```
test/
├── core/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── devices/
│   ├── notifications/
│   └── users/
├── fixtures/
└── helpers/
```

Mocks are provided via `mocktail`.

---

## Configuration

### Build-time environment

| Variable         | Description                                      | Default                              |
|------------------|--------------------------------------------------|--------------------------------------|
| `API_BASE_URL`   | Full API base including `/api/v1`                | `http://localhost:8000/api/v1`       |

Usage:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

### Runtime constants (`lib/core/config/env.dart`)

- Connect / receive / send timeouts
- Notification polling interval & max duration
- Default & max page size

---

## Related Projects

- **Backend**: [notify-service](https://github.com/usgitAz/notify-service) — FastAPI Notification-as-a-Service platform

---

## License

MIT
