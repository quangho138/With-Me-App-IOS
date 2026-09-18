import 'package:flutter/material.dart';

import '../WithMe/Theme/WithMeTheme.dart';

/// Top navigation styled to match the warm "With Me" visual language.
class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  // The shared bar remains a menu by default; child flows can request a back arrow.
  final bool showBackButton;

  const NavBar({
    super.key,
    required this.scaffoldKey,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: WithMeColors.creamLight.withValues(alpha: 0.94),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Text(
        'HOWRU.LIFE',
        style: WithMeText.sectionLabel.copyWith(
          color: WithMeColors.teal,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
      leading: IconButton(
        tooltip: showBackButton ? 'Back' : 'Menu',
        icon: Icon(
          showBackButton ? Icons.arrow_back_rounded : Icons.menu_rounded,
          color: WithMeColors.teal,
        ),
        onPressed: showBackButton
            ? () => Navigator.maybePop(context)
            : () => scaffoldKey.currentState?.openDrawer(),
      ),
      actions: const [SizedBox(width: 48)],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: WithMeColors.teal.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
