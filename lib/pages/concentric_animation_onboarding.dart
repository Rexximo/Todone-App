import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:quick_learn/pages/home_page.dart';


final pages = [
  const PageData(
    icon: Icons.pending_actions_rounded,
    title: "Create Tasks",
    bgColor: Color(0xFFF31260),
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.task_alt_rounded,
    title: "Complete Tasks",
    bgColor: Colors.white,
    textColor: Color(0xFFF31260),
  ),
];

class ConcentricAnimationOnboarding extends StatefulWidget {
  const ConcentricAnimationOnboarding({super.key});

  @override
  State<ConcentricAnimationOnboarding> createState() => _ConcentricAnimationOnboardingState();
}

class _ConcentricAnimationOnboardingState extends State<ConcentricAnimationOnboarding> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.1,
        nextButtonBuilder: (context) => Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Icon(Icons.navigate_next, size: screenWidth * 0.08),
        ),
        itemCount: pages.length,
        opacityFactor: 2.0,
        scaleFactor: 2,
        onChange: (int index) {
          setState(() {
            currentPage = index;
          });
        },
        onFinish: () {
          // Ini akan dipanggil ketika tombol next diklik di halaman terakhir
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        itemBuilder: (index) {
          final page = pages[index % pages.length];
          return SafeArea(child: _Page(page: page));
        },
      ),
    );
  }
}

class PageData {
  final String? title;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;

  const PageData({
    this.title,
    this.icon,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
  });
}

class _Page extends StatelessWidget {
  final PageData page;

  const _Page({required this.page});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: page.textColor,
          ),
          child: Icon(page.icon, size: screenHeight * 0.1, color: page.bgColor),
        ),
        Text(
          page.title ?? "",
          style: TextStyle(
            color: page.textColor,
            fontSize: screenHeight * 0.035,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
