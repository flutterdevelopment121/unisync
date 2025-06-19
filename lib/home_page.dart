import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase
import 'main.dart'; // To access the Supabase client instance
import 'dart:ui'; // For blur effect (glassmorphism)

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // 0: Notes, 1: Home, 2: Profile

  Future<void> _signOut(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
    }
  }

  // Widget selection logic
  Widget _getSelectedPage(int index) {
    final user = supabase.auth.currentUser;
    switch (index) {
      case 0:
        return Center(
          child: Text(
            'Notes Page',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
      case 1:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to UniSync!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              if (user != null)
                Text(
                  'Logged in as: ${user.email}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
            ],
          ),
        );
      case 2:
        return Center(
          child: Text(
            'Profile Page',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
      default:
        return _getSelectedPage(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniSync Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _getSelectedPage(_selectedIndex),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          bottom: 25.0,
          left: 16,
          right: 16,
          top: 8,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    icon: Icons.notes_outlined,
                    selectedIcon: Icons.notes,
                    label: 'Notes',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    label: 'Home',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    label: 'Profile',
                    index: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable nav item builder
  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior
          .opaque, // Ensures the GestureDetector captures taps within its bounds
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        // Make the container transparent so it doesn't alter the visual appearance
        color: Colors.transparent,
        // Expand the container to fill available space within the Row's distribution
        // and the parent Container's height.
        // Adding some padding can also help define the touch area.
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize
              .min, // Ensure Column doesn't try to expand infinitely
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? Theme.of(context)
                        .colorScheme
                        .secondary // Selected label color
                  : Theme.of(
                      context,
                    ).colorScheme.tertiary, // Default icon color
              size: isSelected ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Theme.of(context)
                          .colorScheme
                          .secondary // Selected label color
                    : Theme.of(
                        context,
                      ).colorScheme.tertiary, // Default label color
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
