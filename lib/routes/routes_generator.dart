import 'package:flutter/material.dart';
import 'package:minigolf/pages/GetStarted_screen.dart';
import 'package:minigolf/pages/HomeScreen.dart';
import 'package:minigolf/pages/LeaderBoard_screen.dart';
import 'package:minigolf/pages/Login_screen.dart';
import 'package:minigolf/pages/PlayNow_screen.dart';
import 'package:minigolf/pages/Scoring_screen.dart';
import 'package:minigolf/routes/routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget widgetScreen;

    switch (settings.name) {
      case Routes.getStarted:
        widgetScreen = GetStartedScreen();
        break;
      case Routes.login:
        widgetScreen = LoginScreen();
        break;
      case Routes.home:
        widgetScreen = const Homescreen();
        break;
      case Routes.playnow:
        widgetScreen = PlayNowScreen();
        break;
      case Routes.leaderboard:
        widgetScreen = LeaderBoardScreen();
        break;
      case Routes.scoreboard:
        widgetScreen = ScoringScreen();
        break;
      default:
        widgetScreen = _errorRoute();
    }

    return PageRouteBuilder(
        settings: settings, pageBuilder: (_, __, ___) => widgetScreen);
  }

  static Widget _errorRoute() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: const Center(
        child: Text(
          'No such screen found in route generator',
        ),
      ),
    );
  }
}
