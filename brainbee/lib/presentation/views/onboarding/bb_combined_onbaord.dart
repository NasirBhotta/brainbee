import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/auth/UI/bb_login.dart';
import 'package:brainbee/presentation/views/auth/UI/bb_signup.dart';
import 'package:brainbee/presentation/views/auth/bloc/auth_bloc.dart';
import 'package:brainbee/presentation/views/onboarding/bb_onboarding.dart';
import 'package:brainbee/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BbCombinedOnbaord extends StatefulWidget {
  const BbCombinedOnbaord({super.key});

  @override
  State<BbCombinedOnbaord> createState() => _BbCombinedOnbaordState();
}

class _BbCombinedOnbaordState extends State<BbCombinedOnbaord> {
  double currentOffset = 0;
  bool isLogin = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return MultiBlocListener(
      listeners: [
        // Handle navigation to dashboard
        BlocListener<AuthBloc, AuthState>(
          listenWhen:
              (previous, current) => current is NavigateToDashboardActionState,
          listener: (context, state) {
            if (state is NavigateToDashboardActionState) {
              AppRoutes.navigateToHome(context);
            }
          },
        ),
        // Handle authentication success
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => current is AuthAuthenticated,
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              AppRoutes.navigateToHome(context);
            }
          },
        ),
        // Handle auth errors
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => current is AuthFailureState,
          listener: (context, state) {
            if (state is AuthFailureState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: BBColors.lightGrayBG,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoadingState;

            return AbsorbPointer(
              absorbing: isLoading,
              child: Stack(
                children: [
                  SizedBox(
                    height: size.height,
                    child: Stack(
                      children: [
                        // Top gradient section with onboarding
                        Container(
                          height: size.height * 0.6,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                BBColors.primaryColor,
                                BBColors.secondaryColor,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: const BbOnboarding(),
                        ),

                        // Bottom section with auth forms
                        Positioned(
                          top: size.height * 0.6 - currentOffset * 0.5,
                          bottom: 0,
                          child: SizedBox(
                            height: size.height * 0.5,
                            width: size.width,
                            child:
                                isLogin
                                    ? BbLogin(
                                      onScroll: (offset) {
                                        setState(() {
                                          currentOffset = offset;
                                        });
                                      },
                                      signUp: () {
                                        setState(() {
                                          isLogin = !isLogin;
                                          currentOffset = 0;
                                        });
                                      },
                                    )
                                    : BbSignup(
                                      onScroll: (offset) {
                                        setState(() {
                                          currentOffset = offset;
                                        });
                                      },
                                      login: () {
                                        setState(() {
                                          isLogin = !isLogin;
                                          currentOffset = 0;
                                        });
                                      },
                                    ),
                          ),
                        ),

                        // Debug text (remove in production)
                        if (kDebugMode)
                          Positioned(
                            top: 50,
                            left: 20,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Offset: ${currentOffset.toStringAsFixed(1)}\nAuth: ${state.runtimeType}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Loading overlay
                  if (isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Card(
                          elevation: 8,
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: BBColors.primaryColor,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Authenticating...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
