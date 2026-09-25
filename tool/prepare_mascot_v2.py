#!/usr/bin/env python3
"""Turn the generated V2 mascot poses into frames the app can cross-fade.

The poses in `assets/v2/` (from image generation, one PNG per pose) are each
framed a little differently, so laid on top of one another the character
jumps. This script:

  1. registers every pose to a base - sitting poses to `mascot_idle`, the
     standing wave to `mascot_wave_a` - by matching the HEAD (scale search +
     phase correlation), so a change of pose reads as a change of expression,
     not a teleport;
  2. builds blink and wave frames as REGION SWAPS on the base: the blink
     frame is the base with only the eyes taken from the blink pose, the
     second wave frame is the base with only the waving arm taken from
     `wave_b`. Cross-fading two frames that are identical outside that region
     cannot ghost a second arm or shift the body;
  3. writes everything onto one shared canvas, downsized for the phone and
     saved as WebP, into `assets/v2/app/`.

    python tool/prepare_mascot_v2.py
"""

from __future__ import annotations

import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from skimage.registration import phase_cross_correlation

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "..", "stress_and_anxiety_management_app_ios", "assets", "v2")
OUT = os.path.join(SRC, "app")

# Final frame size. The character shows at up to ~300 pt tall; 900 px covers
# a 3x phone.
FRAME_W, FRAME_H = 640, 900
WEBP_QUALITY = 88

SITTING = ["idle", "think", "heart", "excited", "sad", "smirk", "happy"]


def load(name: str) -> Image.Image:
    return Image.open(os.path.join(SRC, f"mascot_{name}.png")).convert("RGBA")


def head_signal(im: Image.Image, scale: float) -> np.ndarray:
    """Greyscale of the top of the character (head, crown, flower), on black,
    at a reduced size - what registration compares."""
    w, h = im.size
    small = im.resize((max(1, int(w * scale)), max(1, int(h * scale))), Image.LANCZOS)
    arr = np.asarray(small).astype(np.float32) / 255.0
    lum = (0.3 * arr[..., 0] + 0.59 * arr[..., 1] + 0.11 * arr[..., 2]) * arr[..., 3]
    ys = np.nonzero(arr[..., 3] > 0.5)[0]
    top, bottom = ys.min(), ys.max()
    # The head and its crown are the top ~48% of the character.
    cut = int(top + (bottom - top) * 0.48)
    lum[cut:, :] = 0
    return lum


def register(base: Image.Image, moving: Image.Image) -> tuple[float, float, float]:
    """(scale, dx, dy) that maps `moving` onto `base`, in full-res pixels."""
    work = 0.25
    target = head_signal(base, work)
    best = None
    for s in np.arange(0.86, 1.141, 0.01):
        m = head_signal(moving, work * s)
        # Pad/crop to the target's shape, anchored top-left.
        canvas = np.zeros_like(target)
        hh, ww = min(canvas.shape[0], m.shape[0]), min(canvas.shape[1], m.shape[1])
        canvas[:hh, :ww] = m[:hh, :ww]
        shift, error, _ = phase_cross_correlation(target, canvas, normalization=None)
        if best is None or error < best[0]:
            best = (error, s, shift)
    _, s, (dy, dx) = best
    return float(s), float(dx / work), float(dy / work)


def place(im: Image.Image, scale: float, dx: float, dy: float, size) -> Image.Image:
    """`im` scaled by `scale` and shifted by (dx, dy) onto a `size` canvas."""
    w, h = im.size
    scaled = im.resize((round(w * scale), round(h * scale)), Image.LANCZOS)
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    out.alpha_composite(scaled, (round(dx), round(dy)))
    return out


def feathered_ellipse(size, box, blur: float) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).ellipse(box, fill=255)
    return mask.filter(ImageFilter.GaussianBlur(blur))


def feathered_rect(size, box, blur: float) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rectangle(box, fill=255)
    return mask.filter(ImageFilter.GaussianBlur(blur))


def swap_region(base: Image.Image, donor: Image.Image, mask: Image.Image) -> Image.Image:
    """`base` with the masked area replaced by `donor` - colour AND alpha - so
    whatever the base had there (an open eye, an arm) is gone, not covered."""
    b = np.asarray(base).astype(np.float32)
    d = np.asarray(donor).astype(np.float32)
    m = (np.asarray(mask).astype(np.float32) / 255.0)[..., None]
    return Image.fromarray((b * (1 - m) + d * m).round().astype(np.uint8), "RGBA")


def eye_box(im: Image.Image) -> tuple[int, int, int, int]:
    """Bounding box of the two big dark eyes, from the head region."""
    arr = np.asarray(im).astype(np.int32)
    ys = np.nonzero(arr[..., 3] > 128)[0]
    top, bottom = ys.min(), ys.max()
    band = (top + int((bottom - top) * 0.18), top + int((bottom - top) * 0.45))
    lum = arr[..., 0] + arr[..., 1] + arr[..., 2]
    dark = (lum < 150) & (arr[..., 3] > 200)
    dark[: band[0], :] = False
    dark[band[1]:, :] = False
    yy, xx = np.nonzero(dark)
    return int(xx.min()), int(yy.min()), int(xx.max()), int(yy.max())


def fit_frame(frames: dict[str, Image.Image]) -> dict[str, Image.Image]:
    """Crop every frame to the union of their content, pad to the frame
    aspect, bottom-centred, and resize to FRAME_W x FRAME_H."""
    union = None
    for im in frames.values():
        bb = im.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
        union = bb if union is None else (
            min(union[0], bb[0]), min(union[1], bb[1]),
            max(union[2], bb[2]), max(union[3], bb[3]))
    x0, y0, x1, y1 = union
    pad = 12
    x0, y0, x1, y1 = x0 - pad, y0 - pad, x1 + pad, y1 + pad
    w, h = x1 - x0, y1 - y0
    aspect = FRAME_W / FRAME_H
    if w / h < aspect:
        grow = h * aspect - w
        x0 -= grow / 2
        x1 += grow / 2
    else:
        y0 -= w / aspect - h  # extra room above the head, feet stay put
    box = tuple(round(v) for v in (x0, y0, x1, y1))
    out = {}
    for name, im in frames.items():
        canvas = Image.new("RGBA", (box[2] - box[0], box[3] - box[1]), (0, 0, 0, 0))
        canvas.alpha_composite(im, (-box[0], -box[1]))
        out[name] = canvas.resize((FRAME_W, FRAME_H), Image.LANCZOS)
    return out


# The waving arm, in the fitted 640 x 900 standing frame: the head is an
# ellipse centred (290, 392) with radii (246, 210), and the arm swings about
# the shoulder at WAVE_PIVOT. Read off a gridded render of mascot_wave_a.
WAVE_PIVOT = (508, 600)
_HEAD = (290, 392, 246, 210)


def split_wave_arm(frames: dict[str, Image.Image]):
    """The raised arm as its own layer, and the body without it (open-eyed
    and blinking), so the app can swing the arm from the shoulder.

    Everything outside the head ellipse, right of x = 482 and above the
    shoulder is arm. The cut fades out over the 16 px above the pivot so the
    joint has no hard edge. Swings of about +1 to +12 degrees (toward the
    head) leave no visible seam; swinging outward exposes the cut."""
    a = np.asarray(frames["wave_a"]).astype(np.float32)
    h, w = a.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w]
    cx, cy, rx, ry = _HEAD
    outside = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 > 1.0
    mask = (outside & (xx > 482) & (yy > 380) & (a[..., 3] > 0)).astype(np.float32)
    mask *= np.clip((WAVE_PIVOT[1] - yy) / 16, 0, 1)
    mask = np.asarray(
        Image.fromarray((mask * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.2))
    ).astype(np.float32) / 255.0

    def with_alpha(arr, factor):
        out = arr.copy()
        out[..., 3] *= factor
        return Image.fromarray(out.round().astype(np.uint8), "RGBA")

    blink = np.asarray(frames["wave_blink"]).astype(np.float32)
    return with_alpha(a, 1 - mask), with_alpha(blink, 1 - mask), with_alpha(a, mask)


def main() -> None:
    os.makedirs(OUT, exist_ok=True)
    report = []

    # --- sitting set, registered to idle --------------------------------
    idle = load("idle")
    size = (idle.width + 400, idle.height + 200)
    origin = (200, 100)
    sitting = {"idle": place(idle, 1, *origin, size)}
    for name in SITTING[1:]:
        s, dx, dy = register(idle, load(name))
        sitting[name] = place(load(name), s, origin[0] + dx, origin[1] + dy, size)
        report.append(f"{name:8s} -> idle   scale {s:.2f}  shift ({dx:+.0f}, {dy:+.0f})")

    # Blinks: only the eyes come from the blink pose.
    for base_name in ("idle", "think"):
        base = sitting[base_name]
        blink_src = load(f"{base_name}_blink")
        s, dx, dy = register(load(base_name), blink_src)
        blink = place(blink_src, s, origin[0] + dx, origin[1] + dy, size)
        ex0, ey0, ex1, ey1 = eye_box(base)
        mx, my = (ex1 - ex0) * 0.18, (ey1 - ey0) * 0.55
        mask = feathered_ellipse(size, (ex0 - mx, ey0 - my, ex1 + mx, ey1 + my), 14)
        sitting[f"{base_name}_blink"] = swap_region(base, blink, mask)
        report.append(f"{base_name}_blink eyes {ex0},{ey0}-{ex1},{ey1}  scale {s:.2f}")

    # --- standing wave set, registered to wave_a ------------------------
    wave_a = load("wave_a")
    wsize = (wave_a.width + 400, wave_a.height + 200)
    standing = {"wave_a": place(wave_a, 1, *origin, wsize)}
    s, dx, dy = register(wave_a, load("wave_b"))
    wave_b = place(load("wave_b"), s, origin[0] + dx, origin[1] + dy, wsize)
    report.append(f"wave_b   -> wave_a scale {s:.2f}  shift ({dx:+.0f}, {dy:+.0f})")
    # The waving arm is on the viewer's right, above the lei.
    bb = standing["wave_a"].getchannel("A").getbbox()
    cx = (bb[0] + bb[2]) / 2
    arm = feathered_rect(wsize, (cx + (bb[2] - bb[0]) * 0.18, bb[1] + (bb[3] - bb[1]) * 0.12,
                                  wsize[0], bb[1] + (bb[3] - bb[1]) * 0.62), 22)
    standing["wave_b"] = swap_region(standing["wave_a"], wave_b, arm)
    s, dx, dy = register(wave_a, load("wave_blink"))
    wblink = place(load("wave_blink"), s, origin[0] + dx, origin[1] + dy, wsize)
    ex0, ey0, ex1, ey1 = eye_box(standing["wave_a"])
    mx, my = (ex1 - ex0) * 0.18, (ey1 - ey0) * 0.55
    standing["wave_blink"] = swap_region(
        standing["wave_a"], wblink,
        feathered_ellipse(wsize, (ex0 - mx, ey0 - my, ex1 + mx, ey1 + my), 14))

    fitted_standing = fit_frame(standing)
    body, body_blink, arm = split_wave_arm(fitted_standing)
    report.append(f"wave arm pivot at {WAVE_PIVOT} of {FRAME_W}x{FRAME_H}")

    for group in (fit_frame(sitting), {
        "wave_body": body, "wave_body_blink": body_blink, "wave_arm": arm,
    }):
        for name, im in group.items():
            path = os.path.join(OUT, f"mascot_{name}.webp")
            im.save(path, "WEBP", quality=WEBP_QUALITY, method=6)
            report.append(f"wrote {os.path.basename(path)} {os.path.getsize(path)//1024} KB")

    for bg in ("bg_welcome", "bg_sunset"):
        im = Image.open(os.path.join(SRC, f"{bg}.png")).convert("RGB")
        path = os.path.join(OUT, f"{bg}.webp")
        im.save(path, "WEBP", quality=86, method=6)
        report.append(f"wrote {os.path.basename(path)} {os.path.getsize(path)//1024} KB")

    print("\n".join(report))


if __name__ == "__main__":
    main()
