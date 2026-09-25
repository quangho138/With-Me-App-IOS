# Immediate exercise update

The existing Flutter app is preserved. The changed product screen is BreathingScreen; Before we start continues to supply the selected sound, cycle count, and breathing pattern.

## Experience

- Original animated vector scenes for Waves, Birds (including a nest), Forest, Rain (including a waterfall), and Fire. None provides a quiet landscape with no audio.
- Breathing orb expands on inhale, holds its size during the full hold, contracts on exhale, and remains small during the final box-breathing rest. A moving marker shows phase progress.
- Both 4-7-8 and 4-4-4-4 patterns; selected cycle count; phase countdown; session progress; completion and replay.
- Pause/resume preserves fractional seconds. Restart and pattern changes reset the session. App interruptions pause it. Exiting releases the audio player.
- Mute and volume controls, recoverable audio failure message, manual motion toggle, and system reduced-motion support.
- Existing Quicksand/Yellowtail fonts, mascot, teal buttons, cream cards, and mint/peach background.

## Audio

Five original synthesized stereo ambience loops are bundled in assets/audio. They work offline and use no third-party recordings. They are synthesized interpretations of nature, not field recordings. The reproducible generator is tool/generate_ambience.mjs. Audio playback uses audioplayers (resolved version recorded in pubspec.lock).

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
