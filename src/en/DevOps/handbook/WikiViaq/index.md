# WikiViaq Internal Documentation

WikiViaq is the platform behind this wiki. It is built on **Wiki.js** (v2.5.314) and deployed with Docker Compose. This section provides architecture, setup instructions, and automation details for maintainers.

## Overview

- **Repository**: [Viaq-Platform/Wiki-Viaq](https://github.com/Viaq-Platform/Wiki-Viaq)
- **Server location**: `/var/www/Wiki-Viaq`
- **Primary URL**: [https://wiki.viaq.ir](https://wiki.viaq.ir)
- **Stack**: PostgreSQL + Wiki.js + Nginx (reverse proxy)

## Key Components

| Component | Path | Description |
|-----------|------|-------------|
| Docker Compose | `docker-compose.yml` | Defines `wikijs-db` and `wikijs-app` services. |
| Configuration | `config.yml` | Wiki.js core settings (offline mode, port 3000). |
| Environment | `environments/.env` | Contains `WIKI_URL`, `API_TOKEN`, `SOURCE_DIR`. |
| Automation scripts | `script/` | `setup_groups.sh`, `import_local_files.sh`, etc. |
| Content | `src/en/` and `src/fa/` | Markdown files organised by team and language. |

## Architecture Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Nginx (Host)  │────▶│  Wiki.js App    │────▶│   PostgreSQL    │
│   :80 / :443    │     │  Container      │     │   Container     │
│   (reverse      │     │  :3000          │     │   :5432         │
│    proxy)       │     └─────────────────┘     └─────────────────┘
└─────────────────┘             │
                               │
                               ▼
                        ┌─────────────────┐
                        │  Local File     │
                        │  System Storage │
                        │  /wiki-data     │
                        │  (mounted to    │
                        │   ./src)        │
                        └─────────────────┘
```

## How Groups & Rules Are Created

- The script `setup_groups.sh` reads every folder under `src/en/` and creates a corresponding group in Wiki.js.
- Inside each folder, an optional `include_rules.json` can define additional access to other folders (e.g., `["Backend", "DevOps"]`).
- The script adds one page rule per target using **regex matching** (e.g., path `DevOps` matches any URL containing `DevOps`).

## Storage & Import

- Wiki.js is configured to use **Local File System** storage with path `/wiki-data` (mounted to `./src` on the host).
- The script `import_local_files.sh` triggers a full import, converting all `.md` files into wiki pages.

## Permissions Model

- **Administrators**: full access to everything (via `["all"]` rule).
- **Developers**: access to `Backend`, `DevOps`, `Frontend`, `UI-UX` (configurable via `include_rules.json`).
- **Guest**: no access by default; administrator must add page rules manually for public pages.
- Other groups (Backend, DevOps, etc.) have read/write access only to their own folder.

## Automation Scripts

| Script | Purpose |
|--------|---------|
| `setup_groups.sh` | Creates groups and page rules based on folder structure and `include_rules.json`. |
| `create_group_rules.sh` | Helper called by `setup_groups.sh`; adds one rule to an existing group. |
| `import_local_files.sh` | Triggers a full import of all Markdown files from `src/en/` into the wiki. |
| `startup.sh` | Master script – runs `setup_groups.sh` then `import_local_files.sh`. |

## Next Steps

- See [Setup Guide](setup.md) for initial installation from scratch.
- See [API Token Guide](api-token.md) for generating and using API tokens.

---

*Maintained by the DevOps team. Last update: May 2026*
