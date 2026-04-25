import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.isFirstLaunch) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
      return;
    }
    // Wait up to 3 extra seconds for the Firebase auth stream to emit
    // before falling back to the login screen.
    for (int i = 0; i < 30; i++) {
      if (!mounted) return;
      if (auth.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
        return;
      }
      // Check if auth has finished loading (stream has emitted at least once)
      if (auth.authStreamReady) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;
    if (auth.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE91E8C), Color(0xFFCE93D8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Lottie animation
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Lottie.asset(
                    'assets/animations/splash_animation.json',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.favorite,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // App name
                Text(
                  'Her Cycle',
                  style: GoogleFonts.poppins(
                    fontSize: AppFonts.headlineXL,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                Text(
                  'Know your body. Love yourself.',
                  style: GoogleFonts.poppins(
                    fontSize: AppFonts.bodyL,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(flex: 2),
                // Loading indicator
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.7),
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
