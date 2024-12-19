import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:minigolf/routes/routes.dart';
import 'package:minigolf/routes/routes_generator.dart';
import 'package:minigolf/storage/get_storage.dart';
import 'dart:html'; // Required for Flutter web to access query parameters

void main() {
  // Extract the boardId from the URL
  Uri uri = Uri.base; // Gets the current URL
  String? boardId = uri.queryParameters['boardId'];

  // Store the boardId
  Storage().storeBoardId(boardId);

  // Run the app with boardId
  runApp(MyApp(boardId: boardId));
}

class MyApp extends StatelessWidget {
  final String? boardId;

  const MyApp({super.key, this.boardId});

  @override
  Widget build(BuildContext context) {
    // Print boardId for debugging
    print('Board ID: $boardId');

    return GetMaterialApp(
      initialRoute: Routes.getStarted,
      onGenerateRoute: RouteGenerator.generateRoute,
      title: 'MINI GOLF',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: HomeScreen(boardId: boardId),
    );
  }
}

// Example HomeScreen widget to display boardId


