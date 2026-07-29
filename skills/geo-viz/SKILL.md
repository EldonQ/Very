---
name: geo-viz
description: Render raster (GeoTIFF) data over a standards-compliant China basemap as publication-quality maps, with the South China Sea nine-dash-line inset, a library of Nature-grade colour-blind-friendly palettes (sequential, diverging, perceptually-uniform) the user can choose from, transparent background, and 600 dpi PNG + vector PDF export. Supports both R (terra/sf/ggplot2) and Python (rasterio/geopandas/matplotlib) engines that render identical colours. Use when the user needs to visualize gridded/raster geographic data (climate, soil, land cover, vegetation, topography, hydrology, population) on a China map, make thematic China maps, add the nine-dash line / South China Sea inset, or mentions 中国地图、栅格可视化、专题地图、南海九段线、地图出图.
---

# geo-viz — China Raster Map Rendering

Render a GeoTIFF over an authoritative China basemap into a clean, publication-ready
map. The rendering effect is distilled from a production research-visualization
pipeline:

- China boundary (`china.shp`) + **South China Sea nine-dash line** (`dashline.shp`)
- **South China Sea inset** anchored to the bottom-right corner
- **A library of Nature-grade, colour-blind-friendly palettes** you choose from
  (sequential, diverging, perceptually-uniform) — plus semantic keys by variable type
- Transparent background, clean centered title, main map + legend
- Export **600 dpi PNG (transparent)** and **vector PDF**

Two interchangeable engines are provided; pick per the user's stack:

| Engine | Script | Requires |
|--------|--------|----------|
| Python | `scripts/render_china_map.py` | `rasterio`, `geopandas`, `shapely`, `matplotlib`, `numpy` |
| R | `scripts/render_china_map.R` | `terra`, `sf`, `ggplot2`, `scales` (GDAL via `sf`) |

Both share the **same CLI flags** and produce visually consistent output.

## When to use which engine

- Follow the user's existing project language. If a project already renders figures in R,
  use the R script; for a Python data pipeline, use the Python script.
- If unspecified, default to **Python** (fewer heavy install steps on most machines).
- Do not mix engines for one figure set — output should be internally consistent.

## Quick start

Continuous field (e.g. temperature), clamp colour range to the 2–98 percentile:

```bash
# Python
python scripts/render_china_map.py --input data.tif --output out/temp \
    --title "Annual Mean Temperature" --legend "degC" --palette temp --clamp

# R (identical flags)
Rscript scripts/render_china_map.R --input data.tif --output out/temp \
    --title "Annual Mean Temperature" --legend "degC" --palette temp --clamp
```

Discrete land-cover raster (CLCD 9-class):

```bash
python scripts/render_china_map.py --input landcover.tif --output out/lc \
    --mode class --classes clcd --title "Land Cover" --legend "Class"
```

Each run writes `<output>.png` and `<output>.pdf`.

## Bring your own data

This skill is **data-agnostic**: point `--input` at *any* GeoTIFF and it is reprojected,
masked to China, and rendered. It does not depend on the author's private datasets — the
rasters under `tests/` and `examples/` are only self-contained demos for illustration.

- Continuous field (climate, soil, biomass, indices…): default `--mode continuous`.
- Discrete/classified raster (land cover…): `--mode class --classes clcd|glulc6|harmonised`.
- Multi-band input: select a band with `--band N`.
- Weird nodata sentinel (e.g. `-9999`): pass `--src-nodata -9999`.

Run `--list-palettes` to see every palette, then pick one with `--palette`.

## CLI flags (both engines)

| Flag | Default | Meaning |
|------|---------|---------|
| `--input` | (required) | Source GeoTIFF (any CRS; reprojected to EPSG:4326). |
| `--output` | (required) | Output path base, without extension. |
| `--title` | "" | Map title (centered, bold). |
| `--legend` | "" | Legend / colourbar title (e.g. units). |
| `--palette` | `viridis` | Palette name (theme / semantic key / native colormap; see below). |
| `--reverse` | off | Reverse the chosen palette direction. |
| `--midpoint VALUE` | none | Centre a diverging palette on VALUE (e.g. `0` for anomalies). |
| `--list-palettes` | — | Print every available palette name and exit. |
| `--mode` | `continuous` | `continuous` field or `class` discrete raster. |
| `--classes` | `clcd` | Class definition when `--mode class`: `clcd`, `glulc6`, `harmonised`. |
| `--band` | 1 | Band index (1-based) for multi-band inputs. |
| `--limits MIN MAX` | none | Fixed colour limits (overrides `--clamp`). |
| `--clamp` | off | Clamp continuous range to the 2–98 percentile (robust to outliers). |
| `--src-nodata` | none | Override the source nodata value. |
| `--assets` | `../assets/china` | Directory holding `china.shp` / `dashline.shp`. |
| `--width` / `--height` | 7 / 6.2 | Figure size in inches. |
| `--dpi` | 600 | PNG resolution. |

## Palettes

Run `--list-palettes` on either engine to print the full catalogue. Three families are
available, and **both engines render the same names as identical colours**:

**1. Nature-grade themes** — defined by explicit hex control points shared byte-for-byte
between Python and R, so a figure looks the same whichever engine you run:

- Sequential (light → dark): `blues`, `greens`, `purples`, `oranges`, `reds`, `teal`,
  `ylgnbu`, `ylorrd`, `mako`, `rocket`
- Diverging (low → neutral → high; pair with `--midpoint`): `rdbu`, `rdylbu`,
  `spectral`, `brbg`, `puor`, `prgn`
- Perceptually-uniform: `viridis`, `cividis`, `inferno`, `plasma`

Add `--reverse` to flip any of them.

**2. Semantic keys** — sensible defaults matched to a variable type. Pick by what you map:

- Temperature: `temp` · Precipitation: `precip` · Seasonality/index: `seasonal`
- Soil texture/physical: `texture` · Soil pH: `ph` · Fertility/nutrients: `fertility`
- Vegetation/cover proportion: `veg`, `prop` · Biomass: `biomass` · Canopy height: `height`
- Topography elevation: `terrain` · Slope: `slope` · Hillshade: `hillshade`
- Hydrology: `hydro`, `accum` · Population: `pop` · Human activity: `human`
- Ecosystem function/diversity: `emf`, `diversity` · Heat/PET: `heat` · Solar: `solar` · Edge: `edge`

**3. Native colormaps** — any other name falls through to the engine's built-in maps
(matplotlib for Python, `grDevices::hcl.colors` for R). These may differ slightly between
engines, so prefer a theme name when cross-engine consistency matters.

For the full palette table and discrete class colour definitions, see
[references/palettes.md](references/palettes.md).

## How it works

1. Reproject the source raster to a unified EPSG:4326 display grid
   (extent `73.40, 18.10, 135.15, 53.60`, 0.05° ≈ 5 km) — `average` resampling for
   continuous data, `nearest` for classes.
2. Mask to the China boundary polygons.
3. Draw the raster, overlay `china.shp` + `dashline.shp`, add the South China Sea inset.
4. Apply the palette/limits and legend; export transparent PNG + PDF.

## Assets

`assets/china/` (bundled) contains the required basemap vectors in WGS-84:

- `china.shp` — China provincial boundaries (the mask + main outline)
- `dashline.shp` — South China Sea nine-dash line + island groups
- `countries.shp` — neighbouring countries (optional background, not drawn by default)

Always ship China maps with `dashline.shp` and the South China Sea inset so the map
is territorially complete and compliant.

## Testing

`tests/` provides a self-contained smoke test (no external data needed):

```bash
python tests/test_render.py
```

It generates synthetic demo rasters (`tests/gen_demo_raster.py`), runs both the
continuous and class modes for the Python engine and — if `Rscript` is on `PATH` —
the R engine, and asserts that every `.png`/`.pdf` output exists and is non-empty.
The R engine is reported as `SKIP` (not a failure) when R is unavailable.

## Notes

- Input rasters may be in any CRS; they are reprojected internally. Very large COGs are
  read via overviews where available (R engine uses GDAL warp with `-ovr AUTO`).
- Use `--clamp` for continuous data with long tails (population, biomass) to avoid a
  washed-out colour scale; use `--limits` when a fixed, comparable scale is needed
  across multiple panels.
- Outputs under `tests/_out/` are git-ignored.
