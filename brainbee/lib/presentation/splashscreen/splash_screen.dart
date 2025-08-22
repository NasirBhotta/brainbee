import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/auth/bloc/auth_bloc.dart';
import 'package:brainbee/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;
  bool _minSplashTimeCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );
  }

  void _startSplashSequence() {
    _animationController.forward();

    // Set minimum splash duration
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _minSplashTimeCompleted = true;
        _attemptNavigation();
      }
    });
  }

  void _attemptNavigation() {
    if (_hasNavigated || !_minSplashTimeCompleted) return;

    final authState = context.read<AuthBloc>().state;

    // Only navigate when we have a definitive auth state
    if (authState is AuthAuthenticated) {
      _navigateToHome();
    } else if (authState is AuthLoggedOut ||
        authState is AuthFailureState ||
        authState is AuthInitial) {
      _navigateToAuth();
    }
    // Don't navigate if still in AuthLoadingState
  }

  void _navigateToHome() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    if (kDebugMode) {
      print('Navigating to Home');
    }

    AppRoutes.navigateToHome(context);
  }

  void _navigateToAuth() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    if (kDebugMode) {
      print('Navigating to Auth');
    }

    AppRoutes.navigateToAuth(context);
  }

  String _getStatusText(AuthState state) {
    if (state is AuthLoadingState) {
      return 'Checking authentication...';
    } else if (state is AuthAuthenticated) {
      return 'Welcome back!';
    } else if (state is AuthLoggedOut) {
      return 'Redirecting to login...';
    } else if (state is AuthFailureState) {
      return 'Authentication failed';
    }
    return 'Initializing...';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (kDebugMode) {
          print('Auth state changed to: ${state.runtimeType}');
        }

        // Only attempt navigation after minimum splash time
        if (_minSplashTimeCompleted) {
          _attemptNavigation();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [BBColors.primaryColor, BBColors.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Optimized Logo Animation - Single AnimatedBuilder
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 60,
                            color: BBColors.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // App Name and Tagline - Combined Animation
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        children: [
                          const Text(
                            'Brain Bee',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Learn • Grow • Achieve',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Loading indicator with status text
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return Column(
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _getStatusText(state),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),

                // Debug info (only in debug mode)
                if (kDebugMode)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(top: 40),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            Text(
                              'Auth: ${state.runtimeType}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Min Time: $_minSplashTimeCompleted',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Navigated: $_hasNavigated',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
