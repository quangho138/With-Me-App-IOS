import 'package:flutter/material.dart';

import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Theme/WithMeTheme.dart';

/// `image43.png` — Membership.
///
/// **UI only.** The mockup shows card, expiry and CVC fields for a $4.99/mo
/// plan, but there is no payment integration in the project and nothing here
/// collects or transmits card details — the fields are inert and "Start Plus"
/// does not charge anything. Flagged in `docs/WITH_ME_SPEC_V1.md`.
class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  static const String route = '/membership';

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: 'Membership',
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(
        label: 'Start Plus',
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payments are not connected in this UI pass.'),
          ),
        ),
      ),
      footnote: Text(
        'Cancel any time. Your logs stay yours either way.',
        textAlign: TextAlign.center,
        style: WithMeText.caption.copyWith(color: WithMeColors.inkSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Plan(
            name: 'Free forever',
            blurb: 'Check-ins, daily logs, breathing exercises and the '
                'calendar. No card needed.',
            tinted: true,
          ),
          const SizedBox(height: WithMeSpace.md),
          _Plan(
            name: r'Companion Plus · $4.99/mo',
            blurb: 'All soundscapes · guided meditations · full insight '
                'history · PDF summaries to share',
          ),
          const SizedBox(height: WithMeSpace.lg),
          const _CardFields(),
        ],
      ),
    );
  }
}

class _Plan extends StatelessWidget {
  const _Plan({required this.name, required this.blurb, this.tinted = false});

  final String name;
  final String blurb;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return WithMeCard(
      color: tinted
          ? WithMeColors.mint.withValues(alpha: 0.45)
          : WithMeColors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: WithMeText.option.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: WithMeColors.teal,
            ),
          ),
          const SizedBox(height: WithMeSpace.sm),
          Text(blurb, style: WithMeText.body.copyWith(color: WithMeColors.ink)),
        ],
      ),
    );
  }
}

/// Deliberately display-only — see the class comment on [MembershipScreen].
class _CardFields extends StatelessWidget {
  const _CardFields();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Card', style: WithMeText.fieldLabel),
        const SizedBox(height: 6),
        const _Inert(text: '•••• •••• •••• ••••'),
        const SizedBox(height: WithMeSpace.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expiry', style: WithMeText.fieldLabel),
                const SizedBox(height: 6),
                const SizedBox(width: 92, child: _Inert(text: 'MM/YY')),
              ],
            ),
            const SizedBox(width: WithMeSpace.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CVC', style: WithMeText.fieldLabel),
                const SizedBox(height: 6),
                const SizedBox(width: 68, child: _Inert(text: '•••')),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Inert extends StatelessWidget {
  const _Inert({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        height: kSettingsRowHeight,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.lg),
        decoration: BoxDecoration(
          color: WithMeColors.cream,
          borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
          boxShadow: WithMeSpace.cardShadow,
        ),
        child: Text(
          text,
          style: WithMeText.option.copyWith(color: WithMeColors.inkFaint),
        ),
      );
}
