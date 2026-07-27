# geo-viz — Palette & Class Reference

## Continuous palette keys

Each key maps to a colour ramp in both engines. Python uses a matplotlib colormap
(reversed where noted); R uses `grDevices::hcl.colors` with the equivalent scheme.
"High end" is the colour assigned to large values.

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

Any value not listed is passed through unchanged as a native colormap name
(matplotlib name for Python; `hcl.colors` palette name for R).

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
