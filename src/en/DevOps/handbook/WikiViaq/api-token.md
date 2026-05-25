# WikiViaq API Token Guide

The Wiki.js API token is used by the automation scripts to create groups, manage page rules, and trigger imports. This document explains how to generate, store, and use the token.

## How to Generate a Token

1. Log in to your wiki as an **administrator**.
2. Go to **Administration → API Access**.
3. Click **Create Token**.
4. Give the token a descriptive name (e.g., `automation-script` or `setup-token`).
5. Grant the following permissions:
   - `System: Access`
   - `Groups: Manage`
   - `Storage: Manage` (required for importing content)
6. Click **Create**.
7. **Copy the generated token string immediately** – it will not be shown again.

## Where to Store the Token

The token must be placed in the `.env` file located at `environments/.env` inside the WikiViaq project root.

Example content of `environments/.env`:

```dotenv
WIKI_URL="https://wiki.viaq.ir"
API_TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
SOURCE_DIR="/var/www/Wiki-Viaq/src/en"
GLOBAL_PERMISSIONS='["read:pages", "write:pages"]'
```

## Scripts That Use the Token

The following automation scripts read the token from the `.env` file and use it to call the Wiki.js GraphQL API:

| Script | Purpose |
|--------|---------|
| `script/setup_groups.sh` | Creates groups and page rules based on folder structure. |
| `script/create_group_rules.sh` | Helper that adds a single page rule to an existing group. |
| `script/import_local_files.sh` | Triggers a full import from the Local File System storage. |
| `script/startup.sh` | Master script that runs `setup_groups.sh` and `import_local_files.sh`. |

## Testing the Token

To verify that the token works correctly, run the following command from your server:

```bash
cd /var/www/Wiki-Viaq
source environments/.env
curl -s -L -k -X POST https://wiki.viaq.ir/graphql \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ groups { list { id name } } }"}' | jq '.data.groups.list[] | {id, name}'
```

If the token is valid, you will see a list of existing groups (e.g., Administrators, Developers, Guests). If you get an error like `Forbidden`, the token has expired or lacks sufficient permissions.

## Token Expiration & Renewal

- By default, Wiki.js API tokens **do not expire**.
- If you lose the token or suspect it has been compromised, you can:
  1. Delete the old token in **Administration → API Access**.
  2. Generate a new token.
  3. Update `environments/.env` with the new token.
- There is no automatic renewal mechanism – manual rotation is recommended every 6–12 months.

## Security Best Practices

- **Never commit the `.env` file** to version control. It is already listed in `.gitignore`.
- Use a **dedicated token** for automation; do not reuse personal access tokens.
- **Limit token permissions** to only what the scripts need (System + Groups + Storage).
- **Regenerate tokens periodically** and after personnel changes.
- **Avoid using the token in plaintext** in logs or command history. The scripts already handle it via the `.env` file.

## Troubleshooting

| Issue | Likely cause | Solution |
|-------|--------------|----------|
| `Forbidden` error | Token expired or wrong permissions | Delete the token, create a new one with full permissions, update `.env`. |
| `jq: command not found` | `jq` not installed | Run `sudo apt install jq -y` (Ubuntu/Debian). |
| `Connection refused` | Wiki URL incorrect | Check `WIKI_URL` in `.env` – use `https` and correct domain. |
| Token works for `curl` but not for scripts | Environment variables not loaded | Ensure the script sources `.env` (the provided scripts do). |

---

*For more details, refer to the [Wiki.js API documentation](https://docs.requarks.io/api).*
