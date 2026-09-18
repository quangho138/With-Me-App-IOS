#!/usr/bin/env python3
"""Compare the built screens against the design mockups.

Pairs each golden in `stress_and_anxiety_management_app_ios/test/goldens/`
with the mockup its name carries, normalises both to the 390 pt reference
width, runs the same rectangle detection over each, and reports the
differences.

    flutter test --tags golden --run-skipped --update-goldens
    python tool/compare_screens.py                  # report
    python tool/compare_screens.py --sheets         # also write side-by-sides

Side-by-side sheets land in `build/compare/` for eyeballing what the numbers
cannot catch — wording, weight, the mascot.

The mockup screen is 290 x 590 px against 390 x 844 pt of real device, so the
two are the same width but the mockup is ~50 pt shorter. Vertical positions
are therefore compared with that slack allowed; widths, heights and radii are
compared exactly.
"""

from __future__ import annotations

import os
import re
import sys

from PIL import Image

import measure_mockups as mm

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
APP = os.path.join(ROOT, "stress_and_anxiety_management_app_ios")
GOLDENS = os.path.join(APP, "test", "goldens")
SHEETS = os.path.join(ROOT, "build", "compare")

REF_W = 390

# How far a rectangle may sit from its counterpart before it is called out.
# The mockup is ~50 pt shorter than the device, so everything below the fold
# drifts; 26 keeps that quiet while still catching a misplaced card.
Y_SLACK = 26
SIZE_SLACK = 6


def golden_pairs():
    """(golden path, mockup index) for every golden that names a mockup."""
    if not os.path.isdir(GOLDENS):
        return []
    pairs = []
    for name in sorted(os.listdir(GOLDENS)):
        if not name.endswith(".png"):
            continue
        match = re.match(r"image(\d+)", name)
        if not match:
            # login / help are screens the document never shows.
            pairs.append((os.path.join(GOLDENS, name), None))
            continue
        pairs.append((os.path.join(GOLDENS, name), int(match.group(1))))
    return pairs


def load_golden(path):
    """Golden -> RGB at the 390 pt reference width."""
    im = Image.open(path).convert("RGB")
    scale = REF_W / im.width
    return im.resize((REF_W, round(im.height * scale)), Image.LANCZOS)


def load_mockup(index):
    """Mockup -> its inner screen, RGB at the 390 pt reference width."""
    path = os.path.join(mm.MEDIA, "image%d.png" % index)
    im = Image.open(path).convert("RGB")
    x, y, w, h = mm.find_screen(im)
    screen = im.crop((x, y, x + w, y + h))
    return screen.resize((REF_W, round(h * REF_W / w)), Image.LANCZOS)


def rects(im):
    """Detected card and button rectangles, already in reference points."""
    # measure_mockups works in mockup pixels and scales on the way out; these
    # images are already at the reference width, so undo that scaling.
    found = []
    for kind in ("card", "teal"):
        for r in mm.find_blocks(im, kind):
            found.append(
                {
                    "kind": kind,
                    "x": r.x / mm.SCALE,
                    "y": r.y / mm.SCALE,
                    "w": r.w / mm.SCALE,
                    "h": r.h / mm.SCALE,
                    "radius": r.radius / mm.SCALE,
                    "fill": r.fill,
                }
            )
    # Drop the gradient's own top and bottom bands, which the teal classifier
    # picks up on the mockups but not on the render, and the mockups' painted
    # status bar.
    found = [
        r for r in found
        if r["h"] >= 18 and r["w"] >= 60 and not (r["w"] > 380 and r["y"] < 6)
    ]
    found.sort(key=lambda r: r["y"])
    return found


def match(built, design):
    """Pair rectangles up by vertical position, nearest first."""
    remaining = list(design)
    pairs = []
    for b in built:
        best = None
        best_gap = None
        for d in remaining:
            gap = abs(b["y"] - d["y"]) + abs(b["w"] - d["w"])
            if best_gap is None or gap < best_gap:
                best, best_gap = d, gap
        if best is not None and best_gap is not None and best_gap < 90:
            remaining.remove(best)
            pairs.append((b, best))
        else:
            pairs.append((b, None))
    for d in remaining:
        pairs.append((None, d))
    return pairs


def report(path, index):
    name = os.path.basename(path)[:-4]
    built_im = load_golden(path)

    if index is None:
        print("%-34s (not in the design document)" % name)
        return 0

    design_im = load_mockup(index)
    built = rects(built_im)
    design = rects(design_im)
    built_h = built_im.height
    design_h = design_im.height

    notes = []
    for b, d in match(built, design):
        if b is None:
            notes.append(
                "    missing: design has %-4s w=%-6.1f h=%-6.1f at y=%.1f"
                % (d["kind"], d["w"], d["h"], d["y"])
            )
            continue
        if d is None:
            notes.append(
                "    extra:   built has  %-4s w=%-6.1f h=%-6.1f at y=%.1f"
                % (b["kind"], b["w"], b["h"], b["y"])
            )
            continue
        for field in ("w", "h", "x", "radius"):
            delta = b[field] - d[field]
            if abs(delta) > SIZE_SLACK:
                notes.append(
                    "    %-6s %s: built %.1f vs design %.1f  (%+.1f)"
                    % (b["kind"], field, b[field], d[field], delta)
                )

        # An element is anchored to the top of the screen or to the bottom.
        # The device is ~50 pt taller than the mockup, so one of the two
        # distances matches and the other is off by that slack. Flag only
        # when neither does.
        from_top = b["y"] - d["y"]
        from_bottom = (built_h - b["y"] - b["h"]) - (design_h - d["y"] - d["h"])
        if min(abs(from_top), abs(from_bottom)) > Y_SLACK:
            notes.append(
                "    %-6s y: built %.1f vs design %.1f  (%+.1f from the top, "
                "%+.1f from the bottom)"
                % (b["kind"], b["y"], d["y"], from_top, from_bottom)
            )

    status = "ok" if not notes else "%d difference(s)" % len(notes)
    print("%-34s image%-3d  built %2d rects, design %2d  -> %s"
          % (name, index, len(built), len(design), status))
    for note in notes:
        print(note)
    return len(notes)


def sheet(path, index):
    """Write the built screen and the mockup side by side."""
    if index is None:
        return
    built_im = load_golden(path)
    design_im = load_mockup(index)
    h = max(built_im.height, design_im.height)
    canvas = Image.new("RGB", (REF_W * 2 + 24, h), (24, 24, 24))
    canvas.paste(design_im, (0, 0))
    canvas.paste(built_im, (REF_W + 24, 0))
    os.makedirs(SHEETS, exist_ok=True)
    canvas.save(os.path.join(SHEETS, os.path.basename(path)))


def main(argv):
    pairs = golden_pairs()
    if not pairs:
        print("No goldens. Run:")
        print("  flutter test --tags golden --run-skipped --update-goldens")
        return 1

    total = 0
    for path, index in pairs:
        total += report(path, index)
        if "--sheets" in argv:
            sheet(path, index)

    print()
    print("%d screens, %d differences" % (len(pairs), total))
    if "--sheets" in argv:
        print("side-by-side sheets: %s" % SHEETS)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
