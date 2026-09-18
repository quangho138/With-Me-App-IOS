#!/usr/bin/env python3
"""Cut the mascot out of the V1 design mockups.

The design document ships no character art — the mascot only exists baked
into 45 screenshots, ~120 px tall. This lifts the largest clean instance off
the page gradient and mattes it to transparency.

    python tool/extract_mascot.py            # survey every mockup
    python tool/extract_mascot.py --write    # write the best ones as assets

This is a stopgap. See the "mascot resolution" note in
docs/WITH_ME_SPEC_V1.md: transparent PNGs at 3x would replace these and
nothing else would have to change.
"""

from __future__ import annotations

import os
import sys

from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
MEDIA = os.path.join(ROOT, "build", "design_v1", "word", "media")
DEST = os.path.join(
    ROOT, "stress_and_anxiety_management_app_ios", "assets", "mascot"
)

# Mockups whose mascot sits alone on the gradient, clear of cards and text.
CANDIDATES = [1, 3, 7, 23, 30, 36, 38, 39, 44]

# Upscale factor for the shipped asset. The source is tiny either way; 3x
# keeps it from being resampled twice on a 3x device.
UPSCALE = 3


def find_screen(im):
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

    x0, x1 = bounds([x for x in range(w) if is_frame(px[x, h // 2])])
    y0, y1 = bounds([y for y in range(h) if is_frame(px[w // 2, y])])
    return im.crop((x0, y0, x1 + 1, y1 + 1))


def row_background(px, w, y, margin=6):
    """The gradient colour for this row, read from the page edges."""
    left = [px[x, y] for x in range(2, margin)]
    right = [px[x, y] for x in range(w - margin, w - 2)]
    sample = left + right
    n = len(sample)
    return tuple(sum(c[i] for c in sample) // n for i in range(3))


def is_chrome(c):
    """Card cream or primary teal — UI, not mascot."""
    r, g, b = c[:3]
    if r > 240 and g > 236 and b > 228:
        return True
    if abs(r - 0x0D) < 34 and abs(g - 0x6B) < 34 and abs(b - 0x63) < 34:
        return True
    return False


def deviation_mask(screen, skip_chrome=True):
    """Per-pixel distance from the row's background gradient.

    `skip_chrome` drops cards and buttons, which is what makes the mascot the
    biggest blob on the page. It must be off when building the alpha: the
    character's own near-white highlights would otherwise be cut out, and they
    connect to the page through the pale edge of the body.
    """
    w, h = screen.size
    px = screen.load()
    mask = Image.new("L", (w, h), 0)
    mp = mask.load()
    for y in range(h):
        bg = row_background(px, w, y)
        for x in range(w):
            c = px[x, y]
            if skip_chrome and is_chrome(c):
                continue
            d = abs(c[0] - bg[0]) + abs(c[1] - bg[1]) + abs(c[2] - bg[2])
            mp[x, y] = 255 if d > 34 else 0
    return mask


def largest_blob(mask, min_side=40):
    """Bounding box of the biggest connected run-cluster in the mask."""
    w, h = mask.size
    mp = mask.load()
    seen = [[False] * w for _ in range(h)]
    best = None
    best_area = 0
    for sy in range(h):
        for sx in range(w):
            if mp[sx, sy] == 0 or seen[sy][sx]:
                continue
            stack = [(sx, sy)]
            seen[sy][sx] = True
            x0 = x1 = sx
            y0 = y1 = sy
            area = 0
            while stack:
                x, y = stack.pop()
                area += 1
                if x < x0:
                    x0 = x
                if x > x1:
                    x1 = x
                if y < y0:
                    y0 = y
                if y > y1:
                    y1 = y
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h and not seen[ny][nx] and mp[nx, ny]:
                        seen[ny][nx] = True
                        stack.append((nx, ny))
            if area > best_area and (x1 - x0) >= min_side and (y1 - y0) >= min_side:
                best_area = area
                best = (x0, y0, x1 + 1, y1 + 1)
    return best, best_area


def cut(index):
    im = Image.open(os.path.join(MEDIA, "image%d.png" % index)).convert("RGB")
    screen = find_screen(im)
    mask = deviation_mask(screen)
    box, area = largest_blob(mask)
    if box is None:
        return None
    return screen, mask, box, area


def fill_holes(alpha):
    """Make the silhouette solid.

    Parts of the mascot's body are close enough to the page gradient that the
    threshold drops them, which punches holes through the middle of the
    character. Anything the background cannot reach from the crop border is
    interior, so flood the outside and keep the rest.
    """
    w, h = alpha.size
    ap = alpha.load()
    outside = [[False] * w for _ in range(h)]
    stack = []
    for x in range(w):
        for y in (0, h - 1):
            if ap[x, y] == 0 and not outside[y][x]:
                outside[y][x] = True
                stack.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            if ap[x, y] == 0 and not outside[y][x]:
                outside[y][x] = True
                stack.append((x, y))
    while stack:
        x, y = stack.pop()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and not outside[ny][nx] and ap[nx, ny] == 0:
                outside[ny][nx] = True
                stack.append((nx, ny))
    solid = Image.new("L", (w, h), 0)
    sp = solid.load()
    for y in range(h):
        row = outside[y]
        for x in range(w):
            if not row[x]:
                sp[x, y] = 255
    return solid


def matte(screen, mask, box):
    """Crop to the mascot and build an alpha channel from the mask."""
    sub = screen.crop(box).convert("RGBA")
    # Rebuild the mask over the crop without the chrome rule — see
    # deviation_mask — then close what the threshold missed.
    alpha = fill_holes(deviation_mask(screen.crop(box), skip_chrome=False))
    # Soften the 1 px staircase the threshold leaves behind.
    alpha = alpha.filter(ImageFilter.GaussianBlur(0.6))
    sub.putalpha(alpha)
    w, h = sub.size
    return sub.resize((w * UPSCALE, h * UPSCALE), Image.LANCZOS)


def main(argv):
    write = "--write" in argv
    results = []
    for i in CANDIDATES:
        got = cut(i)
        if not got:
            print("image%-3d no blob" % i)
            continue
        screen, mask, box, area = got
        w = box[2] - box[0]
        h = box[3] - box[1]
        # The mascot is a single upright figure. Anything as wide as the
        # content column is a row of text or a card the mask leaked into.
        plausible = w < 130 and 0.5 < w / h < 1.15
        print("image%-3d box=%-22s %3dx%-3d  filled=%-6d %s" % (
            i, box, w, h, area, "mascot" if plausible else "rejected"))
        if plausible:
            results.append((h, i, screen, mask, box))

    if not write:
        print("\n(dry run — pass --write to emit assets)")
        return 0

    if not results:
        print("no usable mascot found")
        return 1
    results.sort(key=lambda r: r[0], reverse=True)
    os.makedirs(DEST, exist_ok=True)
    tallest = results[0]
    out = matte(tallest[2], tallest[3], tallest[4])
    path = os.path.join(DEST, "mascot_wave.png")
    out.save(path)
    print("\nwrote %s  %dx%d  (from image%d)" % (path, out.width, out.height, tallest[1]))

    # A badge crop: head and shoulders, for the 32-40 pt header lockup.
    head = out.crop((0, 0, out.width, int(out.height * 0.62)))
    badge = os.path.join(DEST, "mascot_badge.png")
    head.save(badge)
    print("wrote %s  %dx%d" % (badge, head.width, head.height))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
