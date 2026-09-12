# With Me — AI Companion UI

UI-only implementation of the "With Me" companion described in the product
owners' spec (`FIU WITH ME.pdf`). No conversation engine, no persistence, no
network calls — those plug in behind the seams noted below.

## Status

| | |
|---|---|
| Scope | Presentation layer only |
| New dependencies | **None** |
| Flutter | 3.47.4 stable, installed at `C:\flutter` |
| `flutter analyze` | Clean — 0 errors, 0 warnings in `lib/WithMe/` |
| Run | Verified in Chrome; every screen and the full check-in driven end to end |

Windows desktop builds need the Visual Studio "Desktop development with C++"
workload, which is not installed. Web and Android are unaffected.

`flutter pub get` reports *"Building with plugins requires symlink support"*
until Developer Mode is enabled (`start ms-settings:developers`). The web build
does not need it; an Android or iOS build will.

## Where it lives

Everything new is under `lib/WithMe/`, isolated from the legacy
HOWRU.LIFE screens so the two can coexist.

```
lib/WithMe/
├── Theme/WithMeTheme.dart          design tokens: colour, type, spacing, motion
├── Mascot/
│   ├── MascotExpression.dart       the 7 emotional states
│   ├── MascotPainter.dart          vector drawing of the character
│   └── WithMeAvatar.dart           animation driver + circular badge variant
├── Components/
│   ├── WithMeBackdrop.dart         painted sunset-beach scene
│   ├── SpeechBubble.dart           cream bubble with typewriter reveal
│   ├── WithMeControls.dart         scale, option tile, grid card, button, gauge
│   ├── WithMeWordmark.dart         logo lockup + "I listen / I understand" card
│   └── CompanionFab.dart           floating launcher for the legacy screens
├── Data/CheckInSteps.dart          the check-in questions, as data
└── Screens/
    ├── WithMeWelcomeScreen.dart    storyboard 1
    ├── WithMeGreetingScreen.dart   storyboard 2
    ├── CheckInScreen.dart          storyboard 3–10
    ├── ActionPlanScreen.dart       the plan + "what next" options
    ├── CompanionChatScreen.dart    free-form conversation
    └── MascotGalleryScreen.dart    expression review surface
```

## Routes

| Route | Screen |
|---|---|
| `/with-me` | Welcome / sign-in |
| `/with-me/greeting` | Greeting, tap-to-talk |
| `/with-me/chat` | Conversation |
| `/with-me/check-in` | Guided check-in |
| `/with-me/avatar` | Expression gallery (demo / review) |

Entry points added to the existing app: a drawer item and a floating
companion button in `MainScaffold`, and a "Talk to With Me" button at the top
of the home screen.

## The avatar

Drawn in code (`MascotPainter`), not shipped as images.

The spec PDF contains a single 1024×1536 raster with the beach baked into the
background; the expression sprites in it are roughly 60 px and there are no
transparent cutouts. Nothing in it is usable as a production asset. Drawing
the character instead gives:

- seven expressions that actually animate, rather than five static crops
- crisp rendering from a 32 px chat badge to a 220 px hero
- no asset payload and no `pubspec` changes
- a face that reacts per question during the check-in

Four independent clocks run the character so it never looks like a loop:
`breath` (always), `blink` (re-scheduled at a randomised interval),
`gesture` (waves, hops, thought dots), `talk` (mouth, while speaking).

**When the product owners deliver real art**, replace the `CustomPaint` inside
`WithMeAvatar.build` with an `Image.asset` / Rive / Lottie keyed off the same
`MascotExpression` enum. Nothing else has to change — every screen talks to
`WithMeAvatar`, never to the painter.

## Seams for the next pass

| What | Where |
|---|---|
| Conversation engine | `CompanionChatScreen._reply` — one method, returns a `ChatMessage` |
| Persisting answers | `CheckInAnswers` in `Data/CheckInSteps.dart` |
| Adding/reordering questions | the `kCheckInSteps` list — data, not screens |
| Voice input | the mic buttons in `WithMeGreetingScreen` and the chat composer |
| Safety / crisis layer | **not built** — see below |

### Safety layer is not implemented

The spec's Layer 6 (Safety & Boundary) has no UI yet. Before this ships to any
real user, crisis-keyword detection must run *before* any reply is generated,
and route to a calm screen with 988 / Crisis Text Line. The `concerned`
expression exists for exactly this and is deliberately not playful.

## Fixes made to the existing app

These were blocking and are unrelated to the companion:

1. `LocalDatabase.dart` moved into `lib/Database/` — it shipped outside `lib/`,
   so the project could not compile as delivered.
2. `LoginScreen` / `SignUpScreen` imported `../database/localdatabase.dart`
   while everything else imported `../Database/LocalDatabase.dart`. Dart treats
   those as two separate libraries, giving two unrelated `DatabaseHelper`
   classes. Both now use the same path.
3. `main()` deleted the SQLite database on every launch. Removed — the
   companion needs history to survive a restart.

Still outstanding: passwords are stored in plaintext in the `users` table.

## Running it

Flutter is at `C:\flutter\bin` but is **not on PATH** — add it, or prefix:

```bash
C:/flutter/bin/flutter run -d chrome
```

To rebuild the web bundle and serve it:

```bash
C:/flutter/bin/flutter build web --no-tree-shake-icons && python -m http.server 8099 --directory build/web
```

Routes are hash-based, e.g. `http://127.0.0.1:8099/#/with-me/avatar`.
