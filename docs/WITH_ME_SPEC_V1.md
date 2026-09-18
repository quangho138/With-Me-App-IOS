# With Me — measured spec, "Complete App Design V1"

The redline document that `WITH ME Complete App Design V1.docx` should have
been. **Every number here is derived, not given.** The .docx contains 45
screenshots and 9 section headings — no measurements, no colour values, no
font names, no Figma link.

Regenerate with:

```bash
unzip -oq "WITH ME Complete App Design V1.docx" -d build/design_v1
python tool/measure_mockups.py > build/measurements.txt
```

## Conversion

| | |
|---|---|
| Device frame inner screen | **290 × 590 px**, identical in all 45 mockups |
| Reference device | iPhone 14/15 — **390 × 844 pt** |
| Scale | **× 1.3448** (390 ÷ 290) |

The mockup screen is 2.034:1; a real iPhone 14 is 2.164:1. **Widths and type
sizes convert exactly. Vertical space has ~50 pt of slack on a real device**
(590 px → 793.5 pt against 844 pt available). Absorb that slack in the flexible
spacer above the bottom button — never by scaling type or padding.

## The grid

Measured across 189 of ~200 detected rectangles:

| Token | Value | Evidence |
|---|---|---|
| Page horizontal margin | **24** | `x = 24` on 189 rects |
| Content width | **342** | `w = 340` on 175 rects (anti-aliased inner fill) |
| Card / row / button radius | **16** | `r = 15` on 108 rects |
| Large card radius | **24** | `r = 20–23` on 36 rects |
| Vertical gap, stacked rows | **12** | e.g. welcome buttons at y 536 / 608 / 680, h 60 |
| Two-up grid column | **164** | `w = 164` on 9 rects → (342 − 14) ÷ 2 |
| Two-up grid gutter | **14** | |
| List row height | **52–56** | `h = 55` (37×), `h = 52.5` (33×) |
| Primary CTA height | **60** | `h = 60.5` on all 27 screens that have one |
| Primary CTA position | bottom-pinned, **24** from the bottom | `y = 708.5` on 23 of 27 |

## Colour

Sampled from the flat fills, not from anti-aliased edges.

| Token | Value | Use |
|---|---|---|
| `teal` | `#0D6B63` | primary button, headings, selected tile, active tab |
| `tealInk` | `#0B3E3C` | device-frame stroke, deepest text |
| `cream` | `#FCFAF4` | card and unselected-row fill |
| `creamWarm` | `#FDF9F2` | menu / settings row fill |
| `skyMint` | `#C9E5E0` | page gradient, top |
| `sandPeach` | `#F1CCAF` | page gradient, bottom |

Page background is a **plain two-stop vertical gradient** `#C9E5E0 → #F1CCAF`,
sampled identically on all 45 screens. Intermediate samples
(`0.25 #D7E3D6`, `0.5 #E8DFC9`, `0.75 #EED5BB`) sit on the straight line
between the two stops, so it is a simple linear gradient with no midpoint.

**There is no beach scene** — no sun, no headland, no surf lines. The current
`WithMeBackdrop._SceneryPainter` must go.

### Category accents

Used for the calendar legend, the dot on option rows, the stressor tiles, and
the chart series.

| Token | Value | Calendar meaning |
|---|---|---|
| `mint` | `#9BD4CB` | Check-in |
| `peach` | `#F5CFB3` | Exercise |
| `coral` | `#E38061` | Feeling better |
| `pink` | `#DD7397` | Challenging day |
| `slate` | `#C8D3CD` | "Other" / inactive |

## Typography — **unconfirmed, needs the product owner**

No font is wired in the project today; `pubspec.yaml`'s `fonts:` block is
commented out. The mockups clearly use two faces, identified from the renders
only:

| Role | Face | Seen in |
|---|---|---|
| UI | rounded geometric sans — **Quicksand** is the closest match | all body, labels, buttons |
| Accent | upright brush script | "With Me" wordmark, "Here. With you.", "Every step counts", "Small steps, bright futures", "Breathe with me…", "Four equal sides…", "Remember…" |

Treat both as provisional until confirmed.

## Screen-by-screen

Rectangles below are the machine-detected card / button / selected-tile
geometry in **pt at the 390-wide reference**. Text, icons and the mascot are
not in these tables — see the mockups for those.

Fills that are neither cream nor `#0D6B63` are the mascot or a chart bleeding
into the detector; ignore them.

<!-- BEGIN GENERATED -->

### welcome-login — `image1.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| teal | 162 | 400 | 56 | 16 | 0 | `#04655A` |
| teal | 24 | 536 | 340 | 60 | 15 | `#237871` |
| card | 24 | 608 | 340 | 60 | 16 | `#FEFAF4` |
| card | 26 | 680 | 338 | 52 | 14 | `#F8F5EF` |

### create-account — `image2.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 171 | 340 | 55 | 15 | `#FCFBF6` |
| card | 24 | 264 | 340 | 55 | 14 | `#FDFBF5` |
| card | 24 | 356 | 340 | 55 | 14 | `#FDFBF5` |
| teal | 24 | 676 | 340 | 60 | 15 | `#0D6B63` |

### reset-password — `image3.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 145 | 340 | 84 | 19 | `#F8F9F2` |
| card | 24 | 268 | 340 | 55 | 14 | `#FDFBF5` |
| teal | 24 | 708 | 340 | 60 | 15 | `#F6F7F2` |

### profile — `image4.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 101 | 340 | 105 | 20 | `#FBFAF5` |
| card | 24 | 244 | 340 | 55 | 14 | `#FDFBF5` |
| card | 24 | 336 | 340 | 55 | 14 | `#FDFBF5` |
| card | 24 | 429 | 340 | 55 | 14 | `#FDFBF5` |
| card | 24 | 496 | 340 | 86 | 18 | `#EDD8BF` |
| teal | 24 | 708 | 340 | 60 | 15 | `#77ABA4` |

### home — `image5.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 294 | 340 | 93 | 20 | `#FCFAF4` |
| teal | 40 | 446 | 308 | 55 | 14 | `#0D6B63` |
| card | 40 | 512 | 310 | 55 | 12 | `#14413F` |
| card | 40 | 578 | 310 | 55 | 12 | `#FEFCF6` |
| card | 40 | 644 | 310 | 55 | 12 | `#E4E7E1` |

### monthly-calendar — `image6.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 22 | 146 | 346 | 281 | 20 | `#E0714F` |
| card | 22 | 441 | 346 | 146 | 18 | `#FDF9F2` |

### checkin-mood — `image7.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 101 | 340 | 100 | 23 | `#FBFBF5` |
| card | 24 | 212 | 340 | 170 | 23 | `#FCFAF4` |
| teal | 292 | 240 | 51 | 40 | 10 | `#0D6B63` |
| card | 24 | 581 | 340 | 52 | 16 | `#FBF4EB` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### checkin-stress — `image8.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 72 | 340 | 128 | 23 | `#0D5C57` |
| card | 24 | 215 | 340 | 60 | 15 | `#14413F` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### checkin-motivation — `image9.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 72 | 340 | 100 | 23 | `#FBFBF5` |
| card | 24 | 187 | 340 | 60 | 16 | `#FFFDF8` |
| teal | 164 | 188 | 59 | 58 | 11 | `#FFFDF8` |
| card | 24 | 300 | 340 | 56 | 18 | `#587673` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### checkin-stress-area — `image10.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 58 | 340 | 100 | 23 | `#FBFBF5` |
| card | 24 | 174 | 162 | 105 | 18 | `#8FD0C6` |
| teal | 200 | 174 | 164 | 105 | 18 | `#F4C8A9` |
| card | 24 | 290 | 340 | 105 | 18 | `#E3E0CD` |
| card | 24 | 412 | 340 | 55 | 18 | `#FDFAF4` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### stressors-work — `image11.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 101 | 340 | 100 | 23 | `#FBFBF5` |
| card | 24 | 212 | 340 | 84 | 15 | `#0D6B63` |
| teal | 141 | 212 | 105 | 84 | 15 | `#0D6B63` |
| card | 141 | 308 | 223 | 84 | 15 | `#E4E0CC` |
| teal | 24 | 308 | 182 | 84 | 15 | `#0D6B63` |
| card | 24 | 405 | 340 | 54 | 14 | `#C4CDC8` |
| card | 24 | 470 | 164 | 51 | 14 | `#5E918C` |
| teal | 200 | 470 | 164 | 51 | 14 | `#83B2AC` |

### stressors-home — `image12.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 101 | 340 | 100 | 23 | `#FBFBF5` |
| card | 141 | 212 | 223 | 84 | 15 | `#DCE2D2` |
| teal | 24 | 212 | 106 | 84 | 15 | `#0D6B63` |
| card | 141 | 308 | 223 | 102 | 15 | `#E5E0CC` |
| teal | 24 | 308 | 182 | 102 | 15 | `#0D6B63` |
| card | 24 | 422 | 340 | 54 | 14 | `#C4CDC8` |
| card | 24 | 488 | 164 | 51 | 15 | `#5E918C` |
| teal | 200 | 488 | 164 | 51 | 14 | `#83B2AC` |

### stressors-school — `image13.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 101 | 340 | 100 | 23 | `#FBFBF5` |
| card | 24 | 212 | 340 | 102 | 15 | `#0D6B63` |
| teal | 141 | 212 | 105 | 102 | 15 | `#0D6B63` |
| card | 24 | 326 | 340 | 84 | 15 | `#FDFAF4` |
| card | 24 | 422 | 340 | 54 | 14 | `#C4CDC8` |
| card | 24 | 488 | 164 | 51 | 15 | `#5E918C` |
| teal | 200 | 488 | 164 | 51 | 14 | `#83B2AC` |

### stressors-social — `image14.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 101 | 340 | 100 | 23 | `#FBFBF5` |
| card | 141 | 212 | 105 | 84 | 15 | `#FCFAF5` |
| teal | 24 | 212 | 340 | 84 | 15 | `#FCFAF5` |
| card | 24 | 308 | 340 | 102 | 15 | `#FCFAF4` |
| card | 24 | 422 | 340 | 54 | 14 | `#C4CDC8` |
| card | 24 | 488 | 164 | 51 | 15 | `#5E918C` |
| teal | 200 | 488 | 164 | 51 | 14 | `#83B2AC` |

### signs-intro — `image15.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 101 | 340 | 128 | 20 | `#FBFAF5` |
| teal | 24 | 266 | 175 | 52 | 15 | `#6EA59F` |
| card | 24 | 330 | 171 | 42 | 15 | `#2C5452` |
| card | 24 | 382 | 167 | 48 | 15 | `#94A7A3` |
| card | 24 | 441 | 166 | 60 | 15 | `#FDFAF3` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### signs-body — `image16.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 106 | 340 | 100 | 23 | `#FBFAF5` |
| teal | 24 | 216 | 340 | 52 | 15 | `#0D6B63` |
| card | 24 | 280 | 340 | 52 | 15 | `#FBFAF3` |
| card | 24 | 343 | 340 | 52 | 15 | `#FCFAF3` |
| card | 24 | 406 | 340 | 52 | 15 | `#FCF9F3` |
| card | 24 | 470 | 340 | 52 | 15 | `#FDF9F2` |
| card | 24 | 532 | 340 | 52 | 16 | `#FDF9F2` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### signs-feelings — `image17.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 106 | 340 | 100 | 23 | `#FBFAF5` |
| teal | 24 | 216 | 340 | 52 | 15 | `#0D6B63` |
| teal | 24 | 280 | 340 | 52 | 15 | `#0D6B63` |
| card | 24 | 343 | 340 | 52 | 15 | `#FCFAF3` |
| card | 24 | 406 | 340 | 52 | 15 | `#FCF9F3` |
| card | 24 | 470 | 340 | 52 | 15 | `#FDF9F2` |
| card | 24 | 532 | 340 | 52 | 16 | `#FDF9F2` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### signs-mind — `image18.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 106 | 340 | 100 | 23 | `#FBFAF5` |
| teal | 24 | 216 | 340 | 52 | 15 | `#89B6AF` |
| card | 24 | 280 | 340 | 52 | 15 | `#FBFAF3` |
| card | 24 | 343 | 340 | 52 | 15 | `#FCFAF3` |
| card | 24 | 406 | 340 | 52 | 15 | `#FCF9F3` |
| card | 24 | 470 | 340 | 52 | 15 | `#FDF9F2` |
| card | 24 | 532 | 340 | 52 | 16 | `#FDF9F2` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### signs-behavior — `image19.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 106 | 340 | 100 | 23 | `#FBFAF5` |
| teal | 24 | 216 | 340 | 52 | 15 | `#0D6B63` |
| card | 24 | 280 | 340 | 52 | 15 | `#FBFAF3` |
| card | 24 | 343 | 340 | 52 | 15 | `#FCFAF3` |
| card | 24 | 406 | 340 | 52 | 15 | `#FCF9F3` |
| card | 24 | 470 | 340 | 52 | 15 | `#FDF9F2` |
| card | 24 | 532 | 340 | 52 | 16 | `#FDF9F2` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### intention — `image20.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 106 | 340 | 70 | 23 | `#B5CCC7` |
| teal | 24 | 301 | 340 | 52 | 15 | `#0D6B63` |
| card | 24 | 366 | 340 | 52 | 15 | `#2C5452` |
| card | 24 | 430 | 340 | 52 | 15 | `#FDF9F3` |
| card | 24 | 495 | 340 | 52 | 16 | `#7F9691` |
| card | 24 | 560 | 340 | 52 | 16 | `#EAEAE3` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### strategies — `image21.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 171 | 340 | 55 | 15 | `#FCFBF6` |
| card | 24 | 264 | 340 | 55 | 14 | `#F2F2EC` |
| card | 24 | 331 | 340 | 102 | 20 | `#FDFAF4` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### strategies-custom-dialog — `image22.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 27 | 202 | 335 | 298 | 24 | `#FFFDF8` |

### strategy-details — `image23.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 145 | 340 | 129 | 20 | `#FBFAF5` |
| card | 24 | 286 | 340 | 134 | 20 | `#E0A33C` |
| teal | 24 | 708 | 340 | 60 | 15 | `#FFFDF8` |

### self-reflection — `image24.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 101 | 340 | 116 | 20 | `#FBFAF5` |
| card | 24 | 254 | 340 | 55 | 14 | `#2A5350` |
| card | 24 | 347 | 340 | 55 | 14 | `#FDFBF5` |
| card | 24 | 440 | 340 | 55 | 14 | `#FDFBF5` |
| card | 24 | 532 | 340 | 55 | 15 | `#FEFAF4` |
| card | 24 | 626 | 340 | 55 | 15 | `#FEFAF4` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### exercise-choose — `image25.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 106 | 340 | 70 | 23 | `#548C86` |
| teal | 24 | 188 | 340 | 76 | 15 | `#0D6B63` |
| card | 24 | 277 | 340 | 76 | 15 | `#FCFAF3` |
| card | 24 | 366 | 340 | 76 | 15 | `#FCFAF3` |
| card | 24 | 454 | 340 | 59 | 15 | `#B9C3BE` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### rest-your-mind — `image26.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| teal | 24 | 206 | 340 | 82 | 18 | `#0D6B63` |
| card | 24 | 300 | 340 | 82 | 18 | `#FCFAF4` |
| card | 24 | 394 | 340 | 82 | 18 | `#FDFAF4` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### breathing-478 — `image27.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 470 | 340 | 59 | 15 | `#FCFAF5` |
| card | 24 | 540 | 340 | 59 | 15 | `#FCFAF4` |
| card | 24 | 608 | 340 | 59 | 15 | `#FDFAF4` |
| teal | 6 | 708 | 375 | 60 | 15 | `#0D6B63` |

### breathing-4444-info — `image28.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|

### breathing-4444 — `image29.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| teal | 198 | 110 | 167 | 36 | 8 | `#8DB8B1` |
| card | 24 | 526 | 340 | 54 | 15 | `#E1E1D1` |
| card | 24 | 589 | 340 | 54 | 15 | `#E5DFCD` |
| teal | 6 | 712 | 375 | 60 | 15 | `#0D6B63` |

### before-we-start — `image30.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 141 | 175 | 223 | 47 | 20 | `#D7E3D6` |
| teal | 24 | 175 | 108 | 47 | 19 | `#1E756D` |
| card | 24 | 232 | 340 | 47 | 20 | `#8CA09D` |
| card | 24 | 320 | 340 | 52 | 22 | `#14413F` |
| teal | 234 | 323 | 59 | 47 | 14 | `#FFFDF8` |
| teal | 24 | 708 | 340 | 60 | 15 | `#408982` |

### soundscape-player — `image31.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 416 | 340 | 40 | 2 | `#D56B4F` |
| teal | 24 | 601 | 340 | 60 | 15 | `#FFFDF8` |

### insights — `image32.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| teal | 27 | 108 | 108 | 39 | 10 | `#FFFDF8` |
| card | 22 | 167 | 346 | 171 | 20 | `#FCFAF5` |
| card | 22 | 716 | 346 | 56 | 16 | `#19645F` |

### triggers-and-signs — `image33.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 142 | 340 | 46 | 15 | `#FBFAF5` |
| card | 24 | 200 | 340 | 232 | 20 | `#F4C7A8` |
| card | 24 | 444 | 340 | 232 | 20 | `#F4C7A8` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### strategies-and-actions — `image34.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 142 | 340 | 72 | 16 | `#FBFAF5` |
| card | 24 | 228 | 340 | 273 | 20 | `#D9618B` |
| teal | 148 | 290 | 47 | 27 | 14 | `#0D6A62` |
| card | 24 | 512 | 340 | 192 | 20 | `#FDF9F3` |
| card | 24 | 717 | 340 | 54 | 16 | `#246B66` |

### day-detail — `image35.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 142 | 340 | 160 | 20 | `#FCFAF5` |
| card | 24 | 314 | 340 | 120 | 18 | `#E6E0CB` |
| card | 24 | 446 | 340 | 51 | 16 | `#B7C0B9` |

### your-day — `image36.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 145 | 340 | 196 | 20 | `#FCFAF5` |
| teal | 24 | 708 | 340 | 60 | 15 | `#0D6B63` |

### progress — `image37.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| teal | 27 | 154 | 108 | 40 | 10 | `#4C918A` |
| card | 22 | 214 | 346 | 136 | 18 | `#DEE1D0` |
| card | 22 | 363 | 167 | 109 | 18 | `#FDFAF4` |
| card | 22 | 486 | 346 | 80 | 19 | `#FCF7EF` |
| card | 22 | 706 | 346 | 74 | 20 | `#FEFAF4` |

### reminder — `image38.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 58 | 340 | 101 | 23 | `#FBFBF5` |
| card | 24 | 172 | 340 | 59 | 16 | `#FBFAF4` |
| teal | 24 | 245 | 340 | 59 | 15 | `#FFFDF8` |
| card | 24 | 318 | 340 | 59 | 15 | `#FCFAF3` |
| card | 24 | 390 | 340 | 70 | 15 | `#FCF9F3` |
| teal | 24 | 708 | 340 | 60 | 15 | `#157068` |

### remember — `image39.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 122 | 340 | 56 | 16 | `#416562` |
| card | 24 | 191 | 340 | 56 | 16 | `#FCFAF5` |
| card | 24 | 260 | 340 | 56 | 15 | `#FCFAF4` |
| card | 24 | 328 | 340 | 56 | 15 | `#FCFAF4` |
| card | 24 | 396 | 340 | 56 | 15 | `#F0EFEA` |

### menu — `image40.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 55 | 340 | 94 | 22 | `#F9FBF5` |
| card | 24 | 158 | 340 | 55 | 15 | `#FAFAF4` |
| card | 24 | 223 | 340 | 55 | 15 | `#FBFAF4` |
| card | 24 | 288 | 340 | 55 | 14 | `#FCFAF3` |
| card | 24 | 352 | 340 | 55 | 14 | `#FCFAF3` |
| card | 24 | 417 | 340 | 55 | 14 | `#FDF9F3` |
| card | 24 | 482 | 340 | 55 | 15 | `#FDF9F2` |
| card | 24 | 546 | 340 | 55 | 15 | `#FDF9F2` |
| card | 24 | 610 | 340 | 55 | 15 | `#FDF8F1` |

### settings — `image41.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 145 | 340 | 63 | 15 | `#FAFAF4` |
| card | 24 | 220 | 340 | 63 | 15 | `#FBFAF4` |
| card | 24 | 296 | 340 | 63 | 14 | `#FCFAF3` |
| card | 24 | 371 | 340 | 55 | 14 | `#78918D` |
| card | 24 | 438 | 340 | 55 | 15 | `#FDF9F2` |
| card | 24 | 506 | 340 | 55 | 15 | `#FDF9F2` |
| card | 24 | 573 | 340 | 55 | 15 | `#FDF8F2` |
| card | 24 | 640 | 340 | 55 | 15 | `#FDF8F1` |
| card | 24 | 708 | 340 | 55 | 15 | `#FDF8F1` |

### notifications — `image42.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 145 | 340 | 63 | 15 | `#FAFAF4` |
| card | 24 | 220 | 340 | 63 | 15 | `#FBFAF4` |
| card | 24 | 296 | 340 | 63 | 14 | `#E8EAE4` |
| card | 24 | 371 | 340 | 63 | 14 | `#FCFAF3` |
| card | 24 | 472 | 340 | 55 | 14 | `#2D5552` |
| teal | 24 | 708 | 340 | 60 | 15 | `#53958E` |

### membership — `image43.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 273 | 340 | 118 | 20 | `#FCFAF4` |
| card | 24 | 429 | 340 | 55 | 14 | `#A8B7B3` |
| card | 24 | 522 | 145 | 55 | 14 | `#FEFAF4` |
| teal | 24 | 676 | 340 | 60 | 15 | `#0D6B63` |

### about — `image44.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| card | 24 | 316 | 340 | 198 | 20 | `#FDFAF4` |
| card | 26 | 527 | 338 | 76 | 16 | `#FFFDF8` |
| card | 24 | 618 | 340 | 55 | 15 | `#365C59` |

### logs — `image45.png`

| kind | x | y | w | h | r | fill |
|---|---|---|---|---|---|---|
| teal | 30 | 150 | 105 | 39 | 10 | `#0D6B63` |
| card | 24 | 207 | 340 | 104 | 18 | `#FCFAF5` |
| card | 24 | 323 | 340 | 80 | 18 | `#FCFAF4` |
| card | 24 | 414 | 340 | 80 | 18 | `#FDFAF4` |

<!-- END GENERATED -->

## Known problems in the source document

1. **Fonts and mascot art are not specified.** See above, and the mascot note
   below.
2. **`image28.png` (4-4-4-4 info) is the legacy blue design** — a leftover
   "before" screenshot. `image29.png` next to it is the new style. Built in
   the new style.
3. **Mascot resolution.** The character is ~120 px tall in these screenshots
   and the design uses it at 200 pt+. Cropped-and-upscaled art will be soft at
   hero size. Transparent PNGs at 3× (~660 px tall) would fix it, and nothing
   else would have to change — `WithMeAvatar` is the only widget that touches
   the art.
4. **`image43.png` (membership)** shows card entry for a $4.99/mo plan. No
   payment integration exists; the screen is built as UI only.
