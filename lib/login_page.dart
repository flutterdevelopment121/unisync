import 'package:flutter/material.dart';
import 'register.dart'; // Import the RegisterPage
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart'; // Import the liquid_glass_renderer package
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'main.dart'; // To access the supabase client instance

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isLoading = false; // State variable for loading indicator

  // TODO: Add state for loading indicators, error messages

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Removed the outer LiquidGlass wrapper for a full-page effect.
    // Now applying LiquidGlass to individual elements.
    return Scaffold(
      // Removed AppBar
      // appBar: AppBar(title: const Text('UniSync Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Moved title from AppBar to body
              Text(
                'UniSync',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 32.0, // Adjust size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40.0), // Add spacing below title
              // Email TextField without LiquidGlass
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(), // Keep border for structure
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),

              // Password TextField without LiquidGlass
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(), // Keep border for structure
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                  ),
                ),
                obscureText: _isPasswordObscured, // Use state variable here
              ),
              const SizedBox(height: 24.0),

              // Wrap ElevatedButton with LiquidGlass
              LiquidGlass(
                blur: 5.0, // Apply blur
                shape: LiquidRoundedRectangle(
                  borderRadius: Radius.circular(
                    25.0,
                  ), // Match Button border radius (ElevatedButton default is often higher)
                ),
                settings: const LiquidGlassSettings(
                  thickness: 2.0,
                  glassColor: Colors.white12,
                ),
                glassContainsChild:
                    false, // Render Button content on top of glass
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ), // make button wider
                    // Ensure the button itself is transparent if you want the glass effect
                    // to be the primary background. Otherwise, the button's color will obscure it.
                    // backgroundColor: Colors.transparent, // Example: make button see-through
                    // elevation: 0, // Remove shadow if using transparent background
                  ),
                  onPressed: _isLoading ? null : () async { // Disable button when loading
                    // TODO: Implement actual login logic with Supabase
                    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                      setState(() {
                        _isLoading = true;
                      });

                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      print(
                        'Login attempt with Email: $email, Password: $password',
                      );

                      try {
                        final AuthResponse res = await supabase.auth.signInWithPassword(
                          email: email,
                          password: password,
                        );
                        if (res.user != null) {
                          if (mounted) {
                            // Navigate to home page and remove all previous routes
                            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                          }
                        } else {
                          // This case might not be hit often if signInWithPassword throws on failure
                           if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Login failed. Please try again.')),
                            );
                          }
                        }
                      } on AuthException catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login failed: ${e.message}')),
                          );
                        }
                      } catch (e) {
                         if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('An unexpected error occurred: $e')),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() { _isLoading = false; });
                        }
                      }
                    } else {
                       if (mounted) { setState(() { _isLoading = false; });}
                    }
                  },
                  child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white)) 
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 12.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text('Not a user? Register'),
              ),
            ],
          ), // Padding
        ), // Center
      ),
    );
  }
}
