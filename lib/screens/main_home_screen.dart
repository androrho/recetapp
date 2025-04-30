import 'package:flutter/material.dart';

import 'bottom_screens/community_screen.dart';
import 'bottom_screens/my_account_screen.dart';
import 'bottom_screens/my_recipes_screen.dart';

/// Main screen with bottom navigation.
///
/// Shows three tabs:
///  - Mis recetas (MyRecipesScreen)
///  - Comunidad (CommunityScreen)
///  - Mi cuenta (MyAccountScreen)
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  /// Index of the currently selected tab.
  int _selectedIndex = 0;

  /// The widgets shown for each tab.
  final List<Widget> widgetOptions = const [
    MyRecipesScreen(),
    CommunityScreen(),
    MyAccountScreen(),
  ];

  /// Called when the user taps a bottom navigation item.
  /// Updates the selected index to show the right tab.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar title
      appBar: AppBar(
        title: const Text('Recetapp'),
      ),
      body: widgetOptions[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Mis recetas',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Comunidad',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Mi cuenta',
          ),
        ],
      ),
    );
  }
}