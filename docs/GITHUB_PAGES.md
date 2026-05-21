# Publishing to GitHub Pages

## 1. Create the repository

```bash
cd colombia-bo-geographic-analysis
git init
git add .
git commit -m "Add Colombia BO geographic analysis workflow and docs site"
git remote add origin https://github.com/<org>/<repo>.git
git push -u origin main
```

**Do not** add `data/*.xlsx` — `.gitignore` blocks it.

## 2. Enable Pages

1. GitHub → **Settings** → **Pages**
2. **Source:** Deploy from branch
3. **Branch:** `main` · **Folder:** `/docs`
4. Save — site URL: `https://<org>.github.io/<repo>/`

## 3. Fix doc links on the landing page

Edit `docs/index.html` and replace `YOUR_ORG/YOUR_REPO` in the documentation links with your repo path.

## 4. Verify locally (optional)

```powershell
cd docs
python -m http.server 8080
# Open http://localhost:8080/
```

## 5. What gets published

| URL path | File |
|----------|------|
| `/` | `docs/index.html` |
| `/map.html` | Interactive Leaflet map |
| `/report-full-market.html` | Full 125-BO report |
| `/report-top8-operators.html` | Top-8 scoped report |

Markdown files (`WORKFLOW.md`, etc.) are readable on GitHub but not served as Pages unless you add Jekyll — link to them from `index.html` as above.

## 6. Private vs public

If the narrative contains sensitive commercial detail, use a **private** repo with Pages restricted to org members, or strip numeric tables before publishing.
