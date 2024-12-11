import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

  UserClass getUserData() {
    final user = UserClass.fromJson(getValue('user'));
    log('User data: ${user.toJson()}');
    return user;
  }

  bool isLoggedIn() {
    return containsKey('user');
  }
}
