import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:minigolf/routes/routes.dart';
import 'package:minigolf/storage/get_storage.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-Screen Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/inmall.png',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Modern App Icon
                Hero(
                  tag: 'app_icon',
                  child: Container(
                    padding: const EdgeInsets.all(28.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sports_golf_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Title
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Mini Golf',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                // Subtitle with Modern Style
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Blur
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      // Subtitle Text
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: const Text(
                          'Experience the joy of golf anytime, anywhere!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Feature Cards Section
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildFeatureCard(
                        icon: Icons.sports_golf,
                        title: 'Play Anywhere',
                        color: Colors.tealAccent,
                      ),
                      const SizedBox(width: 16),
                      _buildFeatureCard(
                        icon: Icons.star_rounded,
                        title: 'Challenge Friends',
                        color: Colors.amberAccent,
                      ),
                      const SizedBox(width: 16),
                      _buildFeatureCard(
                        icon: Icons.leaderboard_rounded,
                        title: 'Top Rankings',
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Get Started Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CupertinoButton(
                    // onPressed: () {
                    //   Get.offAllNamed(Routes.login);
                    // },
                    onPressed: () {
                      if (Storage().hasUserData() == true) {
                        Get.offAllNamed(Routes.home);
                      } else {
                        Get.offAllNamed(Routes.login);
                      }
                    },
                    color: Colors.tealAccent,
                    borderRadius: BorderRadius.circular(30),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        // Icon(
                        //   CupertinoIcons.arrow_right,
                        //   color: Colors.black,
                        // ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Feature Card Builder
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: 140,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
