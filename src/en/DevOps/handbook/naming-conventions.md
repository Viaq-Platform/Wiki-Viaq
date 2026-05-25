# Naming Conventions

Consistent naming reduces confusion, eases automation, and improves maintainability. This document defines the mandatory naming rules for all Viaq‑owned digital assets.

## 1. Repositories

**Format:** `{team}-{project-name}`

- Use **lowercase** letters only.
- Use **hyphens** (`-`) as word separators.
- Keep the name short but descriptive.

**Examples:**
- `backend-user-api`
- `frontend-admin-dashboard`
- `devops-terraform-modules`

## 2. Branches

| Branch type | Naming pattern | Example |
|-------------|----------------|---------|
| Main branch | `main` | `main` |
| Feature | `feature/{short-description}` | `feature/oauth2-integration` |
| Bugfix | `fix/{issue-id}-{description}` | `fix/123-login-timeout` |
| Release | `release/{version}` | `release/v2.1.0` |
| Hotfix | `hotfix/{version}-{description}` | `hotfix/v2.1.1-cve-patch` |

## 3. Tags / Releases

**Format:** `v{major}.{minor}.{patch}`

- Follow **semantic versioning** (SemVer).
- Optional pre‑release labels: `-alpha`, `-beta`, `-rc`.

**Examples:**
- `v1.2.3`
- `v2.0.0-beta`
- `v3.0.0-rc1`

## 4. Docker Images

**Format:** `viaq/{service-name}:{tag}`

- `service-name` – lowercase, hyphenated.
- `tag` – either `latest`, a version number (`v1.2.3`), or a short commit hash (`a1b2c3d`).

**Examples:**
- `viaq/user-service:v1.2.3`
- `viaq/nginx-proxy:latest`
- `viaq/worker:7f8e9d0`

## 5. Environment Variables

- Use **UPPER_SNAKE_CASE**.
- Prefix with the service or component name to avoid clashes.

**Examples:**
- `USER_SERVICE_DB_HOST`
- `FRONTEND_API_BASE_URL`
- `LOG_LEVEL=debug`

## 6. Kubernetes Resources

- Resource names must be **lowercase** and **hyphenated**.
- Include the component name and its role.

**Examples:**
- `user-api-deployment`
- `postgresql-persistent-volume-claim`
- `nginx-ingress`

## 7. Files & Directories in Repositories

| Type | Convention |
|------|------------|
| Configuration files | `.env.example`, `config.yml`, `docker-compose.yml` |
| Scripts | `snake_case.sh` or `kebab-case` (be consistent per repo) |
| Documentation | `README.md`, `CONTRIBUTING.md`, `LICENSE` |
| Tests | `*.test.js`, `*_test.go`, or `test_*.py` |

## 8. Exceptions

Any deviation from these conventions must:
- Be documented in the project’s `README.md`.
- Receive written approval from the DevOps lead.

---

*This document is mandatory for all new projects and services. Non‑compliant assets will be flagged for refactoring.*
