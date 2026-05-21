# Data directory

## Required file (local only — do not commit)

Copy your internal export here:

```
data/Colombia Top 8 BOs.xlsx
```

Original path used in analysis:

`C:\Raghava\LATAM\Colombia\Random Analysis\Colombia Top 8 BOs.xlsx`

## Workbook structure

| Sheet | Contents |
|-------|----------|
| Sheet1 | Route-level transactions by operator and route |
| Sheet2 | Operator-level pivot summary |
| sharedStrings | Route names, operator names |

## Column mapping (Sheet1 monthly txns)

| Year | Mar | Apr | May |
|------|-----|-----|-----|
| 2025 | D | F | H |
| 2026 | J | L | N |

## Confidentiality

This dataset contains **internal redBus sales volumes**. Keep out of public git remotes. `.gitignore` blocks `*.xlsx` in this folder.

## Optional derived outputs (generated)

After running `scripts/parse_colombia_bo_xlsx.ps1`:

- `data/derived/operators_summary.csv`
- `data/derived/departments_yoy.csv`
- `data/derived/corridors_yoy.csv`

(Create `data/derived/` locally; not checked in by default.)
