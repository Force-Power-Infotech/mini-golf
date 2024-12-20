import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minigolf/class/create_team.dart';
import 'package:minigolf/class/user_class.dart';

class Storage extends GetxController {
  final box = GetStorage();

  Future<void> initStorage() async {
    await GetStorage.init();
  }

  void storeValue(String constant, dynamic value) {
    box.write(constant, value);
  }

  getValue(String constant) {
    return box.read(constant);
  }

  clearData() {
    return box.erase();
  }

  removeValue(String constant) {
    return box.remove(constant);
  }

  bool containsKey(String constant) {
    return box.hasData(constant);
  }

  void storeUserDate(UserClass user) {
    storeValue('user', user.toJson());
    log('User data stored: ${user.toJson()}');
  }

  void storeTeamDate(TeamClass team) {
    storeValue('team', team.toJson());
    log('team data stored: ${team.toJson()}');
  }

  UserClass getUserData() {
    final user = UserClass.fromJson(getValue('user'));
    log('User data: ${user.toJson()}');
    return user;
  }

  TeamClass getTeamData() {
    final team = TeamClass.fromJson(getValue('team'));
    log('team data: ${team.toJson()}');
    return team;
  }

  bool isLoggedIn() {
    final user = getValue('user');
    return user != null && user['userID'] != null;
  }

  // Add these methods to your Storage class
  void storeBoardId(String? boardId) {
    if (boardId != null) {
      box.write('boardId', boardId);
    }
  }

  String? getBoardId() {
    return box.read('boardId');
  }

  void saveScores(Map<String, List<int>> scores) {
    box.write('scores', scores);
  }

  Map<String, List<int>>? getScores() {
    final data = box.read('scores');
    if (data != null) {
      return Map<String, List<int>>.from(data);
    }
    return null;
  }

  // Add these new methods after the existing methods
  Future<void> write(String key, dynamic value) async {
    try {
      await box.write(key, value);
    } catch (e) {
      log('Error writing to storage: $e');
      throw Exception('Failed to write to storage');
    }
  }

  dynamic read(String key) {
    try {
      return box.read(key);
    } catch (e) {
      log('Error reading from storage: $e');
      return null;
    }
  }
}
