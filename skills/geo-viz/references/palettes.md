# geo-viz — Palette & Class Reference

Run `--list-palettes` on either engine to print this catalogue at any time. Names
resolve in this order: **Nature-grade themes → semantic keys → native colormap**.
Add `--reverse` to flip any palette; add `--midpoint VALUE` to centre a diverging one.

## Nature-grade themes (identical in both engines)

These themes are defined by **explicit hex control points that are byte-for-byte
identical in `render_china_map.py` and `render_china_map.R`**, so a figure renders in
the exact same colours whichever engine you use. All are colour-blind-friendly.

| Family | Names | Direction |
|--------|-------|-----------|
| Sequential | `blues`, `greens`, `purples`, `oranges`, `reds`, `teal`, `ylgnbu`, `ylorrd`, `mako`, `rocket` | light → dark |
| Diverging | `rdbu`, `rdylbu`, `spectral`, `brbg`, `puor`, `prgn` | low → neutral → high |
| Perceptually-uniform | `viridis`, `cividis`, `inferno`, `plasma` | light → dark |

Diverging themes pair with `--midpoint` (e.g. `--midpoint 0`) to anchor the neutral
colour at a meaningful value — ideal for anomalies, trends, or differences.

## Semantic continuous keys

Each key maps to a colour ramp in both engines, chosen to suit a variable type.
Python uses a matplotlib colormap (reversed where noted); R uses the equivalent
`grDevices::hcl.colors` scheme. "High end" is the colour assigned to large values.

| Key | Suggested variables | Ramp (low → high) |
|-----|--------------------|-------------------|
| `temp` | temperature | blue (cold) → red (warm) |
| `precip` | precipitation, moisture | light → deep blue |
| `seasonal` | seasonality, CTI/SPI/STI indices | viridis |
| `heat` | growing degree days, PET | yellow → red |
| `solar` | sunshine percentage | yellow → brown |
| `soil` | generic soil | yellow → brown |
| `texture` | sand/silt/clay, bulk density, porosity | yellow → brown |
| `ph` | soil pH | red (acid) → blue (alkaline) |
| `fertility` | OC, N, P, K, CEC | light → deep green |
| `neutral` | Munsell soil colour components | viridis |
| `veg` | tree cover, NDVI | light → deep green |
| `prop` | land-cover proportion (0–1) | light → deep green |
| `biomass` | forest AGB | blue-green ramp |
| `height` | canopy height | emerald green |
| `terrain` | elevation | green (low) → tan (high) |
| `slope` | slope | yellow → red |
| `hillshade` | hillshade | grey scale |
| `hydro` | distance-to-stream, generic hydrology | yellow-green-blue |
| `accum` | flow accumulation | yellow-green-blue |
| `pop` | population | inferno |
| `human` | human footprint / impact index | rocket / magma |
| `emf` | ecosystem multifunctionality | viridis |
| `diversity` | landscape (Shannon) diversity | viridis |
| `edge` | edge density | purple-red |

Any value that is not a theme or a semantic key is treated as a **native colormap
name**: a matplotlib colormap for Python, or a `grDevices::hcl.colors` palette for R.
Native names may differ slightly between engines and unknown names raise a clear error
(the R engine lists valid options) — prefer a theme name when cross-engine consistency
matters.

## Discrete class definitions (`--mode class --classes <name>`)

### `clcd` — CLCD land cover (9 classes)

| Code | Label | Colour |
|------|-------|--------|
| 1 | Cropland | `#FAE39C` |
| 2 | Forest | `#446F33` |
| 3 | Shrub | `#33A02C` |
| 4 | Grassland | `#ABD37B` |
| 5 | Water | `#1E69B4` |
| 6 | Snow/Ice | `#A6CEE3` |
| 7 | Barren | `#CFBDA3` |
| 8 | Impervious | `#E24290` |
| 9 | Wetland | `#289BE8` |

### `glulc6` — Global LULC projection (6 classes)

| Code | Label | Colour |
|------|-------|--------|
| 1 | Cropland | `#E8C86E` |
| 2 | Forest | `#2E7D32` |
| 3 | Grassland | `#9CCB6A` |
| 4 | Urban | `#B2182B` |
| 5 | Barren | `#D7C9A8` |
| 6 | Water | `#3B7BB4` |

### `harmonised` — Harmonised global LULC (8 classes)

| Code | Label | Colour |
|------|-------|--------|
| 11 | Urban | `#B2182B` |
| 22 | Cropland | `#E8C86E` |
| 33 | Pasture | `#C7A76C` |
| 441 | Managed forest | `#2E7D32` |
| 442 | Unmanaged forest | `#7FBF7B` |
| 55 | Grass/shrub | `#9CCB6A` |
| 66 | Sparse veg. | `#D7C9A8` |
| 77 | Water | `#3B7BB4` |

Only the classes present in the input raster appear in the legend.

## Adding a new class definition

- Python: add an entry to `CLASS_DEFS` in `scripts/render_china_map.py`.
- R: add an entry to `CLASS_DEFS` in `scripts/render_china_map.R`.

Keep `codes`, `labels`, and `colors` the same length and order in both engines so
output stays consistent.
