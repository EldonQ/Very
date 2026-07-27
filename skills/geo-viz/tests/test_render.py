#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""End-to-end smoke test for the geo-viz renderers (Python and, if available, R).

Steps:
  1. Generate synthetic demo rasters (continuous + class).
  2. Run render_china_map.py for both modes; assert PNG + PDF exist and are non-empty.
  3. If Rscript is on PATH, run render_china_map.R for both modes and assert outputs.

Exit code 0 = all executed engines passed. R is skipped (not failed) if Rscript
is unavailable.
"""
from __future__ import annotations

import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SCRIPTS = os.path.normpath(os.path.join(HERE, "..", "scripts"))
OUT = os.path.join(HERE, "_out")


def _assert_outputs(base):
    ok = True
    for ext in (".png", ".pdf"):
        path = base + ext
        if not os.path.exists(path) or os.path.getsize(path) == 0:
            print("  FAIL missing/empty:", path)
            ok = False
        else:
            print("  ok  %-40s %8d bytes" % (os.path.basename(path),
                                             os.path.getsize(path)))
    return ok


def _run(cmd):
    print("+", " ".join(cmd))
    res = subprocess.run(cmd, capture_output=True, text=True,
                          encoding="utf-8", errors="replace")
    if res.returncode != 0:
        print(res.stdout)
        print(res.stderr, file=sys.stderr)
    else:
        if res.stdout.strip():
            print(res.stdout.strip())
    return res.returncode == 0


def gen_rasters():
    return _run([sys.executable, os.path.join(HERE, "gen_demo_raster.py"),
                 "--outdir", OUT])


def test_python():
    cont = os.path.join(OUT, "demo_continuous.tif")
    cls = os.path.join(OUT, "demo_class.tif")
    passed = True
    if not _run([sys.executable, os.path.join(SCRIPTS, "render_china_map.py"),
                 "--input", cont, "--output", os.path.join(OUT, "py_continuous"),
                 "--title", "Demo Continuous (PY)", "--legend", "degC",
                 "--palette", "temp", "--clamp"]):
        passed = False
    passed &= _assert_outputs(os.path.join(OUT, "py_continuous"))
    if not _run([sys.executable, os.path.join(SCRIPTS, "render_china_map.py"),
                 "--input", cls, "--output", os.path.join(OUT, "py_class"),
                 "--title", "Demo Land Cover (PY)", "--mode", "class",
                 "--classes", "clcd", "--legend", "Class"]):
        passed = False
    passed &= _assert_outputs(os.path.join(OUT, "py_class"))
    return passed


def test_r():
    if shutil.which("Rscript") is None:
        print("Rscript not found - skipping R engine test.")
        return None
    cont = os.path.join(OUT, "demo_continuous.tif")
    cls = os.path.join(OUT, "demo_class.tif")
    passed = True
    if not _run(["Rscript", os.path.join(SCRIPTS, "render_china_map.R"),
                 "--input", cont, "--output", os.path.join(OUT, "r_continuous"),
                 "--title", "Demo Continuous (R)", "--legend", "degC",
                 "--palette", "temp", "--clamp"]):
        passed = False
    passed &= _assert_outputs(os.path.join(OUT, "r_continuous"))
    if not _run(["Rscript", os.path.join(SCRIPTS, "render_china_map.R"),
                 "--input", cls, "--output", os.path.join(OUT, "r_class"),
                 "--title", "Demo Land Cover (R)", "--mode", "class",
                 "--classes", "clcd", "--legend", "Class"]):
        passed = False
    passed &= _assert_outputs(os.path.join(OUT, "r_class"))
    return passed


def main():
    print("== geo-viz renderer smoke test ==")
    if not gen_rasters():
        print("RESULT: FAIL (raster generation)")
        return 1
    print("\n-- Python engine --")
    py_ok = test_python()
    print("\n-- R engine --")
    r_ok = test_r()

    print("\n== summary ==")
    print("  python:", "PASS" if py_ok else "FAIL")
    print("  R:     ", "PASS" if r_ok else ("SKIP" if r_ok is None else "FAIL"))
    failed = (py_ok is False) or (r_ok is False)
    print("RESULT:", "FAIL" if failed else "PASS")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
