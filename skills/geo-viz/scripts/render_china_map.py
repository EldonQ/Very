#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
geo-viz · Render a raster over a standards-compliant China basemap (Python).

Effect (distilled from a production research-visualization pipeline):
  - China boundary (china.shp) + South China Sea nine-dash line (dashline.shp)
  - South China Sea inset in the bottom-right corner
  - Nature-style, colour-blind-friendly palettes (continuous + discrete classes)
  - Transparent background, clean title, main map + legend
  - Export 600 dpi PNG (transparent) + vector PDF

Usage:
  python render_china_map.py --input data.tif --output out/name \
      --title "Annual Mean Temperature" --legend "degC" --palette temp

  python render_china_map.py --input landcover.tif --output out/lc \
      --mode class --classes clcd --title "Land Cover"

Run `python render_china_map.py --help` for all options.
"""
from __future__ import annotations

import argparse
import os
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

# Unified typography so every text element (title, legend, colourbar) shares one
# font family and a consistent size scale across all rendered maps.
plt.rcParams.update({
    "font.family": "sans-serif",
    "font.sans-serif": ["DejaVu Sans", "Arial", "Helvetica"],
    "axes.titlesize": 13,
    "figure.autolayout": False,
})
from matplotlib.colors import (
    BoundaryNorm,
    LinearSegmentedColormap,
    ListedColormap,
    Normalize,
)
from matplotlib.patches import Patch

try:
    import geopandas as gpd
    import rasterio
    from rasterio.features import geometry_mask
    from rasterio.transform import from_origin
    from rasterio.warp import Resampling, reproject
except ImportError as exc:  # pragma: no cover - dependency guard
    sys.stderr.write(
        "Missing dependency: %s\n"
        "Install with: pip install rasterio geopandas matplotlib numpy\n" % exc
    )
    raise SystemExit(2)

# --------------------------------------------------------------------------
# Constants (kept identical to the reference R implementation)
# --------------------------------------------------------------------------
DISP_RES = 0.05  # unified display grid ~5 km in EPSG:4326
DISP_TE = (73.40, 18.10, 135.15, 53.60)  # xmin ymin xmax ymax
INSET_XLIM = (105.0, 126.0)  # South China Sea inset crop
INSET_YLIM = (2.0, 26.0)
BORDER_COL = "#4E5963"

# Nature-style continuous palettes (colour-blind friendly). Values are the
# matplotlib colormap name plus whether it should be reversed so that the
# "high" end matches the reference (e.g. high temperature = red).
_PALETTES = {
    "temp": ("RdYlBu", True),
    "soil": ("YlOrBr", False),
    "prop": ("YlGn", False),
    "veg": ("Greens", False),
    "biomass": ("BuGn", False),
    "height": ("YlGn", False),
    "terrain": ("terrain", False),
    "hydro": ("YlGnBu", False),
    "pop": ("inferno", True),
    "human": ("magma", True),
    "emf": ("viridis", False),
    "precip": ("YlGnBu", False),
    "seasonal": ("viridis", False),
    "heat": ("YlOrRd", False),
    "solar": ("YlOrBr", False),
    "diversity": ("viridis", False),
    "edge": ("PuRd", False),
    "texture": ("YlOrBr", False),
    "ph": ("RdYlBu", False),
    "fertility": ("Greens", False),
    "neutral": ("viridis", False),
    "slope": ("YlOrRd", False),
    "hillshade": ("gray", False),
    "accum": ("YlGnBu", False),
}

# Perceptually uniform, colour-blind-safe native colormaps (identical maths in
# both engines). Exposed as first-class theme names alongside THEMES.
PERCEPTUAL = ("viridis", "cividis", "inferno", "plasma")

# Nature-grade themes defined by EXPLICIT hex control points. The R engine ships
# the byte-for-byte identical stops, so both backends interpolate the exact same
# colours. Sequential ramps run light -> dark; the names in DIVERGING run
# low -> neutral -> high and pair with --midpoint for a centred zero.
THEMES = {
    # -- sequential ---------------------------------------------------------
    "blues":   ["#F7FBFF", "#DEEBF7", "#C6DBEF", "#9ECAE1", "#6BAED6", "#4292C6", "#2171B5", "#08519C", "#08306B"],
    "greens":  ["#F7FCF5", "#E5F5E0", "#C7E9C0", "#A1D99B", "#74C476", "#41AB5D", "#238B45", "#006D2C", "#00441B"],
    "purples": ["#FCFBFD", "#EFEDF5", "#DADAEB", "#BCBDDC", "#9E9AC8", "#807DBA", "#6A51A3", "#54278F", "#3F007D"],
    "oranges": ["#FFF5EB", "#FEE6CE", "#FDD0A2", "#FDAE6B", "#FD8D3C", "#F16913", "#D94801", "#A63603", "#7F2704"],
    "reds":    ["#FFF5F0", "#FEE0D2", "#FCBBA1", "#FC9272", "#FB6A4A", "#EF3B2C", "#CB181D", "#A50F15", "#67000D"],
    "teal":    ["#F7FCFD", "#E5F5F9", "#CCECE6", "#99D8C9", "#66C2A4", "#41AE76", "#238B45", "#006D2C", "#00441B"],
    "ylgnbu":  ["#FFFFD9", "#EDF8B1", "#C7E9B4", "#7FCDBB", "#41B6C4", "#1D91C0", "#225EA8", "#253494", "#081D58"],
    "ylorrd":  ["#FFFFCC", "#FFEDA0", "#FED976", "#FEB24C", "#FD8D3C", "#FC4E2A", "#E31A1C", "#BD0026", "#800026"],
    "mako":    ["#D5F0EA", "#9FDCCB", "#5FB3A3", "#2E8289", "#1E4F6B", "#16263F"],
    "rocket":  ["#FBE6C8", "#F6A97A", "#E85D5D", "#B5305F", "#6E1A55", "#2C0B2E"],
    # -- diverging (low -> neutral -> high) ---------------------------------
    "rdbu":     ["#053061", "#2166AC", "#4393C3", "#92C5DE", "#D1E5F0", "#F7F7F7", "#FDDBC7", "#F4A582", "#D6604D", "#B2182B", "#67001F"],
    "rdylbu":   ["#313695", "#4575B4", "#74ADD1", "#ABD9E9", "#E0F3F8", "#FFFFBF", "#FEE090", "#FDAE61", "#F46D43", "#D73027", "#A50026"],
    "spectral": ["#3288BD", "#66C2A5", "#ABDDA4", "#E6F598", "#FFFFBF", "#FEE08B", "#FDAE61", "#F46D43", "#D53E4F", "#9E0142"],
    "brbg":     ["#543005", "#8C510A", "#BF812D", "#DFC27D", "#F6E8C3", "#F5F5F5", "#C7EAE5", "#80CDC1", "#35978F", "#01665E", "#003C30"],
    "puor":     ["#7F3B08", "#B35806", "#E08214", "#FDB863", "#FEE0B6", "#F7F7F7", "#D8DAEB", "#B2ABD2", "#8073AC", "#542788", "#2D004B"],
    "prgn":     ["#40004B", "#762A83", "#9970AB", "#C2A5CF", "#E7D4E8", "#F7F7F7", "#D9F0D3", "#A6DBA0", "#5AAE61", "#1B7837", "#00441B"],
}
DIVERGING = {"rdbu", "rdylbu", "spectral", "brbg", "puor", "prgn"}

# Discrete land-cover class definitions (codes / labels / colours).
CLASS_DEFS = {
    "clcd": {
        "codes": [1, 2, 3, 4, 5, 6, 7, 8, 9],
        "labels": [
            "Cropland", "Forest", "Shrub", "Grassland", "Water",
            "Snow/Ice", "Barren", "Impervious", "Wetland",
        ],
        "colors": [
            "#FAE39C", "#446F33", "#33A02C", "#ABD37B", "#1E69B4",
            "#A6CEE3", "#CFBDA3", "#E24290", "#289BE8",
        ],
    },
    "glulc6": {
        "codes": [1, 2, 3, 4, 5, 6],
        "labels": ["Cropland", "Forest", "Grassland", "Urban", "Barren", "Water"],
        "colors": ["#E8C86E", "#2E7D32", "#9CCB6A", "#B2182B", "#D7C9A8", "#3B7BB4"],
    },
    "harmonised": {
        "codes": [11, 22, 33, 441, 442, 55, 66, 77],
        "labels": [
            "Urban", "Cropland", "Pasture", "Managed forest",
            "Unmanaged forest", "Grass/shrub", "Sparse veg.", "Water",
        ],
        "colors": [
            "#B2182B", "#E8C86E", "#C7A76C", "#2E7D32", "#7FBF7B",
            "#9CCB6A", "#D7C9A8", "#3B7BB4",
        ],
    },
}


def get_cmap(name: str, reverse: bool = False):
    """Resolve a colormap from a Nature theme, a semantic key, or a native name.

    Resolution order: explicit-hex THEMES -> semantic _PALETTES -> matplotlib
    built-in name. ``reverse`` flips whichever colormap was resolved.
    """
    if name in THEMES:
        cmap = LinearSegmentedColormap.from_list(name, THEMES[name], N=256)
    elif name in _PALETTES:
        cmap_name, rev = _PALETTES[name]
        cmap = plt.get_cmap(cmap_name)
        if rev:
            cmap = cmap.reversed()
    else:
        cmap = plt.get_cmap(name)
    return cmap.reversed() if reverse else cmap


# --------------------------------------------------------------------------
# Data preparation
# --------------------------------------------------------------------------
def prepare_raster(input_path, china_geoms, band, mode, src_nodata):
    """Reproject the source raster to the unified EPSG:4326 grid and mask to China.

    Returns (array, extent, transform) where extent = (west, east, south, north).
    """
    west, south, east, north = DISP_TE
    width = int(round((east - west) / DISP_RES))
    height = int(round((north - south) / DISP_RES))
    dst_transform = from_origin(west, north, DISP_RES, DISP_RES)
    dst = np.full((height, width), np.nan, dtype="float32")

    resampling = Resampling.nearest if mode == "class" else Resampling.average
    with rasterio.open(input_path) as src:
        reproject(
            source=rasterio.band(src, band),
            destination=dst,
            src_transform=src.transform,
            src_crs=src.crs,
            src_nodata=src_nodata if src_nodata is not None else src.nodata,
            dst_transform=dst_transform,
            dst_crs="EPSG:4326",
            dst_nodata=np.nan,
            resampling=resampling,
        )

    inside = geometry_mask(
        china_geoms, out_shape=dst.shape, transform=dst_transform, invert=True
    )
    dst[~inside] = np.nan
    extent = (west, east, south, north)
    return dst, extent, dst_transform


# --------------------------------------------------------------------------
# Plotting
# --------------------------------------------------------------------------
def _draw_layer(ax, arr, extent, cmap, norm, vmin, vmax, discrete):
    if discrete or norm is not None:
        return ax.imshow(arr, extent=extent, origin="upper", cmap=cmap,
                         norm=norm, interpolation="nearest")
    return ax.imshow(arr, extent=extent, origin="upper", cmap=cmap,
                     vmin=vmin, vmax=vmax, interpolation="nearest")


def render(arr, extent, china, dashline, out_base, title, legend_title,
           palette, mode, classes, limits, clamp, reverse, midpoint,
           width, height, dpi):
    china_bounds = china.total_bounds  # minx, miny, maxx, maxy
    discrete = mode == "class"

    # ---- colour scale -----------------------------------------------------
    norm = vmin = vmax = None
    cmap = get_cmap(palette, reverse=reverse)
    legend_handles = None
    if discrete:
        cdef = CLASS_DEFS[classes]
        present = sorted(
            c for c in cdef["codes"] if np.any(np.isclose(arr, c, equal_nan=False))
        )
        if not present:
            present = cdef["codes"]
        idx = [cdef["codes"].index(c) for c in present]
        colors = [cdef["colors"][i] for i in idx]
        labels = [cdef["labels"][i] for i in idx]
        cmap = ListedColormap(colors)
        bounds = [c - 0.5 for c in present] + [present[-1] + 0.5]
        norm = BoundaryNorm(bounds, cmap.N)
        legend_handles = [Patch(facecolor=c, edgecolor="none", label=l)
                          for c, l in zip(colors, labels)]
    else:
        if limits is not None:
            vmin, vmax = limits
        elif clamp:
            finite = arr[np.isfinite(arr)]
            if finite.size:
                vmin, vmax = np.percentile(finite, [2, 98])
                if not np.isfinite(vmin) or vmin == vmax:
                    vmin, vmax = np.nanmin(arr), np.nanmax(arr)
        if midpoint is not None:
            finite = arr[np.isfinite(arr)]
            lo = vmin if vmin is not None else (
                float(np.nanmin(arr)) if finite.size else 0.0)
            hi = vmax if vmax is not None else (
                float(np.nanmax(arr)) if finite.size else 1.0)
            half = max(abs(lo - midpoint), abs(hi - midpoint))
            if half > 0:
                # Symmetric centring on ``midpoint`` (midpoint -> mid colour),
                # matching R's scales::rescale_mid so both engines colour
                # identically even when the midpoint sits outside the data.
                norm = Normalize(vmin=midpoint - half, vmax=midpoint + half)
                vmin = vmax = None

    # ---- main figure ------------------------------------------------------
    fig, ax = plt.subplots(figsize=(width, height))
    fig.patch.set_alpha(0.0)
    ax.patch.set_alpha(0.0)

    im = _draw_layer(ax, arr, extent, cmap, norm, vmin, vmax, discrete)
    china.boundary.plot(ax=ax, color=BORDER_COL, linewidth=0.22)
    if dashline is not None:
        dashline.plot(ax=ax, color=BORDER_COL, linewidth=0.30)

    ax.set_xlim(china_bounds[0], china_bounds[2])
    ax.set_ylim(china_bounds[1], china_bounds[3])
    # Latitude-corrected aspect so China keeps true geographic proportions in
    # EPSG:4326 (matches ggplot2 coord_sf; a plain "equal" aspect stretches it).
    mean_lat = 0.5 * (china_bounds[1] + china_bounds[3])
    ax.set_aspect(1.0 / np.cos(np.deg2rad(mean_lat)))
    ax.axis("off")
    if title:
        ax.set_title(title, fontsize=13, fontweight="bold", pad=6)

    # ---- legend / colourbar ----------------------------------------------
    if discrete:
        ax.legend(handles=legend_handles, title=legend_title, loc="center left",
                  bbox_to_anchor=(1.01, 0.5), frameon=False, fontsize=9,
                  title_fontsize=10)
    else:
        cbar = fig.colorbar(im, ax=ax, fraction=0.035, pad=0.02, shrink=0.75)
        cbar.ax.set_title(legend_title, fontsize=10, loc="left", pad=6)
        cbar.outline.set_visible(False)

    # ---- South China Sea inset (bottom-right) -----------------------------
    _add_scs_inset(ax, arr, extent, china, dashline, cmap, norm, vmin, vmax,
                   discrete)

    fig.tight_layout()
    os.makedirs(os.path.dirname(os.path.abspath(out_base)), exist_ok=True)
    png_path = out_base + ".png"
    pdf_path = out_base + ".pdf"
    fig.savefig(png_path, dpi=dpi, transparent=True, bbox_inches="tight")
    fig.savefig(pdf_path, transparent=True, bbox_inches="tight")
    plt.close(fig)
    print("  wrote: %s / %s" % (os.path.basename(png_path),
                                 os.path.basename(pdf_path)))
    return png_path


def _add_scs_inset(ax, arr, extent, china, dashline, cmap, norm, vmin, vmax,
                   discrete):
    """Draw the South China Sea inset anchored to the bottom-right corner."""
    axins = ax.inset_axes([0.80, 0.02, 0.18, 0.30])
    axins.patch.set_alpha(0.0)
    _draw_layer(axins, arr, extent, cmap, norm, vmin, vmax, discrete)
    china.boundary.plot(ax=axins, color=BORDER_COL, linewidth=0.18)
    if dashline is not None:
        dashline.plot(ax=axins, color=BORDER_COL, linewidth=0.25)
    axins.set_xlim(*INSET_XLIM)
    axins.set_ylim(*INSET_YLIM)
    axins.set_aspect(1.0 / np.cos(np.deg2rad(0.5 * (INSET_YLIM[0] + INSET_YLIM[1]))))
    axins.set_xticks([])
    axins.set_yticks([])
    for spine in axins.spines.values():
        spine.set_edgecolor(BORDER_COL)
        spine.set_linewidth(0.4)


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------
def load_basemap(assets_dir):
    china_shp = os.path.join(assets_dir, "china.shp")
    dash_shp = os.path.join(assets_dir, "dashline.shp")
    if not os.path.exists(china_shp):
        raise SystemExit("china.shp not found under: %s" % assets_dir)
    china = gpd.read_file(china_shp)
    if china.crs is None or china.crs.to_epsg() != 4326:
        china = china.to_crs(4326)
    dashline = None
    if os.path.exists(dash_shp):
        dashline = gpd.read_file(dash_shp)
        if dashline.crs is None or dashline.crs.to_epsg() != 4326:
            dashline = dashline.to_crs(4326)
    return china, dashline


def print_palettes():
    """Print every available palette name grouped by family, then exit."""
    seq = [k for k in THEMES if k not in DIVERGING]
    div = [k for k in THEMES if k in DIVERGING]
    print("Nature-grade themes (byte-for-byte identical in Python and R):")
    print("  sequential :", ", ".join(seq))
    print("  diverging  :", ", ".join(div), "   (pair with --midpoint)")
    print("  perceptual :", ", ".join(PERCEPTUAL))
    print("Semantic keys (auto-picked by variable type):")
    print(" ", ", ".join(sorted(_PALETTES)))
    print("Any matplotlib colormap name also works. Add --reverse to flip.")


def parse_args(argv=None):
    p = argparse.ArgumentParser(
        description="Render a raster over a China basemap (nine-dash line + SCS inset)."
    )
    p.add_argument("--input", help="Input GeoTIFF raster path.")
    p.add_argument("--output",
                   help="Output path base (without extension); .png and .pdf are written.")
    p.add_argument("--title", default="", help="Map title.")
    p.add_argument("--legend", default="", help="Legend / colourbar title.")
    p.add_argument("--palette", default="viridis",
                   help="Theme/semantic key or any matplotlib colormap "
                        "(run --list-palettes to see them all).")
    p.add_argument("--reverse", action="store_true",
                   help="Reverse the chosen palette.")
    p.add_argument("--midpoint", type=float, default=None,
                   help="Centre a diverging palette on this value (e.g. 0).")
    p.add_argument("--list-palettes", action="store_true",
                   help="List every available palette name and exit.")
    p.add_argument("--mode", choices=["continuous", "class"], default="continuous",
                   help="Continuous field or discrete class raster.")
    p.add_argument("--classes", choices=sorted(CLASS_DEFS), default="clcd",
                   help="Class definition to use when --mode class.")
    p.add_argument("--band", type=int, default=1, help="Raster band (1-based).")
    p.add_argument("--limits", type=float, nargs=2, default=None,
                   metavar=("MIN", "MAX"), help="Fixed colour limits.")
    p.add_argument("--clamp", action="store_true",
                   help="Clamp continuous colour range to the 2-98 percentile.")
    p.add_argument("--src-nodata", type=float, default=None,
                   help="Override source nodata value.")
    default_assets = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "..", "assets", "china"
    )
    p.add_argument("--assets", default=os.path.normpath(default_assets),
                   help="Directory containing china.shp / dashline.shp.")
    p.add_argument("--width", type=float, default=7.0, help="Figure width (inch).")
    p.add_argument("--height", type=float, default=6.2, help="Figure height (inch).")
    p.add_argument("--dpi", type=int, default=600, help="PNG resolution.")
    return p.parse_args(argv)


def main(argv=None):
    args = parse_args(argv)
    if args.list_palettes:
        print_palettes()
        return
    if not args.input or not args.output:
        raise SystemExit("--input and --output are required (or use --list-palettes).")
    if not os.path.exists(args.input):
        raise SystemExit("Input raster not found: %s" % args.input)
    china, dashline = load_basemap(args.assets)
    china_geoms = list(china.geometry)
    arr, extent, _ = prepare_raster(
        args.input, china_geoms, args.band, args.mode, args.src_nodata
    )
    if not np.any(np.isfinite(arr)):
        raise SystemExit("No valid data inside China after masking.")
    render(
        arr, extent, china, dashline, args.output, args.title, args.legend,
        args.palette, args.mode, args.classes, args.limits, args.clamp,
        args.reverse, args.midpoint, args.width, args.height, args.dpi,
    )


if __name__ == "__main__":
    main()
