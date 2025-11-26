import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/scroll_controller.dart';
import 'package:brainbee/presentation/views/auth/bloc/auth_bloc.dart';
import 'package:brainbee/routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BbLogin extends StatefulWidget {
  final Function(double offset)? onScroll;

  const BbLogin({super.key, required this.onScroll, required this.signUp});
  final Function()? signUp;

  @override
  State<BbLogin> createState() => _BbLoginState();
}

class _BbLoginState extends State<BbLogin> {
  final emailController = TextEditingController(text: "jawad1@gmail.com");
  final passwordController = TextEditingController(text: "Jawad123");
  ScrollController scrollController = ScrollController();

  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  double offset = 0;
  double maxOffset = 400;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.addListener(() {
        if (scrollController.offset >= 0) {
          offset = scrollController.hasClients ? scrollController.offset : 0;
          widget.onScroll?.call(scrollController.offset);

          setState(() {});
        }
      });
    });

    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        scrollController.jumpTo(200);
      }
    });
    passwordFocus.addListener(() {
      if (passwordFocus.hasFocus) {
        scrollController.jumpTo(350);
        setState(() {
          maxOffset += 150;
        });
      }
      if (!passwordFocus.hasFocus) {
        setState(() {
          scrollController.jumpTo(267);
          maxOffset -= 150;
        });
      }
    });
  }

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      controller: scrollController,
      physics: SlowMaxScrollPhysics(maxOffset: maxOffset),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailureState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is NavigateToDashboardActionState) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.only(top: 10 + offset, left: 10, right: 10),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Login',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Username / Email",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    focusNode: emailFocus,
                    controller: emailController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      hintText: 'Enter your username or email',

                      hintStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontSize: 12, color: BBColors.bodyText),
                    ),
                    onFieldSubmitted: (value) {
                      emailFocus.unfocus();
                      FocusScope.of(context).requestFocus(passwordFocus);
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Password",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    focusNode: passwordFocus,
                    controller: passwordController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      hintText: 'Enter your password',

                      hintStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontSize: 12, color: BBColors.bodyText),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(child: SizedBox.shrink()),
                      InkWell(
                        onTap: () {},
                        child: Text(
                          'Forgot Password?',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: BBColors.secondaryColor,
                            decorationThickness: 2,
                            color: BBColors.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [
                          BBColors.primaryColor,
                          BBColors.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          AuthLoginRequested(
                            email: emailController.text,
                            password: passwordController.text,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child:
                          (state is AuthLoadingState)
                              ? const CircularProgressIndicator(
                                color: BBColors.white,
                                strokeWidth: 1.5,
                              )
                              : Text(
                                'Sign In',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: BBColors.white,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: size.width,
                          height: 0.5,
                          color: BBColors.bodyText,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Text("OR"),
                      ),
                      Expanded(
                        child: Container(
                          width: size.width,
                          height: 0.5,
                          color: BBColors.bodyText,
                        ),
                      ),
                    ],
                  ),

                  // const SizedBox(height: 10),
                  // ElevatedButton(
                  //   onPressed: () {},
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: BBColors.primaryBlue,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Image.asset('assets/google.png', height: 25, width: 25),
                  //       const SizedBox(width: 10),
                  //       Text(
                  //         'Login with Google',
                  //         style: Theme.of(
                  //           context,
                  //         ).textTheme.bodyMedium?.copyWith(
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.w600,
                  //           color: BBColors.white,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: widget.signUp,
                        child: Text(
                          'Sign Up',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: BBColors.secondaryColor,
                            decorationThickness: 2,
                            color: BBColors.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Need help?",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () {
                          // Handle terms and conditions action
                        },
                        child: Text(
                          'Get Support',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: BBColors.secondaryColor,
                            decorationThickness: 2,
                            color: BBColors.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height:
                        passwordFocus.hasFocus
                            ? context.screenHeight * 0.1
                            : 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
