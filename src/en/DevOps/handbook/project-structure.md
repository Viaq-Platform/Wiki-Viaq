# Standard Project Structure

A predictable project layout simplifies navigation, onboarding, and automation. All Viaq projects must follow the structures defined below.

## 1. Backend Project (Node.js / Go / Python)

```
project-root/
├── .gitignore
├── README.md
├── LICENSE
├── Makefile (or Taskfile)
├── go.mod / requirements.txt / package.json
├── cmd/ (for Go) or src/
│   ├── main/
│   ├── api/
│   └── utils/
├── internal/ (private packages)
├── pkg/ (public libraries)
├── tests/
│   ├── unit/
│   └── integration/
├── configs/
│   ├── development.env
│   └── production.env
├── scripts/
│   ├── build.sh
│   └── deploy.sh
└── docs/
    └── api.md
```

## 2. Frontend Project (React / Vue / Angular)

```
project-root/
├── .gitignore
├── README.md
├── package.json
├── public/
│   └── index.html
├── src/
│   ├── components/
│   ├── pages/
│   ├── services/
│   ├── styles/
│   ├── utils/
│   ├── App.jsx (or .vue/.ts)
│   └── index.js
├── tests/
│   ├── unit/
│   └── e2e/
├── .env
├── .env.example
└── vite.config.js / webpack.config.js
```

## 3. Dockerized Service

Every service that runs in a container must include:

```
service/
├── Dockerfile
├── .dockerignore
├── docker-compose.yml (for local development)
└── docker/
    ├── dev/
    │   └── Dockerfile.dev
    └── prod/
        └── nginx.conf (if applicable)
```

## 4. Infrastructure as Code (Terraform)

```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf (provider versions)
├── modules/
│   ├── networking/
│   ├── compute/
│   └── database/
└── environments/
    ├── dev/
    │   └── terraform.tfvars
    ├── staging/
    └── prod/
```

## 5. CI/CD Pipelines

Place pipeline definitions in:

- GitHub Actions: `.github/workflows/{stage}-{job}.yml`
- GitLab CI: `.gitlab-ci.yml` (or split into `/.gitlab/ci/`)

Example GitHub Actions structure:

```
.github/
└── workflows/
    ├── ci-test.yml
    ├── cd-staging.yml
    └── cd-prod.yml
```

## 6. Documentation Directory

Every repository must contain a `docs/` folder with at least:

```
docs/
├── architecture.md
├── api.md (if applicable)
└── development.md (setup instructions)
```

## 7. Exceptions

If a project cannot follow this exact structure, the `README.md` must:
- Clearly explain the deviation.
- Provide a map of the actual layout.
- Justify why the standard structure is not suitable.

---

*All new repositories must comply with this structure. Existing repositories should be migrated during major version upgrades.*
