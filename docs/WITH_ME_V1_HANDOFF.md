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

## Decisions you should know about

**Fonts are a guess.** The design names none. Quicksand (UI) and Yellowtail
(the script wordmark and accent lines) were identified from the renders and
shipped as assets. If the real faces exist, changing `WithMeText.ui` and
`WithMeText.script` plus the `fonts:` block is the whole job.

**The mascot is cut out of the screenshots.** There is no character art
anywhere — the concept PDF has the character baked into a beach background.
`tool/extract_mascot.py` lifts the largest clean instance off the page
gradient (`image1.png`, 103 × 146 px), closes the mask, mattes it and upscales
3×. Two consequences:

- It is **one pose**. `MascotExpression` still picks the *motion* — a
  celebrating hop reads differently from an idle breath — but the face does not
  change.
- At the 200 pt hero size the design uses, upscaled 103 px art is soft.

Transparent PNGs at 3× (~660 px tall), one per expression, would fix both and
change nothing outside `WithMeAvatar`. `MascotPainter` is kept unused as the
vector fallback.

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
| **Web (Chrome)** | Builds and runs. Every screen renders and navigates. **Cannot persist** — sqflite has no web implementation, so anything that writes fails. |
| **iOS** | The real target. Cannot be built from Windows; needs macOS and Xcode. |
| **Android** | Builds. `flutter build apk --debug` produces a 157 MB debug APK with the fonts and mascot bundled. Not run on a device — none attached. |
| **Windows desktop** | Needs the Visual Studio "Desktop development with C++" workload, which is not installed. |

Because the browser cannot persist, every database call is now wrapped: a
failure shows a message and leaves the screen on its empty state. Before that,
"Create account" sat disabled for ever on web with an uncaught exception behind
it. That guard matters on a real device too — a database that will not open
should not trap the user.

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
`%LOCALAPPDATA%\Android\sdk
dk8.2.13676358` — an empty directory with
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
