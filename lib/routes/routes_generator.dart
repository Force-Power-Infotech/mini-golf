import 'package:flutter/material.dart';
import 'package:minigolf/pages/get_started_screen.dart';
import 'package:minigolf/pages/group_wise_leaderboard.dart';
import 'package:minigolf/pages/home_screen.dart';
import 'package:minigolf/pages/leader_board_screen.dart';
import 'package:minigolf/pages/login_screen.dart';
import 'package:minigolf/pages/play_now_screen.dart';
import 'package:minigolf/pages/scoring_screen.dart';
import 'package:minigolf/routes/routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget widgetScreen;

    switch (settings.name) {
      case Routes.getStarted:
        widgetScreen = const GetStartedScreen();
        break;
      case Routes.login:
        widgetScreen = const LoginScreen();
        break;
      case Routes.home:
        widgetScreen = const Homescreen();
        break;
      case Routes.playnow:
        widgetScreen = const PlayNowScreen();
        break;
      case Routes.leaderboard:
        widgetScreen = LeaderBoardScreen();
        break;
      case Routes.scoreboard:
        widgetScreen = const ScoringScreen();
        break;
      case Routes.groupwiseleaderboard:
        widgetScreen = const GroupWiseLeaderboard();
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
