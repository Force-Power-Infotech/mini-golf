import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:minigolf/pages/HomeScreen.dart';
import 'package:minigolf/routes/routes.dart';

class PlayNowScreen extends StatefulWidget {
  @override
  _PlayNowScreenState createState() => _PlayNowScreenState();
}

class _PlayNowScreenState extends State<PlayNowScreen> {
  List<Player> players = [];

  void _addPlayer() {
    setState(() {
      players.add(Player());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Keep the existing SliverAppBar
          SliverAppBar(
            expandedHeight: 400,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                          NetworkImage('https://i.ibb.co/Zz95KzQ/PLAY-now.png'),
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

          // Instruction Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Card(
                color: Colors.grey[900],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Instructions",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "1. Use the 'Add Player' button to add a new player.\n"
                        "2. Fill in the player's name by tapping on the input field.\n"
                        "3. Use the delete icon to remove a player if needed.",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Player List Section
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return AnimatedPlayerCard(
                  player: players[index],
                  onRemove: () {
                    setState(() {
                      players.removeAt(index);
                    });
                  },
                );
              },
              childCount: players.length,
            ),
          ),

          // Add Player Button
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.grey],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _addPlayer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Add Player',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.toNamed(Routes.scoreboard),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Player {
  String name;
  String imageUrl;

  Player({this.name = '', this.imageUrl = ''});
}

class AnimatedPlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onRemove;

  const AnimatedPlayerCard({required this.player, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: player.name.isEmpty
              ? Border.all(color: Colors.redAccent, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Circular Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[800],
                backgroundImage: player.imageUrl.isNotEmpty
                    ? NetworkImage(player.imageUrl)
                    : null,
                child: player.imageUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Name Input
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  onChanged: (value) {
                    player.name = value;
                  },
                ),
              ),

              // Remove Button
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
