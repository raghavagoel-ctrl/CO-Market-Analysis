# Colombia BO Geographic Analysis

YoY performance of Colombia intercity bus operators (initially **top 8**, later **full market / 125 operators**), with geographic cohorts, corridor attribution, disruption context, and an interactive Leaflet map.

Built in a Claude CLI session (May 2026). This repo packages the **workflow**, **methodology**, and **publishable HTML** so others can extend the analysis or wire it into Cursor/GitHub Pages.

## Quick links (local)

| Artifact | Path |
|----------|------|
| **GitHub Pages hub** | [`docs/index.html`](docs/index.html) |
| **Interactive map** (125 BOs) | [`docs/map.html`](docs/map.html) |
| **Written report — full market** | [`docs/report-full-market.html`](docs/report-full-market.html) |
| **Written report — top 8** | [`docs/report-top8-operators.html`](docs/report-top8-operators.html) |
| **End-to-end workflow** | [`WORKFLOW.md`](WORKFLOW.md) |
| **Data rules & formulas** | [`METHODOLOGY.md`](METHODOLOGY.md) |
| **Prompt sequence (replay)** | [`PROMPTS.md`](PROMPTS.md) |

## Source data (not in repo)

Place the Excel export locally (confidential):

`C:\Raghava\LATAM\Colombia\Random Analysis\Colombia Top 8 BOs.xlsx`

The filename is legacy; the workbook was expanded to **all 125 operators**. See [`data/README.md`](data/README.md).

## GitHub repository

**https://github.com/raghavagoel-ctrl/CO-Market-Analysis**

## GitHub Pages

1. Repo: [raghavagoel-ctrl/CO-Market-Analysis](https://github.com/raghavagoel-ctrl/CO-Market-Analysis)
2. **Settings → Pages → Build and deployment → Source:** Deploy from branch `main`, folder **`/docs`**.
3. Site URL: `https://raghavagoel-ctrl.github.io/CO-Market-Analysis/` → opens `docs/index.html`.

The map loads department polygons from a public GeoJSON CDN; it needs network access in the browser.

## Session provenance

| Field | Value |
|-------|--------|
| Claude session ID | `b815d8f1-3caa-4201-b979-d90ce7233ac1` |
| Transcript | `%USERPROFILE%\.claude\projects\C--Users-raghava-goel\b815d8f1-3caa-4201-b979-d90ce7233ac1.jsonl` |
| Prompt history | `%USERPROFILE%\.claude\history.jsonl` (entries 19–31) |

## Headline results (full market, Mar–May 2025 vs 2026)

- **Market YoY:** −0.9% (116,482 → 115,481 transactions)
- **Operators:** 125 active
- **Routes (clean):** 2,448 after pivot-artifact removal
- **Top 8 only understated recovery** in Nariño (+50.1% vs −35.6% in top-8 slice) and Chocó (+24.4% vs −54.1%)

## Next steps for contributors

- Re-run parsing when the Excel pivot is refreshed (`scripts/parse_colombia_bo_xlsx.ps1` is a reference pattern).
- Parameterize comparison months (currently Mar–May).
- Automate export to CSV for Tequila cross-checks.
- Add operator-level drill-down on the map.
