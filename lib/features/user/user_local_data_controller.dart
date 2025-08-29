import 'package:flutter/material.dart';
import 'package:teb_mesada/features/user/model/user.dart';

import 'package:teb_package/teb_package.dart';

class UserLocalDataController with ChangeNotifier {
  var _user = User();

  User get localUser => User.fromMap(map: _user.toMap);

  Future<void> chechLocalData() async {
    try {
      var userMap = await TebLocalStorage.readMap(key: 'user');

      if (userMap.isNotEmpty) _user = User.fromMap(map: userMap);
    } catch (e) {
      clearUserData();
    }
  }

  void saveUser({required User user}) {
    clearUserData();
    TebLocalStorage.saveMap(key: 'user', map: user.toMap);
  }

  void clearUserData() async {
    TebLocalStorage.removeValue(key: 'user');
  }

  void saveSelectedChild({required User childUser}) {
    TebLocalStorage.removeValue(key: 'selectedChild');
    TebLocalStorage.saveMap(key: 'selectedChild', map: childUser.toMap);
  }

  Future<User> get getLocalSelectedChild async {
    var user = User();
    try {
      var userMap = await TebLocalStorage.readMap(key: 'selectedChild');

      if (userMap.isNotEmpty) user = User.fromMap(map: userMap);

      return user;
    } catch (e) {
      clearUserData();
      return user;
    }
  }
}
