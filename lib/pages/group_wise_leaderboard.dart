import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minigolf/api.dart';
import 'package:minigolf/class/create_team.dart';
import 'package:minigolf/connection/connection.dart';
import 'package:minigolf/routes/routes.dart';
import 'package:minigolf/storage/get_storage.dart';

import '../widgets/app_widgets.dart';

class LeaderboardModel {
  final int uid;
  final int score;
  final bool status;
  final DateTime lastUpdated;
  final String userName;

  LeaderboardModel({
    required this.uid,
    required this.score,
    required this.status,
    required this.lastUpdated,
    required this.userName,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      uid: json['uid'],
      score: json['score'],
      status: json['status'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      userName: json['userName'],
    );
  }
}

class GroupWiseLeaderboard extends StatefulWidget {
  const GroupWiseLeaderboard({super.key});

  @override
  State<GroupWiseLeaderboard> createState() => _GroupWiseLeaderboardState();
}

class _GroupWiseLeaderboardState extends State<GroupWiseLeaderboard> {
  final storage = GetStorage();
  List<LeaderboardModel> scores = [];
  bool isLoading = true;
  String teamId = '';

  @override
  void initState() {
    super.initState();
    fetchLeaderboardData();
  }

  TeamClass team = Storage().getTeamData();

  @override
  Widget build(BuildContext context) {
    final sortedScores = [...scores]
      ..sort((a, b) => a.score.compareTo(b.score));

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            expandedHeight: 400,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/leaderboard_banner.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            floating: true,
            snap: true,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildLeaderboardHeader(),
                if (scores.isEmpty)
                  const Center(
                    child: Text(
                      'No scores available',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  ...sortedScores.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final player = entry.value;
                    return _buildLeaderboardRow(rank, player, rank <= 3);
                  }),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchLeaderboardData,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildLeaderboardHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Rank',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Player',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Score',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(
      int rank, LeaderboardModel player, bool highlight) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.amber.shade700.withOpacity(0.1)
            : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            '$rank',
            style: TextStyle(
              color: highlight ? Colors.amber : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            player.userName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${player.score}',
            style: TextStyle(
              color: highlight ? Colors.amber : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchLeaderboardData() async {
    if (mounted) {
      setState(() => isLoading = true);
    }

    try {
      final response = await ApiService().post(
        Api.baseUrl,
        data: {
          'q': 'leaderboard',
          'teamId': team.teamId,
        },
      );

      if (!mounted) return;

      if (response == null) {
        AppWidgets.errorSnackBar(content: 'No response from server');
        setState(() => isLoading = false);
        return;
      }

      Map<String, dynamic> data = response.data;
      if (response.statusCode == 200 && data['error'] == false) {
        setState(() {
          // Changed from 'leaderboard' to 'scores' to match API response
          scores = (data['scores'] as List)
              .map((item) => LeaderboardModel.fromJson(item))
              .toList();
          isLoading = false;
        });
      } else {
        AppWidgets.errorSnackBar(content: data['message']);
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      AppWidgets.errorSnackBar(content: 'Error: $e');
      setState(() => isLoading = false);
    }
  }
}
