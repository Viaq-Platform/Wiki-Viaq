# Git Bundle: Transferring and Replacing a Branch from an Offline Server

This document explains how to use `git bundle` to transfer a repository from a server without internet access and then **replace a remote branch** on GitHub (or any Git remote) with the exact content of the bundle.

---

## 📁 Folder Structure

### On the offline server (no international internet)
Create a directory to store bundle files:

```bash
sudo mkdir -p /var/www/tools/files/git.bundle
```

### On the online machine (e.g., local PC with VPN or WSL)
The bundle files will be transferred here. Use the same directory structure if convenient:

```bash
sudo mkdir -p /var/www/tools/files/git.bundle
```

---

## 🚀 Step-by-Step: Create Bundle on Offline Server

1. Navigate to the repository and create a bundle containing all branches:

```bash
cd /path/to/your/repo
REPO_NAME=$(basename "$PWD")
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")
BUNDLE_FILE="/var/www/tools/files/git.bundle/${REPO_NAME}-${TIMESTAMP}.bundle"

git bundle create "$BUNDLE_FILE" --all
```

2. Transfer the bundle file to the online machine (SCP, USB, etc.)

---

## 🔄 On the Online Machine (WSL / Linux)

### 1. Add the bundle as a temporary remote

```bash
cd /path/to/local/repo   # the same repository already cloned
git remote remove bundle 2>/dev/null
git remote add bundle /var/www/tools/files/git.bundle/Viaq-Backend-2026-05-31-06-33.bundle
```

### 2. Fetch all refs from the bundle

```bash
git fetch bundle
```

### 3. List branches available in the bundle

```bash
git branch -r
```

You will see something like `bundle/main`, `bundle/feat-change-access-limit`, etc.

### 4. Replace your local branch with the bundle’s branch (hard reset)

**Warning:** This will overwrite your local branch history.

```bash
git checkout feat-change-access-limit   # or your target branch
git reset --hard bundle/feat-change-access-limit
```

If the bundle branch has a different name, adjust accordingly:

```bash
git reset --hard bundle/main
```

### 5. Force-push the updated branch to the remote origin

```bash
git push origin feat-change-access-limit --force
```

If you want to replace a different remote branch:

```bash
git push origin HEAD:feat-change-access-limit --force
```

### 6. (Optional) Remove the temporary remote

```bash
git remote remove bundle
```

---

## 🧩 Handling Divergent Histories

If `git fetch bundle` complains about unrelated histories, you may need to allow merging (but with `reset --hard` it's usually not needed). In case you want to merge instead of replace:

```bash
git merge bundle/feat-change-access-limit --allow-unrelated-histories
```

But for a **complete replacement**, `reset --hard` is the correct tool.

---

## 🔁 Automation Script (for the online machine)

You can create a small script to replace a branch from a bundle:

```bash
#!/bin/bash
# replace-from-bundle.sh <bundle-file> <branch-name>

BUNDLE_FILE="$1"
BRANCH="$2"
REPO_DIR="/var/www/viaq/backend/Viaq-Backend"

cd "$REPO_DIR" || exit 1
git remote remove bundle 2>/dev/null
git remote add bundle "$BUNDLE_FILE"
git fetch bundle
git checkout "$BRANCH"
git reset --hard "bundle/$BRANCH"
git push origin "$BRANCH" --force
git remote remove bundle
```

Usage:

```bash
chmod +x replace-from-bundle.sh
./replace-from-bundle.sh /var/www/tools/files/git.bundle/Viaq-Backend-2026-05-31-06-33.bundle feat-change-access-limit
```

---

## 📌 Summary of Commands for Replacement

| Step | Command |
|------|---------|
| Add bundle remote | `git remote add bundle /path/to/bundle.bundle` |
| Fetch from bundle | `git fetch bundle` |
| List bundle branches | `git branch -r` |
| Hard reset local branch | `git reset --hard bundle/<branch>` |
| Force push to origin | `git push origin <branch> --force` |
| Remove bundle remote | `git remote remove bundle` |

### Summary Git Command
```bash
REPO_NAME=$(basename "$PWD")
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")
BUNDLE_FILE="/var/www/tools/files/git.bundle/${REPO_NAME}-${TIMESTAMP}.bundle"
git bundle create "$BUNDLE_FILE" --all
```

```
git remote add bundle /var/www/tools/files/git.bundle/...
```

```
git fetch bundle
git reset --hard bundle/main
git merge bundle/main main
git push origin bundle/main:main --force
```


---

## ⚠️ Important Notes

- `git reset --hard` discards **all** local changes on that branch. Stash them first if needed.
- `--force` overwrites the remote branch history. Use with caution if others are working on the same branch.
- Always verify that the bundle file contains the correct branch before resetting.

---

## 📚 See Also

- [Git Bundle Official Documentation](https://git-scm.com/docs/git-bundle)
- [Force Push Best Practices](https://git-scm.com/docs/git-push#Documentation/git-push.txt---force)

---

*Last updated: May 2026 – DevOps Team*
