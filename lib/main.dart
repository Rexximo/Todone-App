import 'package:flutter/material.dart';
import 'pages/concentric_animation_onboarding.dart';
import 'package:rive/rive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Todone',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    home: const LoginPage(),
  );
}
}


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // dummy account
  String validEmail = "ipnu@gmail.com";
  String validPassword = "12345";

  /// input form controller
  FocusNode emailFocusNode = FocusNode();
  TextEditingController emailController = TextEditingController();

  FocusNode passwordFocusNode = FocusNode();
  TextEditingController passwordController = TextEditingController();

  /// rive controller and input
  StateMachineController? controller;

  /// SMI Stand for State Machine Input
  SMIBool? lookOnEmail;
  SMINumber? followOnEmail;

  SMIBool? lookOnPassword;
  SMIBool? peekOnPassword;

  SMITrigger? triggerSuccess;
  SMITrigger? triggerFail;

  bool _isPasswordVisible = false;

  @override
  void initState() {
    emailFocusNode.addListener(() {
      lookOnEmail?.change(emailFocusNode.hasFocus);
    });

    passwordFocusNode.addListener(() {
      lookOnPassword?.change(passwordFocusNode.hasFocus);
    });

    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();

    emailController.dispose();
    emailFocusNode.dispose();

    passwordController.dispose();
    passwordFocusNode.dispose();

    super.dispose();
  }

  void onClickLogin() async {
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    showLoadingDialog(context);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pop(context);

    final valid =
        email.toLowerCase() == validEmail.toLowerCase() && password == validPassword;

    if (valid) {
      triggerSuccess?.change(true);
      
      // Tunggu animasi success selesai lalu redirect
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConcentricAnimationOnboarding()),
      );
    } else {
      triggerFail?.change(true);
      
      // Tampilkan error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau Password salah!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF31260),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Title
                Text(
                  'Todone',
                  style: GoogleFonts.poppins(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                // Login Card dengan Teddy di atas
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Card
                    Container(
                      margin: const EdgeInsets.only(top: 120),
                      padding: const EdgeInsets.fromLTRB(24, 140, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email Field
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            focusNode: emailFocusNode,
                            controller: emailController,
                            onChanged: (value) {
                              followOnEmail?.change(value.length.toDouble() * 1.5);
                            },
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Enter your email..',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFF31260),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Password Field
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            obscureText: !_isPasswordVisible,
                            focusNode: passwordFocusNode,
                            controller: passwordController,
                            maxLines: 1,
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              hintText: 'Enter your password..',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFF31260),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                  peekOnPassword?.change(_isPasswordVisible);
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: onClickLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF31260),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Rive Animation di atas card
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: RiveAnimation.asset(
                          "assets/animation/auth-teddy.riv",
                          fit: BoxFit.cover,
                          onInit: (artboard) {
                            controller = StateMachineController.fromArtboard(
                              artboard,
                              "Login Machine",
                            );

                            if (controller == null) {
                              debugPrint("❌ Controller is null! Check State Machine name in Rive file");
                              return;
                            }

                            artboard.addController(controller!);
                            debugPrint("✅ Controller added successfully");

                            // Print semua input yang tersedia
                            debugPrint("=== Available Inputs ===");
                            for (var input in controller!.inputs) {
                              debugPrint("📝 ${input.name} (${input.runtimeType})");
                            }
                            debugPrint("========================");

                            lookOnEmail = controller?.findSMI("isFocus");
                            followOnEmail = controller?.findSMI("numLook");

                            lookOnPassword = controller?.findSMI("isPrivateField");
                            peekOnPassword = controller?.findSMI("isPrivateFieldShow");

                            triggerSuccess = controller?.findSMI("successTrigger");
                            triggerFail = controller?.findSMI("failTrigger");

                            debugPrint("📧 lookOnEmail (isFocus): ${lookOnEmail != null}");
                            debugPrint("👀 followOnEmail (numLook): ${followOnEmail != null}");
                            debugPrint("🔒 lookOnPassword (isPrivateField): ${lookOnPassword != null}");
                            debugPrint("👁️ peekOnPassword (isPrivateFieldShow): ${peekOnPassword != null}");
                            debugPrint("✅ triggerSuccess: ${triggerSuccess != null}");
                            debugPrint("❌ triggerFail: ${triggerFail != null}");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}