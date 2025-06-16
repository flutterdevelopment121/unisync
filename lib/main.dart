import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Recommended for managing keys
import 'login_page.dart'; // Placeholder for login page
import 'register.dart'; // Placeholder for registration page
import 'home_page.dart'; // Placeholder for home page

// Load environment variables from .env file
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (create a .env file in your project root)
  await dotenv.load(fileName: "credentials.env");

  // Initialize Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    // Handle the case where keys are missing (e.g., show an error, exit)
    // For now, we'll just print and exit. In a real app, you'd handle this gracefully.
    print("Error: SUPABASE_URL or SUPABASE_ANON_KEY not found in .env file.");
    // Consider throwing an exception or showing an error screen
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: true, // Set to false in production
  );

  runApp(const UniSyncApp());
}

// Get a reference to the Supabase client
final supabase = Supabase.instance.client;

class UniSyncApp extends StatelessWidget {
  const UniSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the default brown seed color
    const Color primaryBrown = Color(0xFF795548);

    // Function to build the theme data
    ThemeData buildTheme(Brightness brightness, Color seedColor) {
      final colorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      );

      return ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: GoogleFonts.robotoFlexTextTheme(
          ThemeData(brightness: brightness).textTheme,
        ),
        // You can customize specific component themes here if needed
        // cardTheme: CardTheme(...),
        // elevatedButtonTheme: ElevatedButtonThemeData(...),
        // appBarTheme: AppBarTheme(...),
      );
    }

    return MaterialApp(
      title: 'UniSync',
      debugShowCheckedModeBanner: false, // Set to false in production
      theme: buildTheme(Brightness.light, primaryBrown), // Default Light Theme
      darkTheme: buildTheme(
        Brightness.dark,
        primaryBrown,
      ), // Default Dark Theme
      themeMode: ThemeMode.system, // Default to system theme mode
      // TODO: Implement user preference for themeMode and seedColor

      // Initial route setup
      initialRoute: '/login', // Start with the login page
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) =>
            const RegisterPage(), // Placeholder for registration page
         '/home': (context) => const HomePage(), // Placeholder for home page
        // TODO: Add other routes here (e.g., '/home', '/notes', '/attendance')
      },

      // You might use a router package like go_router later for more complex navigation
      // onGenerateRoute: (settings) { ... }
    );
  }
}
