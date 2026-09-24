# With Me V1 — what was built, and what is still open

Branch `design-v1-exact`, off `BhavB13/with-me-companion-ui`. Local commits
only — nothing pushed.

## The one thing to know first

**`WITH ME Complete App Design V1.docx` contains no specifications.** It is 45
screenshots and 9 section headings — no measurements, no colour values, no font
names, no Figma link, no redlines. Each screenshot is about 330 × 640 px.

So "match the design exactly" could not be read off the document. Every number
in the app was **measured** off the images instead:

| | |
|---|---|
| Device frame inner screen | **290 × 590 px**, identical in all 45 mockups |
| Reference device | iPhone 14/15 — **390 × 844 pt** |
| Conversion | **× 1.3448** |

`tool/measure_mockups.py` does the measuring and `docs/WITH_ME_SPEC_V1.md`
records the result — the redline document the .docx should have been. The
numbers in the code come from there, not from taste. If the product owner
supplies the real design source, re-run the script and diff it against the
spec before changing anything.

One consequence to carry: the mockup screen is 2.034:1 and a real iPhone 14 is
2.164:1, so there is ~50 pt of vertical slack on a real device. `WithMeScaffold`
absorbs it in one flexible gap above the bottom action. Widths and type sizes
convert exactly.

## What the app is now

The design covers the whole product, so With Me stopped being a section beside
the legacy HOWRU.LIFE screens and became the app. `main.dart` opens on the
welcome screen, the theme lives on `MaterialApp`, and the blue-grey
presentation layer is gone.

All 45 screens are built. The check-in still writes through the existing
`insertMood`, `insertControlGauge`, `insertStressor` and `insertReflection`,
and the `YYYY-MM-DD` date format those queries depend on is untouched.

`lib/Database/LocalDatabase.dart` gained three **additive** range reads —
`getMoodsBetween`, `getControlGaugesBetween`, `getStressorsBetween` — because
the calendar, dashboard and progress screens each cover a span and asking day
by day meant 30 to 365 round trips to open one screen. Same tables, same keys,
no schema change, nothing existing altered.

Dashboards read real rows. On a fresh install the insights screen says "No
check-ins in the last 30 days yet" rather than inventing the mockup's
40/20/20/10/10 split.

```
flutter analyze   0 errors, 0 warnings
flutter test      3 passing, 1 suite skipped (the golden capture — see below)
flutter build web working; runs in Chrome with no console errors
```

## How the build is checked against the document

Not by eye. Two commands:

```bash
flutter test --tags golden --run-skipped --update-goldens
python tool/compare_screens.py --sheets
```

The first renders all 45 screens at 390 × 844 with the real fonts, real
device insets and a week of seeded check-ins. The second pairs each capture
with its mockup, runs the same rectangle detection over both, and prints the
differences — comparing each element against whichever edge it is anchored to,
since the device is ~50 pt taller than the mockup. `--sheets` also writes
side-by-side images to `build/compare/`.

The golden suite is tagged and skipped by a plain `flutter test`: the screens
print real dates ("Today", "Yesterday", "Sept 12"), so a capture taken today
does not match one taken tomorrow. It is a comparison tool, not a regression
gate, and `dart_test.yaml` says so.

Running that found, and this branch fixed: an oversized mascot on every screen,
30–365 sequential database queries to open one screen, the pattern switcher on
the wrong breathing screen, both breath shapes at two thirds their size, a
blank page for a day with no entry, and logs listed oldest-first with all five
reflection prompts crammed into each card.

### What the numbers missed

The rectangle report is blind to colour, wording and overflow, so a second
pass read all 28 side-by-side sheets by eye. The count barely moved (71 → 70)
while six real defects came out, which is the point — none of these were
geometry:

- **`WithMeText.caption` was `inkFaint`.** 2.6:1 on cream, under the 4.5:1
  floor, on 13 pt text — while `body` at 15 pt already sat on the darker
  `inkSoft`. The smaller size was carrying the weaker colour. Zooming
  image7's "Rough / Okay / Good" shows dark slate glyphs, not pale grey.
  Now `inkSoft`, which affects 29 call sites.
- **"Keep going!" on the mint stat tile** inherited that same grey, landing
  at roughly 2:1 against its own fill. Teal on the tinted tile only.
- **The medical disclaimer on image44** was the faintest text on the screen.
  Sampling the mockup puts both of that screen's text blocks at `ink`; the
  build had the disclaimer on `inkSoft`. It is the one clinical caveat in the
  app and should not be the hardest line to read.
- **The Signs mini-chart on image35** drew four bars in one tint. The design
  runs them across the series palette — mint, peach, pink, coral — so
  `BarChart` gained an optional per-bar `colors`.
- **"Thought challenging" ellipsised on image34.** `ChartLegend` pinned every
  entry to half the card; the design lets each size to its own label and lets
  the `Wrap` pick the line breaks. Now capped at the card's inner width so a
  long label takes its own line instead of overflowing.
- **The mood card came out 111 pt against a measured 170.** The caption
  ("Pretty good today") was there all along but only appears once a mood is
  picked, and the capture opened the screen untouched. `_drivers` in the
  golden suite now taps the fourth swatch first. That exposed the real gap:
  the design insets the swatch row 24 pt from the card edge — the pink circle
  starts at x = 48 against a card edge of 24 — where `WithMeCard`'s default
  is 16, which spread the five circles wider than the design draws them.

Two fixture bugs came out with them. The seed wrote the reflection *prompts*
into the answer columns, so every log card read "What took the most out of
me?" while every other seeded field held a real value; and it stamped 9:41 on
all seven days, which made the screen look like it printed a constant. Both
now carry values in the voice image45 uses, still derived from the index so
two captures on the same day stay identical.

### Where the mockups disagree with each other

Two differences are the document contradicting itself, not the build drifting.
Changing either would break a screen that currently matches exactly, so both
are left as they are:

- **The date-range card.** image33 draws it as a row — "DATE RANGE" left,
  "Last 14 days" right — and image34 draws it centred over two lines with a
  date span. `DateRangeCard` is shared and follows image33, which it matches
  exactly.
- **Option row height.** 52 on image25 and image26, which measure clean; 59
  on image38. `kOptionRowHeight` stays at 52 and image38's five rows report
  −7.1 each.

One number is honest rather than matching: the second mood bar on image37 is
a short nub because a seeded "Rough" day scores 1 of 5. The mockup's sample
data had no low day. Raising the floor would make the chart overstate the
mood, so the bar stays short.

## Check In, the calendar, and the way back

Three changes on request, after the design pass. Each departs from the
mockups on purpose.

**The daily check-in moved to the calendar.** Selecting *today* on the monthly
calendar lists every page of the daily check-in - "Hello Maya, how are you
feeling today?", the 1-5 stress scale, motivation, and on through the
strategy detail, thirteen in all. Each row opens straight onto that page, and
"Start today's check-in" walks them in order. Back from the page a visit
started on returns to the calendar rather than into pages the user skipped.
Any other day still opens its detail. The flow is `DailyCheckInScreen`
(`/daily-check-in`); `pageTitles()` is the list the calendar shows and must
stay in step with its `_step` switch.

**Check In is the five W's.** The "CHECK IN" action now opens the
self-reflection on its own: Who, What, Where, When and Why, each a dropdown of
questions - the original app's Self-Reflection screen, rebuilt in the V1 page
style (`image24`, plus a title row and a back chevron). One reflection a day:
reopening shows today's choices and saving replaces them. The questions are
the ones image24 shows ("Who did I lean on today?" ...), in
`kReflectionPrompts`. The original app used a different, more general set
("Who inspires you the most and why?" ...); swapping to those is a change to
that one map. The page is 4 pt tighter between dropdowns than image24 so all
five fit above the button with the extra title row.

**Every screen has a way back.** `WithMeScaffold` now shows the chevron
whenever the navigator can pop, without each screen having to ask - beside the
title, beside the lockup when there is no title, or alone top-left when there
is neither. `onBack` still overrides it where back means something else (the
check-in steps). The soundscape draws its own scene, so it adds the chevron
itself, in white. Root screens - welcome, and home after signing in - have
nothing behind them and show none. This puts chevrons on screens the mockups
drew without one (image6, image32 and others). The chevron is labelled "Back"
for screen readers.

Verified by driving the web build through Flutter's semantics tree in
headless Chromium, 21 checks: all five W's chosen, saved, and restored on
reopening; today's list present only once today is picked, reaching the last
page; a listed page and "Start" both opening with a chevron; back stepping
within the flow, then to the calendar, then home; and back present on Menu,
Insights and Exercises. The nine screens that matched their mockups before
still match.

## The mascot moves, and the check-in waits for answers

Second round of product-owner changes.

**Animation.** `MascotPainter` draws a `MascotPose` - arm angles, lean, hop,
squash, sit, walk phase, face - and `WithMeAvatar` turns time into poses.
Everywhere it breathes, blinks on an irregular rhythm, glances about and
fidgets its hands. On Home (`MascotBehavior.roam`) it runs a loop: a wave
hello with a wink, a walk to the right edge, a stumble that plops it onto
its behind with dizzy stars, a spring back up and a shake-off, a walk to the
left, another wave, and back to the middle. The walk range stops short of
each edge by the reach of a flung-out arm. Reduced motion holds a still
pose.

**Reactions in the check-in.** Each page's mascot reads that page's answer
(`_reaction` in `DailyCheckInScreen`): idle and fidgeting until something is
picked, then **sad** for hard answers (Rough, stress 4-5, a low rating),
a **smirk** for middling ones (Okay, a 3, choosing body/mind/...), and a
**happy** hop for good ones. Naming a stressor or a sign gets gentle
concern. `sad` and `smirk` are new `MascotExpression`s.

**Intention to change** replaces "What is your intention today?". A dial
(`ReadinessGauge`) the user drags: mint / peach / coral bands, the needle
pivoting under a fading dial face, read as Not ready yet ... Very ready,
with a line of reassurance per level. Geometry measured off the screen the
product owner supplied. The old list (`kIntentions`) is unused.

**One signs page, chosen.** Body / Feelings / Mind / Behavior is now a
choice - rebuilt as image15 actually draws it, left-aligned 172 pt pills
with one selected - and only that dimension's page follows. The flow is
ten pages. The calendar lists the dependent page as "How stress is showing
up for you"; opening it starts at the choice. The chosen dimension's signs
are now saved with the stressor; before this, signs were never written at
all.

**Continue waits.** Every check-in page keeps Continue disabled until it is
answered; Back always works. A disabled `WithMeButton` is still announced to
screen readers as a (dimmed) button.

Verified: 33 captures, and two click-throughs of the web build through
Flutter's semantics tree - 17 checks on the gating, the signs routing and
the dial, and the earlier 21 on navigation. The nine screens that matched
their mockups still do.

## Decisions you should know about

**Fonts are a guess.** The design names none. Quicksand (UI) and Yellowtail
(the script wordmark and accent lines) were identified from the renders and
shipped as assets. If the real faces exist, changing `WithMeText.ui` and
`WithMeText.script` plus the `fonts:` block is the whole job.

**The mascot is drawn, not a picture.** The document ships no character
art; the first build cut one pose out of `image1.png`, which could neither
change its face nor move its limbs. At the product owner's request it now
comes from `MascotPainter` - the same leaf crown, hibiscus, lei and belly
swirl, drawn in code - so it can animate. It looks flatter than the 3D
render in the mockups; that trade was chosen deliberately, and it is the same
character on every screen, header badge included. `assets/mascot/*.png` and
`tool/extract_mascot.py` are no longer used by the app.

**There is no login form in the document.** `image1` has a "Log In" button;
`image2` and `image3` are signup and password reset. `WithMeLoginScreen` is
built to match those two exactly rather than invented.

**`image28` is the old blue design** — a leftover "before" screenshot sitting
next to the new-style `image29`. Rebuilt in the V1 style as
`BoxBreathingInfoScreen`.

**The menu's "Help" row had no screen.** Rather than delete the old FAQ answers
along with the rest of the legacy UI, they were kept and restyled as
`HelpScreen`.

## Deliberately inert

These are drawn because the design draws them, and they do nothing:

- **Membership (`image43`)** shows card, expiry and CVC fields for a $4.99/mo
  plan. There is no payment integration; nothing collects or transmits card
  details and "Start Plus" charges nothing. Do not wire this up without a real
  payment provider and a review of what the screen implies.
- **Notifications (`image42`) and the reminder (`image38`)** are preferences
  with no scheduler behind them — the project has no notifications plugin.
- **Soundscapes (`image31`)** run on a timer, not audio. `_tick` is the seam.
- **"Continue with Google", Privacy & data, Export, Terms** all say so when
  tapped.

## Still open

0. **iOS has never been built** — it needs macOS and Xcode, so it cannot be
   done from this machine. Android builds; nothing has been run on a physical
   device.
1. **Strategy ratings have no table.** `LocalDatabase` covers reflections,
   moods, the control gauge and stressors. The strategies screen (`image21`)
   and the Strategies & Actions breakdown (`image34`) have nowhere to write,
   so the breakdown shows the vocabulary rather than real use. This is the
   biggest gap between what the design promises and what the app can deliver.
2. **Passwords are still plaintext** in the `users` table. Carried over, not
   introduced here, and it should not ship.
3. **No safety/crisis layer.** Flagged in the previous pass and still true.
   Nothing in V1 addresses it either.
4. **Signs are stored in the stressor `detail` column**, comma-joined, because
   there is no signs table. The Triggers & Signs screen parses them back out.
   It works; it is not a schema.

## Platforms

| | |
|---|---|
| **Web (Chrome)** | Builds, runs and **persists** — sqlite compiled to WebAssembly, stored in IndexedDB (`sqflite_common_ffi_web`). Ships with a demo account; see below. |
| **iOS** | The real target. Cannot be built from Windows; needs macOS and Xcode. |
| **Android** | Builds. `flutter build apk --debug` produces a 157 MB debug APK with the fonts and mascot bundled. Not run on a device — none attached. |
| **Windows desktop** | Needs the Visual Studio "Desktop development with C++" workload, which is not installed. |

Every database call is wrapped: a failure shows a message and leaves the
screen on its empty state, so a database that will not open never traps the
user.

### The demo account

For showing the app, the browser build signs in with:

```
demo@withme.app  /  withme123
```

`lib/Database/DemoAccount.dart` creates it on launch along with a week of
check-ins (the user is "Maya", as in the mockups). It tops up any of the last
seven days that has no mood on every launch, so "this week" stays populated
whenever the demo happens; **today is left empty** so a check-in can be done
live, and a day with a real entry is never touched. It is on by default only
in the browser — a phone gets it only when built with
`--dart-define=WITHME_DEMO=true`, so a real install never picks up invented
rows.

The browser engine needs `web/sqlite3.wasm` and `web/sqflite_sw.js`, which
belong in the repo; after upgrading `sqflite_common_ffi_web`, regenerate them with
`dart run sqflite_common_ffi_web:setup`. The package is imported through
`WebFactory.dart`'s conditional export, so phone builds never compile it.

Wiring this up exposed a race that was always there: `DatabaseHelper` cached
the *database*, not the open, so two callers arriving before the first open
finished each started their own and the second threw. On a phone the open is
fast enough to hide it; in the browser the first open loads WebAssembly and
takes seconds, and a sign-in during that window failed with "Couldn't read
your account". It now caches the future.

Verified in headless Chromium: wrong password rejected, demo sign-in lands on
"Welcome back, Maya!", logs / progress / insights / calendar all populated,
and a relaunch on the same profile keeps the data without duplicating it.
(Point a persistent test profile at a short path — deep in a long temp
directory IndexedDB exceeds Windows' 260-character limit and fails with
"Internal error", which reads like an app bug and is not one.)

### What the Android build needed

The project pinned Gradle 8.12, AGP 8.9.1 and Kotlin 2.1.0. Flutter 3.47.4
requires at least 8.14.0, 8.11.1 and 2.2.20, so the build failed immediately on
version checks — it could not have worked as delivered. All three are bumped on
this branch.

Flutter then warns that it will *soon* require Gradle 9.1.0, AGP 9.0.1 and
Kotlin 2.3.20. The current versions build today; the next SDK bump will want
those.

**Watch the disk.** The C: drive on this machine runs at 99–100% full (3.6 GB
free of 475 GB at the time of writing). The first build attempt ran out of
space mid-way and left a truncated NDK at
`%LOCALAPPDATA%/Android/sdk/ndk/28.2.13676358` — an empty directory with
only `.installer` in it. Every later attempt then failed with `[CXX1101] NDK …
did not have a source.properties file`, which reads like an SDK problem rather
than a disk one. Deleting that directory and rebuilding let the NDK download
properly and the build went green. If it happens again, that is the fix.

## Running it

Flutter is at `C:\flutter\bin` and is **not on PATH**.

```bash
C:/flutter/bin/flutter run -d chrome
```

To rebuild the web bundle and serve it:

```bash
C:/flutter/bin/flutter build web --no-tree-shake-icons && python -m http.server 8137 --directory build/web
```

Routes are hash-based — `http://127.0.0.1:8137/#/home`, `#/check-in`,
`#/calendar`, `#/menu`, `#/settings`, `#/progress`, and so on; `main.dart` has
the full list. Check screens at a 390 × 844 viewport.

To regenerate the design artefacts:

```bash
unzip -oq "WITH ME Complete App Design V1.docx" -d build/design_v1
python tool/measure_mockups.py > build/measurements.txt
python tool/extract_mascot.py --write
```

`build/` is gitignored; the .docx is the source of truth.
