---
name: gbif-occ
description: Download species occurrence records from GBIF at scale via the asynchronous Occurrence Download API, resolve any taxon group (including paraphyletic groups like "fish" that are not a single backbone node) into a complete taxonKey set, verify taxonomic full-coverage (no missing orders/classes, no record-bearing escapees), optionally filter fish to freshwater using FishBase habitat traits, and visualize the downloaded data (spatial density map on a standards-compliant China basemap + dataset overview panels). Ships a one-command flagship preset (China mainland + Hong Kong/Macau/Taiwan freshwater fish). Use when the user needs to download GBIF occurrence data, build a species checklist/occurrence dataset for a country/region or taxon, prepare SDM/niche-modelling inputs, resolve taxonKeys, audit taxonomic coverage of a GBIF query, visualize occurrence data, or mentions GBIF、物种分布数据、出现记录、鱼类数据下载、淡水鱼、taxonKey、DwC-A、数据可视化.
---

# gbif-occ — GBIF Occurrence Downloader

A reusable R pipeline that turns "I want all records of *these taxa* in *this
region*" into a clean, citable, and *visualized* occurrence dataset — distilled
from a production run that downloaded every freshwater fish record across China
(mainland + Hong Kong, Macau, Taiwan).

It solves three problems a naive `occ_search()` does not:

1. **Complete taxon resolution.** Many groups are **not a single backbone node**.
   "Fish" is paraphyletic — GBIF hangs the ray-finned orders directly under
   Chordata with no unifying class. This skill enumerates the right set of
   orders/classes into a `taxonKey` list.
2. **Full-coverage verification.** It audits, from the GBIF backbone top-down,
   that no target order/class was missed and no record-bearing family/genus
   escaped the key set (excluding fossils).
3. **Scale + citation.** It uses the **asynchronous Occurrence Download API**
   (whole-dataset export, not the 100k `occ_search` cap), waits for the archive,
   unzips it, and stores the citable **DOI**.

It then **shows you the data**: a spatial density map (on a standards-compliant
China basemap) and a dataset-overview panel (top species, records by region, top
orders, sampling over time).

Single engine: **R** (`rgbif`, `data.table`; `rfishbase` for the optional fish
filter; `ggplot2`/`patchwork`/`sf` for visualization), reusing the exact logic
that was validated end-to-end.

## Requirements

- R with packages: `rgbif`, `data.table` (core). Optional:
  `rfishbase` (for `filter_habitat.R`); `ggplot2`, `patchwork`, `scales`,
  `viridisLite`, `hexbin`, `sf` (for `visualize.R`; `maps` only as a fallback
  basemap when `sf`/shapefiles are unavailable).
  Install: `install.packages(c("rgbif","data.table","rfishbase","ggplot2","patchwork","scales","viridisLite","hexbin","sf","maps"))`
- A free GBIF account for downloads (resolve/verify/visualize steps need none).
  Provide credentials via environment variables or a `.env` file in the working dir:
  ```
  GBIF_USER=your_user
  GBIF_PWD=your_password
  GBIF_EMAIL=you@example.com
  ```
  Register at https://www.gbif.org/user/profile. Credentials are read only from
  the environment and never written to any output or log.

## Quick start — flagship preset

Reproduce the whole China-freshwater-fish run with one command:

```bash
Rscript skills/gbif-occ/scripts/run_preset.R \
    --preset china_freshwater_fish --out gbif_out
```

This resolves fish taxonKeys → verifies coverage → submits & fetches the
download → filters to freshwater → renders figures. Outputs land under `gbif_out/`:

```
gbif_out/
├── raw/         download_key.txt · <key>.zip (DwC-A) · CITATION.txt (DOI)
├── interim/     occurrence.txt (unzipped)
├── processed/   occurrences_freshwater.csv · species_summary.csv
├── reference/   taxon_keys.csv · fishbase_habitat.csv
├── figures/     *_map.png · *_summary.png · *_habitat.png
└── logs/        coverage.log
```

## Step-by-step (any taxon, any region)

Each script is standalone with consistent `--flag value` CLI. Run only what you need.

```bash
cd skills/gbif-occ/scripts

# 1) Resolve taxa -> taxonKey list (no account needed)
Rscript resolve_keys.R --preset fish --out keys.csv          # fish (paraphyletic)
Rscript resolve_keys.R --taxon "Odonata" --out keys.csv       # a single clade
Rscript resolve_keys.R --under 44 --rank ORDER,CLASS --out keys.csv  # enumerate children

# 2) (optional) Verify taxonomic full coverage (no account needed)
Rscript verify_coverage.R --keys-file keys.csv --parent 44 \
    --child-ranks ORDER,CLASS --region CN,HK,MO,TW --out logs/coverage.log

# 3) Submit + wait + fetch + unzip + save DOI (needs GBIF account)
Rscript download.R --keys-file keys.csv --region CN,HK,MO,TW \
    --has-coordinate true --out gbif_out

# 4) (optional, fish only) Drop pure-marine species via FishBase
Rscript filter_habitat.R --occ gbif_out/interim/occurrence.txt --out gbif_out

# 5) (optional) Visualize the downloaded data (no account needed)
Rscript visualize.R --occ gbif_out/processed/occurrences_freshwater.csv \
    --out gbif_out/figures/china_fish --title "China Freshwater Fish (GBIF)" \
    --habitat gbif_out/reference/fishbase_habitat.csv
```

## Scripts & key flags

| Script | Purpose | Key flags |
|--------|---------|-----------|
| `resolve_keys.R` | Taxa → `taxonKey` CSV | `--preset fish` · `--taxon "A,B"` · `--under <key/name> --rank ORDER,CLASS` · `--out` |
| `verify_coverage.R` | Audit full coverage & escapees | `--keys-file` · `--parent` · `--child-ranks` · `--region` · `--exclude-fossil` |
| `download.R` | Async submit/wait/fetch/unzip + DOI | `--keys-file`/`--taxon-keys` · `--region` · `--wkt` · `--year a,b` · `--basis` · `--has-coordinate` · `--keep-issue` · `--format DWCA\|SIMPLE_CSV` · `--no-wait` · `--out` |
| `filter_habitat.R` | FishBase freshwater filter (fish) | `--occ` · `--out` · `--species-col` · `--drop-unranked` |
| `visualize.R` | Display/analyze downloaded data | `--occ` · `--out` (prefix) · `--title` · `--top` · `--habitat` · `--assets` · `--no-inset` |
| `run_preset.R` | Run a full preset end-to-end | `--preset` · `--out` · `--no-wait` |
| `common.R` | Shared helpers (sourced, not run) | — |

Download predicates combine with **AND**. `--has-coordinate true` keeps only
georeferenced records and (unless `--keep-issue`) drops `hasGeospatialIssue`
records — the standard SDM setup.

## Visualization

`visualize.R` reads either the GBIF `occurrence.txt` (tab/unquoted) or the
processed `.csv` (auto-detected) and renders 600-dpi PNGs:

- **`<prefix>_map.png`** — spatial density of occurrences (hexagonal binning,
  log record count) over a **standards-compliant China basemap**: province
  boundaries + the South China Sea **nine-dash line**, with a South China Sea
  **inset** in the bottom-right corner. The dataset at a glance.
- **`<prefix>_summary.png`** — a 4-panel overview: Top-N species, records by
  region, Top-N orders, and records by year.
- **`<prefix>_habitat.png`** *(only with `--habitat`)* — FishBase
  freshwater/marine decision breakdown for the classified species.

The basemap shapefiles (`china.shp`, `dashline.shp`, WGS-84) are bundled under
`assets/china/`. Override the location with `--assets <dir>`, or `--no-inset` to
drop the South China Sea inset. If `sf` or the shapefiles are unavailable, the
map falls back to a plain `maps` world outline auto-cropped to the data. The
palette and theme are self-contained (no dependency on other skills).

See `examples/figures/` for the rendered China-freshwater-fish output.

## Presets

`presets/china_freshwater_fish.R` is the worked example. To make your own
(e.g. a province's amphibians), copy it and edit the `PRESET` list — taxon
resolution mode, region, predicates, whether to verify coverage, whether to run
the FishBase filter, whether to visualize — then `run_preset.R --preset <yourfile>.R`.

## Notes & gotchas

- **DwC-A tables are tab-separated, unquoted** — read with `sep="\t", quote=""`
  (handled by `common.R::read_gbif_table`). `fwrite` output is standard quoted
  CSV; read it back with the default quote. See `references/gbif_notes.md`.
- **Async downloads queue** (PREPARING → RUNNING → SUCCEEDED); minutes to tens of
  minutes for large requests is normal. Use `--no-wait` to submit and fetch later.
- **Always cite the DOI** (saved to `raw/CITATION.txt`) in academic use.
- The FishBase filter is **fish-specific** — set `filter_habitat = FALSE` (or skip
  `filter_habitat.R`) for non-fish taxa.
- The visualization is generic across taxa/regions; only `_habitat.png` is
  fish-specific (needs a FishBase-derived `--habitat` table). The bundled basemap
  is China-centric — for other regions pass `--assets <dir>` with your own
  `china.shp`/`dashline.shp` equivalents, or rely on the `maps` fallback.

## Testing

```bash
Rscript skills/gbif-occ/tests/test_smoke.R   # RESULT: PASS
```

Offline checks (CLI parsing, tab/quoted reading, dir layout, fish constants, and
`visualize.R` rendering the compliant basemap from the bundled sample) run
anywhere; one online check resolves fish keys against the GBIF API and reports
`SKIP` if the network is unavailable. No GBIF account required.

## Examples

`examples/` holds real artifacts from the China-freshwater-fish run:

- `example_fish_taxon_keys.csv` — 52 resolved keys (46 orders + 6 fish classes)
- `example_CITATION.txt` — the citable DOI record
- `example_occurrences_sample.csv` — an 8,000-row sample (8 columns) of the real
  occurrences, small enough to ship and enough to reproduce the figures:
  `Rscript scripts/visualize.R --occ examples/example_occurrences_sample.csv --out /tmp/demo`
- `figures/` — the rendered `*_map.png` (compliant China basemap + nine-dash line
  + SCS inset), `*_summary.png`, `*_habitat.png` from the full 166k-record dataset.
