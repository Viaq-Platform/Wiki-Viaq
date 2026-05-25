# Documentation Guide

All Viaq documentation must be written in Markdown and placed in the appropriate folder inside `/var/www/Wiki-Viaq/src/`. This guide explains how to write, format, and manage documentation effectively.

## 1. Where to Place Files

| Content type | Destination path |
|--------------|------------------|
| General standards & handbooks | `src/en/DevOps/handbook/` |
| Team‑specific guides | `src/en/{team}/` (e.g., `src/en/Backend/`) |
| WikiViaq internal documentation | `src/en/DevOps/handbook/WikiViaq/` |
| Persian translations | `src/fa/` (mirror structure) |

## 2. Markdown Best Practices

- Use meaningful headings (`#`, `##`, `###`). Do not skip levels.
- Keep line length ≤ 120 characters.
- Use backticks for inline code.
- For multi‑line code blocks, use ````` instead of triple backticks.
- Use relative links to other wiki pages (e.g., `[link](../handbook/naming-conventions.md)`).

## 3. Adding Images

Store images in the `assets/` folder at the root of `src/`. Reference them with a relative path:

```markdown
![architecture diagram](../../assets/diagram.png)
```

## 4. Using `include_rules.json`

If a folder represents a group that needs cross‑folder access, place an `include_rules.json` file inside it. Example:

```json
["Backend", "DevOps", "Frontend"]
```

The script `script/setup_groups.sh` automatically creates page rules based on this file.

## 5. Updating Documentation

After adding or modifying any `.md` file, run the import script:

```bash
sudo bash /var/www/Wiki-Viaq/script/import_local_files.sh
```

This synchronises your local Markdown files with the Wiki.js database.

## 6. Style Guide

- **Tone**: Imperative and concise (“Install the package” not “You should install the package”).
- **Titles**: Use sentence case (capitalise first word and proper nouns) consistently.
- **Lists**: Use numbered lists for sequential steps, bullet lists for non‑sequential items.

## 7. Review Process

All documentation changes must be reviewed by at least one peer. Use GitHub pull requests for changes to the [WikiViaq repository](https://github.com/Viaq-Platform/Wiki-Viaq).

## 8. Examples of Good Documentation

- **Procedures**: Step‑by‑step with clear commands.
- **Conceptual**: Explain the “why” before the “how”.
- **Reference**: Tables, enums, and bullet lists.

## 9. Prohibited Practices

- Do not commit sensitive information (passwords, tokens) – use `.env` files.
- Do not use triple backticks in any `.md` file – always use ````` as the delimiter.
- Do not skip the review process for changes to the `handbook/` directory.

---

*For questions, contact the DevOps team on Slack `#documentation`.*
