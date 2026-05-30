# VIAQ Platform – Repository Index

Welcome to the Viaq-Platform GitHub Organization. This is the central hub for all source code, infrastructure, and tooling related to the VIAQ Platform. Our platform is a comprehensive suite of services designed to empower real‑time IoT data processing, analytics, and scalable applications.

**For more information, please visit our official website and application:**

- Website: [viaq.ir](https://viaq.ir)
- App: [viaq.ir/application](https://viaq.ir/application)

---

## 📚 Repositories Index

Our projects are organized into several categories to ensure clarity and maintainability. Below is a complete index of all repositories within this organization.

### a) Backend & Infrastructure Services

| Repository | Server Source Path | Description |
|------------|--------------------|-------------|
| `viaq-backend` | `/var/www/viaq-backend` | The main platform repository. Contains the core Node.js API (`node-mongo`), the `docker-compose.yml` for infrastructure management, and server administration scripts. |
| `viaq-cloud` | `/var/www/viaq-cloud` | A collection of high‑performance Go microservices for initial, heavy‑duty processing of raw IoT data. |
| `viaq-monitoring` | `/var/www/viaq-monitoring` | A metrics exporter service that provides health and status data from all system components for Telegraf to scrape. |

### b) Frontend Applications

| Repository | Server Source Path | Description |
|------------|--------------------|-------------|
| `frontend-user-dashboard` | `/var/www/user-viaq` | The source code for the main user dashboard, accessible at `user.viaq.ir`. |
| `frontend-admin-panel` | `/var/www/admin-viaq` | The source code for the administrative panel, accessible at `admin.viaq.ir`. |
| `frontend-public-website` | `/var/www/viaq-frontend` | The source code for the main public‑facing company website (`viaq.ir`). |
| `frontend-invite-page` | `/var/www/viaq-invite` | A small, standalone application for the user invitation page (`invite.viaq.ir`). |

### c) Mobile Application

| Repository | Server Source Path | Description |
|------------|--------------------|-------------|
| `mobile-app-flutter` | N/A | The complete Flutter project for our mobile application (Android and PWA). |

### d) Side Projects

| Repository | Server Source Path | Description |
|------------|--------------------|-------------|
| `tiam-backend` | `/var/www/tiam` | A separate backend service for the Tiam platform. |

### e) Tooling & Organization

| Repository | Server Source Path | Description |
|------------|--------------------|-------------|
| `ci-cd-templates` | `/var/www/ci-cd-templates` | The central repository for storing reusable GitHub Actions workflows used across all projects. |

---

## ⚠️ Important Notice

Due to organizational policies, our repositories are not open source and are **private**. Therefore, the source code and detailed implementations are not publicly accessible. If you are interested in collaboration or partnership, please contact us directly through our website.
