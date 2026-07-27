#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Generate small synthetic GeoTIFFs over China for testing the renderers.

Creates two rasters in the target directory:
  demo_continuous.tif  - a smooth latitude/longitude gradient (temperature-like)
  demo_class.tif       - a discrete CLCD-style class raster (codes 1-9)

These cover the China display extent so masking/inset logic can be exercised
without any external data.
"""
from __future__ import annotations

import argparse
import os

import numpy as np
import rasterio
from rasterio.transform import from_origin

# Match the renderer display grid but coarser (faster tests).
WEST, SOUTH, EAST, NORTH = 73.40, 18.10, 135.15, 53.60
RES = 0.2


def _grid():
    width = int(round((EAST - WEST) / RES))
    height = int(round((NORTH - SOUTH) / RES))
    transform = from_origin(WEST, NORTH, RES, RES)
    xs = WEST + (np.arange(width) + 0.5) * RES
    ys = NORTH - (np.arange(height) + 0.5) * RES
    lon, lat = np.meshgrid(xs, ys)
    return width, height, transform, lon, lat


def write_continuous(path):
    width, height, transform, lon, lat = _grid()
    # Temperature-like field: warm south, cool north/west highlands.
    data = (30.0 - 0.6 * (lat - SOUTH) - 0.05 * (lon - WEST)
            + 3.0 * np.sin(lon / 6.0)).astype("float32")
    _write(path, data, transform, dtype="float32", nodata=-9999.0)


def write_class(path):
    width, height, transform, lon, lat = _grid()
    rng = np.random.default_rng(42)
    # Spatially coherent-ish classes 1..9 via banded latitude + noise.
    band = np.clip(((NORTH - lat) / (NORTH - SOUTH) * 8).astype(int) + 1, 1, 9)
    noise = rng.integers(-1, 2, size=band.shape)
    data = np.clip(band + noise, 1, 9).astype("int16")
    _write(path, data, transform, dtype="int16", nodata=0)


def _write(path, data, transform, dtype, nodata):
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with rasterio.open(
        path, "w", driver="GTiff", height=data.shape[0], width=data.shape[1],
        count=1, dtype=dtype, crs="EPSG:4326", transform=transform,
        nodata=nodata,
    ) as dst:
        dst.write(data, 1)
    print("wrote", path)


def main(argv=None):
    p = argparse.ArgumentParser(description="Generate demo rasters for geo-viz tests.")
    p.add_argument("--outdir", default=os.path.join(os.path.dirname(__file__), "_out"))
    args = p.parse_args(argv)
    write_continuous(os.path.join(args.outdir, "demo_continuous.tif"))
    write_class(os.path.join(args.outdir, "demo_class.tif"))


if __name__ == "__main__":
    main()
