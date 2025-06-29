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

  // Widget selection logic
  Widget _getSelectedPage({
    required int index,
    required double topPadding,
    required double bottomPadding,
    required double topPanelHeight,
  }) {
    final user = supabase.auth.currentUser;
    switch (index) {
      case 0:
        return Padding(
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          child: Center(
            child: Text(
              'Notes Page',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        );
      case 1:
        return ListView(
          // Add padding to the top and bottom to avoid content being hidden.
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          children: [
            // This is the new, non-overlay rectangle.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                height: topPanelHeight / 2,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Center(
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
                  const SizedBox(height: 400), // To ensure scrolling
                  const Text('More content down here...'),
                ],
              ),
            ),
          ],
        );
      case 2:
        return Padding(
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          child: Center(
            child: Text(
              'Profile Page',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        );
      default:
        return _getSelectedPage(
          index: 1,
          topPadding: topPadding,
          bottomPadding: bottomPadding,
          topPanelHeight: topPanelHeight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the height for the top panel to easily reuse it.
    // I've increased it from 1/3 to 1/2.5 (40%) of the screen height.
    final topPanelHeight = MediaQuery.of(context).size.height / 2.5;

    // Define constants for the bottom navigation bar to calculate padding
    const double navBarHeight = 70;
    const double navBarPadding = 25.0; // Symmetrical padding around the nav bar

    // Define a single blur value for a consistent glass effect.
    const double glassBlur = 10.0;

    return Scaffold(
      extendBody: true, // Allows the body to extend behind the bottom nav bar area
      body: Stack(
        children: [
          // The main content of the page, which will be blurred by the container above.
          _getSelectedPage(
            index: _selectedIndex,
            topPadding: topPanelHeight + 20, // Padding for top glass panel
            bottomPadding:
                navBarHeight +
                (navBarPadding * 2), // Padding for bottom nav bar
            topPanelHeight: topPanelHeight,
          ),
          // The glassmorphism container
          Align(
            alignment: Alignment.topCenter,
            child: ClipRRect(
              // I'm interpreting "curved borders in the top" as a container
              // at the top of the screen with its bottom corners curved.
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
                child: Container(
                  height: topPanelHeight,
                  decoration: BoxDecoration(
                    // Tinted with the secondary color.
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // This is the new OVERLAY rectangle, with blur, placed on top of the main overlay.
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              // Center it vertically within the main top overlay.
              padding: EdgeInsets.only(top: topPanelHeight / 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
                  child: Container(
                    // Give it some horizontal margin to not touch the screen edges
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: topPanelHeight / 2,
                    decoration: BoxDecoration(
                      // A slightly more opaque color to be visible on top of the other overlay
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // The glassmorphism navigation bar, now inside the Stack
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              // Using symmetrical padding for a cleaner look.
              padding: const EdgeInsets.all(navBarPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
                  child: Container(
                    height: navBarHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.15),
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
          ),
        ],
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
