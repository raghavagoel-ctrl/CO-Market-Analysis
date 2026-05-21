# Prompt sequence — replay in Cursor or Claude

Copy-paste these prompts in order when re-running the analysis with a fresh Excel export. Adjust paths to your `data/` folder.

---

## 1. Load and reconcile operators

```
The file at data/Colombia Top 8 BOs.xlsx contains route-use sales data for Colombia bus operators YoY (Mar–May 2025 vs 2026).

Match operator names across years — some operator IDs changed. Document reconciliations and compute operator-level YoY from Sheet2. Use ZIP/XML parsing if Excel is locked; copy to TEMP first.

Known ID migrations: Bolivariano 20982→31571, Arauca 23180→33571, Rápido Ochoa 15612→33594.
```

---

## 2. Geographic performance patterns

```
From that file, identify geographic patterns — which areas, routes, and departments are growing vs declining?

Aggregate by:
- Origin department (parsed from route labels like "Medellin (Ant)-Ibague (Tol)")
- Corridor pairs (dept→dept)
- Custom regions: Bogotá Capital, Andean, Eje Cafetero, Caribbean, Pacific, Llanos, Amazon

Use Sheet2 for headline operator/market YoY; use Sheet1 for corridors after artifact cleaning.
```

---

## 3. Validate headline metrics

```
Sanity-check: Bolivariano should be roughly -2% to -9% YoY, not double-digit wrong declines. Overall market YoY should be near flat (roughly -1% to +1%) for the top-8 era before full-market expansion.

If route-level totals disagree with Sheet2 by >1%, explain the gap.
```

---

## 4. Disruption attribution

```
Link the largest geographic wins and losses to natural disasters, security events, infrastructure/policy changes, and migration patterns in Colombia during Mar–May 2025–2026.

Tag each major corridor with a cause type: natural | security | policy | migration | indirect.
```

---

## 5. Interactive map

```
Build a self-contained HTML map (Leaflet) of Colombia with:
- Department choropleth by origin YoY%
- Corridor arcs (green solid = growth, red dashed = decline)
- Disruption markers (use colored badges, not emoji — Windows font issues)

Embed data as JS constants. Save to docs/map.html. Match redBus styling (#e8412a accent).
```

---

## 6. Written report

```
Produce a Word-openable HTML report (.html, Word MIME) with:
Executive summary, regional sections with biggest routes, full department table, top 8 growing/declining corridors, disruption catalog, findings, recommendations, methodology appendix.

Save as docs/report-full-market.html (or .doc if needed for Word double-click).
```

---

## 7. Full-market rerun

```
The Excel file now includes all bus operators (~125), not only top 8.

Re-run the pipeline:
- Apply pivot artifact rule: if 2025 Mar/Apr/May columns all equal 2026 Mar and >0, zero out 2025 for that row
- Update headline to operator-level -0.9% if still valid
- Add top-8 vs full-market comparison table (Nariño, Chocó, Quindío, Medellín–Armenia)
- Refresh docs/map.html embedded DATA
```

---

## 8. Enrich top-8 regional report

```
For each analytic region in the top-8 report, add:
- 2–3 sentence region description
- Table of biggest routes in that region by absolute txn volume and YoY%
```

---

## Reference: original Claude history lines

Stored in `%USERPROFILE%\.claude\history.jsonl` — session `b815d8f1-3caa-4201-b979-d90ce7233ac1`, display entries 19–31 (May 2026).
