import 'package:flutter/material.dart';
import 'NavBar.dart';
import '../WithMe/Components/CompanionFab.dart';

/// MainScaffold is a reusable widget that provides a consistent layout
/// for screens in the app, including a NavBar at the top and a Drawer menu.
/// It accepts a `body` widget to display the main content of each screen.
class MainScaffold extends StatelessWidget {
  final Widget body; // The main content of the screen
  final String title; // Title displayed in the Drawer header
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Key to control the Scaffold (needed to open the drawer from NavBar)

  MainScaffold({super.key, required this.body, this.title = 'HOWRU.LIFE'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assigns the key so NavBar can control drawer
      backgroundColor: const Color(0xFF708694), // Background color of the screen

      // NavBar at the top of the screen
      appBar: NavBar(scaffoldKey: _scaffoldKey),

      // Drawer menu that slides from the left
      drawer: Drawer(
        backgroundColor: const Color(0xFF708694),
        child: ListView(
          padding: EdgeInsets.zero, // Remove default padding at top
          children: [
            // Drawer header containing the logo and app title
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF546E7A),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false, // Remove all previous routes
                      );
                    },
                    child: Image.asset(
                      'assets/logo.png', // App logo
                      width: 80,
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 8), // Space between logo and title
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false, // Remove all previous routes
                      );
                    },
                    child: Text(
                      title, // App name
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Drawer menu items
            _drawerItem(
              icon: Icons.favorite,
              label: 'With Me — AI Companion',
              context: context,
              onTap: () => _navigateTo(context, '/with-me/chat'),
            ),
            _drawerItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              context: context,
              onTap: () => _navigateTo(context, '/dashboard'),
            ),
            _drawerItem(
              icon: Icons.shopping_cart,
              label: 'Membership',
              context: context,
              onTap: () => _navigateTo(context, '/membership'),
            ),
            _drawerItem(
              icon: Icons.settings,
              label: 'Settings',
              context: context,
              onTap: () => _navigateTo(context, '/settings'),
            ),
            _drawerItem(
              icon: Icons.info,
              label: 'About',
              context: context,
              onTap: () => _navigateTo(context, '/about'),
            ),
            _drawerItem(
              icon: Icons.question_mark,
              label: 'Frequently Asked Questions',
              context: context,
              onTap: () => _navigateTo(context, '/faq'),
            ),
            _drawerItem(
              icon: Icons.logout,
              label: 'Logout',
              context: context,
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/logout', (route) => false),
            ),
          ],
        ),
      ),

      // The main body content of the screen
      body: body,

      // Puts the With Me companion within reach of every wrapped screen.
      floatingActionButton: const CompanionFab(),
    );
  }

  /// Helper method to create a Drawer item with icon, label, and tap behavior
  Widget _drawerItem({
    required IconData icon,
    required String label,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white), // Icon displayed at start
      title: Text(label, style: const TextStyle(color: Colors.white)), // Label text
      onTap: onTap, // Action when tapped
    );
  }

  /// Navigates to a named route and closes the drawer first
  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushNamed(context, route); // Navigate to the specified route
  }
}
