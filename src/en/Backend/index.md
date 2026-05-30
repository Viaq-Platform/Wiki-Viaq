# VIAQ Backend Platform

## 🚀 Overview

The VIAQ Backend Platform is the core infrastructure powering VIAQ's smart environmental monitoring solutions. It leverages IoT technology and data analytics to provide real-time insights into environmental parameters such as air quality, gaseous pollutants, dust, temperature, and humidity.

This repository contains the primary backend services (`node-mongo`), infrastructure configuration (`docker-compose.yml`), and management utilities required to run the VIAQ platform.

**Key Features:**
- Real-time online monitoring of environmental parameters.
- Low-cost deployment of IoT devices with no required on-site infrastructure.
- Remote monitoring and alerts via dedicated mobile applications (Android & iOS).
- Data analysis and graphical representation.
- Scalable for various industries including manufacturing, warehouses, pharmaceutical storage, server rooms, and smart homes.

---

## 🏛️ Repository & Platform Structure

- **`node-mongo/`** – Main backend API service (Node.js + Express.js).  
  Handles client requests, device interactions, business logic, and MongoDB communication.  
  ➡️ [View NodeMongo README](./node-mongo/README.md)

- **`docker-compose.yml`** – Defines the multi‑container Docker application that forms the platform backbone.  
  **Services managed:** `questdb` (time‑series database), `mongodb` (primary database), `grafana` (visualisation), `telegraf` (metrics collection), plus `rabbitmq` and `emqx`.

- **`telegraf/`** – Contains the unified `telegraf.conf` used for collecting metrics from all platform components and IoT devices.

- **`scripts/`** – Organised collection of Bash scripts for server administration, backups, and service orchestration.  
  Scripts are grouped into subdirectories (e.g., `qdb/`, `git/`, `mailserver/`, `nginx/`, `npm/`, `rabbitmq/`, `startup/`).

---

## 🤖 CI/CD with GitHub Actions

This project uses a fully automated **CI/CD pipeline** built on GitHub Actions, powered by reusable workflows.

- **Centralized templates** in the [`ci-cd-templates`](https://github.com/Viaq-Platform/CI-CD-Templates) repository ensure consistency across all projects.

- **Workflow:**
  1. **Trigger** – Push to `main` or `develop`.
  2. **CI stage** – Code checkout, dependency installation, automated tests/linters, and build artifact creation.
  3. **CD stage** – Secure connection to staging/production server via SSH (keys stored in GitHub Secrets), pull latest code, install production dependencies, and restart the PM2 service (zero‑downtime).

---

## 🚀 Getting Started (Local Development Environment)

### Prerequisites

- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/) (LTS version recommended)
- [npm](https://www.npmjs.com/) (comes with Node.js)
- [Docker](https://www.docker.com/products/docker-desktop/) and Docker Compose

### Setup Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Viaq-Platform/Viaq-Backend.git
   cd Viaq-Backend
   ```

2. **Start dependent Docker services:**
   ```bash
   docker-compose up -d
   ```
   This starts MongoDB, QuestDB, Grafana, and other infrastructure containers.

3. **Set up the `node-mongo` service:**
   ```bash
   cd node-mongo
   npm install
   cp environments/.env.example environments/.env
   # Edit environments/.env with your local settings
   ```

4. **Run the API server:**
   ```bash
   npm start
   ```

5. **Access services:**
   - `node-mongo` API – `http://localhost:3500` (or as configured)
   - QuestDB Web Console – `http://localhost:9000`
   - Grafana – `http://localhost:3000`

---

## 🛠️ Management Scripts & Global Aliases

All administrative scripts are located in the `scripts/` directory, organised into subfolders. To make them globally accessible, run the **alias installer**:

```bash
sudo bash /var/www/viaq/backend/Viaq-Backend/scripts/install_scripts.sh
```

This command:
- Scans every `.sh` file inside `scripts/` and its subdirectories.
- Excludes files containing `back`, `backup`, `temp`, or `old` (case‑insensitive).
- Creates symlinks in `/usr/local/bin` so that every script becomes a **global command** (the script’s name without the `.sh` suffix).
- Also sets up shortened aliases for the healthchecker.

### Available Global Commands (Examples)

After running the installer, you can invoke the following commands from anywhere:

| Category          | Command                               | Description                                                                  |
|-------------------|---------------------------------------|------------------------------------------------------------------------------|
| **Platform start**| `startup`                             | Starts the entire VIAQ platform (Docker + PM2) – runs `startup/startup.sh`   |
| **Healthchecker** | `healthcheck` or `hlthch`             | Runs the healthcheck start script (`/var/www/healthchecker/start.sh`)        |
|                   | `healthcheck_log` or `hlthch_log`     | Shows merged, sorted logs from the healthchecker                             |
| **QuestDB**       | `qdb_backup`                          | Backs up a date range of QuestDB data                                        |
|                   | `qdb_import`                          | Imports a compressed QuestDB backup                                          |
|                   | `qdb_copy_with_progress`              | Copies QuestDB data with progress indicator                                  |
|                   | `qdb_functions`                       | Helper functions for QuestDB operations (not meant to be called directly)    |
| **Git**           | `pull_all`                            | Pulls the latest code for all repositories                                   |
| **Mailserver**    | *scripts inside `mailserver/`*        | Various mailserver utilities                                                 |
| **Nginx**         | *scripts inside `nginx/`*             | Nginx configuration helpers                                                  |
| **npm**           | *scripts inside `npm/`*               | NPM package management helpers                                               |
| **RabbitMQ**      | *scripts inside `rabbitmq/`*          | RabbitMQ administration scripts                                              |

> **Note:** The installer automatically gives each script a command name equal to the base filename (e.g., `qdb_backup.sh` becomes `qdb_backup`).  
> Short aliases (`hlthch`, `hlthch_log`) are created only for the healthchecker.

### Manual Invocation (Without Global Aliases)

If you prefer to run scripts directly without installing aliases, use the full path:

```bash
sudo bash /var/www/viaq/backend/Viaq-Backend/scripts/startup/startup.sh
sudo bash /var/www/healthchecker/start.sh
```

---

## 📜 License

This project is proprietary and confidential. All rights reserved.
