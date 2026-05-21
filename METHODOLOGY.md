# Methodology — Colombia BO Geographic Analysis

Formal definitions for metrics, cleaning rules, and cohorts used in the May 2026 analysis.

---

## Comparison window

- **Months:** March, April, May (inclusive)
- **Years:** 2025 (baseline) vs 2026 (current)
- **Rationale:** Peak dry-season intercity travel before school holidays; aligns with internal pivot columns.

---

## Transaction grain

| Grain | Definition | Preferred for |
|-------|------------|---------------|
| **Operator-level** | Sum of BO monthly txns from Sheet2 after ID reconciliation | **Headline market YoY** |
| **Route-level** | Sum of route row txns from Sheet1 after artifact removal | Corridor / department rankings |
| **Department-level** | Origin department from route label | Choropleth map coloring |
| **Corridor-level** | Ordered pair of departments (from → to) | Arc map lines, disruption attribution |

---

## Route label parsing

Pattern: `CityA (DeptA)-CityB (DeptB)`

- Extract **DeptA** as origin department code (3–6 char abbreviations: `Ant`, `D.C`, `N.San`, `Guaj`, …).
- Corridor key: `fromDept|toDept` (directional).

---

## Operator ID reconciliation

When a BO migrates platform IDs between years:

1. **Sheet1:** Old ID rows may be 2025-only; new ID rows 2026-only.
2. **Sheet2 rows 10–17:** Original top-8 pivot — use column **M** (2025 total), **I** (2026 total).
3. **Exclude** legacy IDs from operator rollups when new IDs exist for the same brand.

Documented migrations:

| Operator | 2025 ID | 2026 ID |
|----------|---------|---------|
| Bolivariano | 20982 | 31571 |
| Arauca | 23180 | 33571 |
| Rápido Ochoa | 15612 | 33594 |

---

## Pivot artifact detection (Sheet1)

**Problem:** After pivot refresh, some new-operator rows had 2025 month columns **copied from 2026 March** → `D = F = H = J`.

**Detection rule:**

```
IF D == F == H AND D > 0 THEN flag artifact → set 2025 total T25 = 0 (exclude from YoY)
```

**Impact:** 1,679 of 4,105 rows removed → **2,448** clean unique routes.

---

## YoY formulas

**Route or department:**

```
YoY% = (T26 - T25) / T25 * 100
```

where `T25 = Mar25 + Apr25 + May25`, `T26 = Mar26 + Apr26 + May26`.

**Market headline (operator-level):**

```
YoY% = (Sum_I_2026 - Sum_M_2025) / Sum_M_2025 * 100
```

Full-market result: **−0.9%** (116,482 → 115,481).

**Route-level market** (includes exited operators): **−2.5%** (123,916 → 120,849).

The ~6% gap (~7,434 txns) = routes from operators active in 2025 but not in 2026.

---

## Regional taxonomy

Analytic regions (used in narrative, not official DANE divisions):

| Region | Departments (examples) |
|--------|-------------------------|
| Bogotá Capital | Bogotá D.C. |
| Andean | Antioquia, Tolima, Santander, Boyacá, Cundinamarca |
| Eje Cafetero | Risaralda, Caldas, Quindío |
| Caribbean | Magdalena, Atlántico, Bolívar, Cesar, Sucre, Córdoba, La Guajira |
| Pacific | Valle, Cauca, Chocó, Nariño |
| Llanos East | Meta, Casanare, Arauca |
| Amazon | Caquetá, Putumayo |
| Andean NE Border | Norte de Santander |

---

## Top 8 operators (volume-based, initial slice)

Bolivariano, Copetran, Expreso Brasilia, Flota Magdalena, Flota Ospina, Palmira, Rápido Ochoa, Rápido El Carmen.

**Note:** Later Excel exports include **Coomotor**, **Expreso Palmira**, **Berlinas del Fonce**, etc., in the expanded 125-operator market. Top-8-only slices **under-count** long-tail recovery corridors (Nariño, Chocó).

---

## Disruption event taxonomy

| Type | Examples in model |
|------|-------------------|
| `natural` | La Niña floods, Copacabana landslides |
| `security` | ELN/FARC-EMC, Catatumbo, Meta conflict |
| `policy` | Autopistas del Café toll / concession |
| `migration` | Venezuelan border transit via Cúcuta |
| `both` | Caribbean blockade + floods |
| `indirect` | Bypass corridors benefiting from Bogotá suppression |

Events are **linked to corridors narratively**; not statistically tested.

---

## Map encoding

| Layer | Encoding |
|-------|----------|
| Departments | Choropleth: red → green by origin YoY% |
| Corridors | Arc width ∝ volume; color green/red; dashed if decline |
| Disruptions | Lat/lon pins with typed badges |

GeoJSON: Colombia department boundaries (public CDN). Fallback: sized circles at dept centroids if GeoJSON fails.

---

## Top-8 vs full-market sensitivity (key deltas)

| Geography | Top-8 YoY | Full-market YoY | Δ (pp) |
|-----------|-----------|-----------------|--------|
| Nariño | −35.6% | +50.1% | +85.7 |
| Chocó | −54.1% | +24.4% | +78.5 |
| Quindío | −0.7% | −25.7% | −25.0 |
| Medellín ↔ Armenia corridor | N/A (hidden) | −64.0% | — |

---

## Data lineage

```
Colombia Top 8 BOs.xlsx (internal)
  → ZIP/XML parse (PowerShell)
  → In-memory aggregates
  → HTML reports + embedded JS constants in map
```

No automated refresh pipeline exists in-repo yet; re-run parse script when pivot updates.
