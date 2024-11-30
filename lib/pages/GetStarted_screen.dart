import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:minigolf/routes/routes.dart';

class GetStartedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                'https://thumbs.dreamstime.com/b/white-golf-balls-against-green-background-pattern-vertical-wallpaper-poster-flyer-events-advertisement-template-concept-sport-321910912.jpg', // Replace with your image asset
                fit: BoxFit.cover,
              ),
            ),

            // Content Overlay
            Column(
              children: [
                const Spacer(flex: 1),

                // App Logo
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_golf_rounded,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),

                // App Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Mini Golf',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.tealAccent,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),

                // App Subtitle

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                        color: Colors.tealAccent,
                        size: 40,
                      ),
                      title: const Text(
                        'Modern Design',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Experience a sleek and modern design with our app.',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // Feature Cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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

                const Spacer(flex: 2),

                // Get Started Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CupertinoButton(
                    onPressed: () {
                      // Navigate to the next screen
                      Get.toNamed(Routes.login);
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
                        SizedBox(width: 10),
                        Icon(
                          CupertinoIcons.arrow_right,
                          color: Colors.black,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Method for Feature Cards
  Widget _buildFeatureCard(
      {required IconData icon, required String title, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: 120,
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
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
