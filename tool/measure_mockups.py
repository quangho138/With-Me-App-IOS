#!/usr/bin/env python3
"""Measure the WITH ME Complete App Design V1 mockups.

The design document is 45 screenshots with no redlines, so every number in
docs/WITH_ME_SPEC_V1.md is derived here rather than eyeballed. Run this to
reproduce or re-check the spec.

    python tool/measure_mockups.py                 # all screens
    python tool/measure_mockups.py 5 7 10          # just those images

Each mockup wraps the screen in a dark device frame. The inner screen is
290x590 px in every one of the 45, so the conversion to the 390x844 pt
iPhone 14 reference is a constant x1.3448.
"""

from __future__ import annotations

import json
import os
import sys
from dataclasses import dataclass, asdict

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
MEDIA = os.path.join(ROOT, "build", "design_v1", "word", "media")
OUT = os.path.join(ROOT, "build", "measurements.json")

# Mockup inner screen -> iPhone 14/15 logical points.
MOCKUP_W, MOCKUP_H = 290, 590
REF_W, REF_H = 390, 844
SCALE = REF_W / MOCKUP_W  # 1.3448

# Document order. rIdN -> image(N-5).png, so image index == document order.
SCREENS = {
    1: "welcome-login", 2: "create-account", 3: "reset-password", 4: "profile",
    5: "home", 6: "monthly-calendar",
    7: "checkin-mood", 8: "checkin-stress", 9: "checkin-motivation",
    10: "checkin-stress-area", 11: "stressors-work", 12: "stressors-home",
    13: "stressors-school", 14: "stressors-social", 15: "signs-intro",
    16: "signs-body", 17: "signs-feelings", 18: "signs-mind",
    19: "signs-behavior", 20: "intention", 21: "strategies",
    22: "strategies-custom-dialog", 23: "strategy-details", 24: "self-reflection",
    25: "exercise-choose", 26: "rest-your-mind", 27: "breathing-478",
    28: "breathing-4444-info", 29: "breathing-4444", 30: "before-we-start",
    31: "soundscape-player",
    32: "insights", 33: "triggers-and-signs", 34: "strategies-and-actions",
    35: "day-detail", 36: "your-day", 37: "progress", 38: "reminder",
    39: "remember",
    40: "menu", 41: "settings", 42: "notifications", 43: "membership",
    44: "about", 45: "logs",
}


def pt(px):
    """Mockup pixels -> reference points, rounded to a half point."""
    return round(px * SCALE * 2) / 2


@dataclass
class Rect:
    x: float
    y: float
    w: float
    h: float
    fill: str
    radius: float


def hexof(c):
    return "#%02X%02X%02X" % c[:3]


def find_screen(im):
    """Locate the inner screen inside the dark device frame."""
    w, h = im.size
    px = im.load()

    def is_frame(c):
        return sum(c[:3]) < 260

    def bounds(seq):
        i = 0
        while i + 1 < len(seq) and seq[i + 1] == seq[i] + 1:
            i += 1
        j = len(seq) - 1
        while j - 1 >= 0 and seq[j - 1] == seq[j] - 1:
            j -= 1
        return seq[i] + 1, seq[j] - 1

    mid_y, mid_x = h // 2, w // 2
    x0, x1 = bounds([x for x in range(w) if is_frame(px[x, mid_y])])
    y0, y1 = bounds([y for y in range(h) if is_frame(px[mid_x, y])])
    return x0, y0, x1 - x0 + 1, y1 - y0 + 1


# --- pixel classification -------------------------------------------------
# The page is a mint->peach vertical gradient; cards sit on it as near-white
# cream, and primary buttons / selected tiles as deep teal.

def classify(c):
    r, g, b = c[:3]
    mx, mn = max(r, g, b), min(r, g, b)
    if r > 243 and g > 240 and b > 232 and mx - mn < 26:
        return "card"
    if g > r and g > b and g < 140 and r < 90:
        return "teal"
    if mx < 110:
        return "ink"
    return "bg"


def row_runs(px, w, y, want):
    runs, start = [], None
    for x in range(w):
        hit = classify(px[x, y]) == want
        if hit and start is None:
            start = x
        elif not hit and start is not None:
            if x - start >= 8:
                runs.append((start, x - 1))
            start = None
    if start is not None and w - start >= 8:
        runs.append((start, w - 1))
    return runs


def find_blocks(im, want):
    """Horizontal bands of `want`, merged into rectangles."""
    w, h = im.size
    px = im.load()
    bands = []  # (y, x0, x1)
    for y in range(h):
        runs = row_runs(px, w, y, want)
        if not runs:
            continue
        x0 = min(r[0] for r in runs)
        x1 = max(r[1] for r in runs)
        if x1 - x0 + 1 < 24:
            continue
        bands.append((y, x0, x1))

    rects = []
    cur = []
    for band in bands:
        if not cur:
            cur = [band]
            continue
        prev = cur[-1]
        overlap = min(prev[2], band[2]) - max(prev[1], band[1])
        if band[0] == prev[0] + 1 and overlap > 0.55 * (prev[2] - prev[1]):
            cur.append(band)
        else:
            rects.append(_to_rect(im, cur))
            cur = [band]
    if cur:
        rects.append(_to_rect(im, cur))
    return [r for r in rects if r.h >= 10 and r.w >= 30]


def _to_rect(im, bands):
    px = im.load()
    ys = [b[0] for b in bands]
    widest = max(b[2] - b[1] for b in bands)
    body = [b for b in bands if b[2] - b[1] >= widest - 2]
    x0 = min(b[1] for b in body)
    x1 = max(b[2] for b in body)
    y0, y1 = min(ys), max(ys)

    # Radius ~= how far the top row is inset relative to the full-width rows.
    radius = max(0, bands[0][1] - x0)

    mid = (y0 + y1) // 2
    fill = hexof(px[min(x0 + (x1 - x0) // 2, im.size[0] - 1), mid])
    return Rect(pt(x0), pt(y0), pt(x1 - x0 + 1), pt(y1 - y0 + 1), fill, pt(radius))


def measure(index):
    path = os.path.join(MEDIA, "image%d.png" % index)
    im = Image.open(path).convert("RGB")
    sx, sy, sw, sh = find_screen(im)
    screen = im.crop((sx, sy, sx + sw, sy + sh))

    px = screen.load()
    gradient = [
        {"stop": round(f, 2), "color": hexof(px[4, min(int(f * (sh - 1)), sh - 1)])}
        for f in (0.05, 0.25, 0.5, 0.75, 0.95)
    ]

    return {
        "image": "image%d.png" % index,
        "screen": SCREENS.get(index, "?"),
        "frame_px": [sw, sh],
        "frame_pt": [pt(sw), pt(sh)],
        "gradient": gradient,
        "cards": [asdict(r) for r in find_blocks(screen, "card")],
        "teal": [asdict(r) for r in find_blocks(screen, "teal")],
    }


def report(m):
    lines = ["=== %s  %s  (%dx%d px -> %sx%s pt)" % (
        m["image"], m["screen"], m["frame_px"][0], m["frame_px"][1],
        m["frame_pt"][0], m["frame_pt"][1])]
    lines.append("    gradient: " + "  ".join(
        "%s:%s" % (g["stop"], g["color"]) for g in m["gradient"]))
    for label, key in (("card", "cards"), ("teal", "teal")):
        for r in m[key]:
            lines.append(
                "    %-5s x=%6.1f y=%6.1f w=%6.1f h=%6.1f  r=%4.1f  %s" % (
                    label, r["x"], r["y"], r["w"], r["h"], r["radius"], r["fill"]))
    return "\n".join(lines)


def main(argv):
    wanted = [int(a) for a in argv] or sorted(SCREENS)
    out = {}
    for i in wanted:
        m = measure(i)
        out[m["image"]] = m
        print(report(m))
        print()
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2)
    print("-> %s  (%d screens)" % (OUT, len(out)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
