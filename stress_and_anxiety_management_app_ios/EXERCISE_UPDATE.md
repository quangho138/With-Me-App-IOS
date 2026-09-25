# Immediate exercise update

The existing Flutter app is preserved. The changed product screen is BreathingScreen; Before we start continues to supply the selected sound, cycle count, and breathing pattern.

## Experience

(Updated 25 Sep 2026 when merged into develop, to match the code as it now is.)

- Four exercises: De-stress Your Day (4-7-8), Ease Your Sleep (4-7-8), Strengthen Your Focus (4-4-4), and the Physiological Sigh (deep inhale, two quick inhales, long exhale, with a recorded breath track and animated lungs). Box breathing (4-4-4-4) is still reachable from its info screen and the pattern tabs.
- Background: silent Mixkit nature footage for Waves, Birds, Forest, Rain and Fire, with a plain dark colour for None or when video cannot load.
- A dot moves along a triangle (or a square for box breathing) to show each phase, with the phase name and length above it. Cycle count, completion and replay.
- Pause/resume preserves fractional seconds. Restart and pattern changes reset the session. Leaving the app pauses it. Exiting releases the audio player.
- Recoverable audio failure message. The Motion on/off toggle and the system reduced-motion setting freeze the nature video on one frame.
- There are no in-app mute or volume controls on the breathing screen (the sigh screen has a breath sound on/off button).

## Audio

The five nature sounds in assets/audio are Mixkit free sound effects, bundled as WAV files. Sources for each are listed in tool/media-source/README.md. Mixkit's free license needs no attribution but does not allow sharing the raw files on their own, so the raw downloads are not committed. sigh-breath.wav is built from a CC0 recording (see assets/audio/SIGH-CREDITS.md) by tool/make_sigh_audio.py. Playback uses audioplayers.

Known issue: the WAV files are large (birds.wav is about 55 MB). Converting them to AAC or OGG would shrink the app a lot.

## Run

From stress_and_anxiety_management_app_ios:

    flutter pub get
    flutter run

Exercise-only preview, using the actual product screens:

    flutter run -d chrome -t tool/exercise_preview.dart

On a Mac with Xcode and an attached iPhone or simulator, run flutter pub get and flutter run -d <device>. Signing and device provisioning remain the responsibility of the existing app setup.

On Windows, Flutter may request Developer Mode for native plugin symlinks. No system setting was changed during this task. Web compilation and Flutter tests were verified with --no-pub after dependency resolution.

## Verification

- 16 tests passed: exact timing, pause/resume, both patterns, completion/replay, lifecycle pause, setup selection propagation, all six scenes, 320x568 with 170% text, pattern switching, motion toggle, and the existing welcome/layout checks.
- Full app web build succeeded. Exercise-only web build succeeded.
- Static analysis reports no errors or warnings; informational style lints remain (primarily the existing PascalCase filenames).
- Browser exercise session reached completion with no reported browser errors.
- Visual captures are in test/exercise_previews.

Commands:

    flutter test --no-pub test/breath_session_test.dart test/breathing_experience_test.dart test/widget_test.dart
    flutter test --no-pub --dart-define=CAPTURE_EXERCISE=true test/breathing_experience_test.dart
    flutter analyze --no-pub --no-fatal-infos
    flutter build web --no-pub

## Verification limits

This Windows environment cannot build or sign an iOS binary. Physical iPhone audio routing, silent-switch behavior, interruptions, and performance still need device verification. Browser checks confirm the exercise runs without reported playback errors; they do not constitute an acoustic quality review. Facebook reference reels were blocked by a login wall, so the design follows the written request rather than a verified frame-for-frame comparison.
