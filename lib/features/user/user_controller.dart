// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:teb_mesada/core/routes.dart';
import 'package:teb_mesada/features/user/access_log/access_log_controller.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_mesada/core/local_data_controller.dart';

import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_util.dart';

class UserController {
  late User _currentUser = User();

  User get currentUser => _currentUser;

  Future<Map<String, dynamic>> login({required User user, bool saveLocalUserData = true}) async {
    Map<String, dynamic> loginReturn;
    try {
      final credential = await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      if (credential.user != null) {
        _currentUser = await getUserbyEmail(email: user.email);
        _currentUser.token = await credential.user!.getIdToken() ?? '';
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      AdmAccessLogController().add(email: user.email, success: false, observation: e.code);

      return {'TebReturn': TebReturn.authSignUpError(e.code)};
    } catch (e) {
      AdmAccessLogController().add(email: user.email, success: false, observation: e.toString());
      return {'TebReturn': TebReturn.error(e.toString())};
    }
    if (saveLocalUserData) LocalDataController().saveUser(user: _currentUser);

    loginReturn = {
      'TebReturn': TebReturn.sucess,
      'nextRoute': _currentUser.familyId.isEmpty ? Routes.familyForm : Routes.landingScreen,
    };
    return loginReturn;
  }

  void logoff() {
    clearCurrentUser();
    LocalDataController().clearUserData();
    LocalDataController().clearSelectedChildData();
  }

  Future<bool> canLoginByUserLocalData() async {
    var userLocalDataController = LocalDataController();
    await userLocalDataController.chechLocalData();

    if (userLocalDataController.localUser.id.isEmpty) return false;

    var loginReturn = await login(
      user: userLocalDataController.localUser,
      saveLocalUserData: false,
    );

    return loginReturn['TebReturn'].returnType == TebReturnType.sucess;
  }

  Future<User> getUserbyEmail({required String email}) async {
    var userQuery = FirebaseFirestore.instance
        .collection(User.collectionName)
        .where("email", isEqualTo: email);

    final users = await userQuery.get();
    final dataList = users.docs.map((doc) => doc.data()).toList();

    if (dataList.isEmpty) {
      return User();
    } else {
      return User.fromMap(map: dataList.first);
    }
  }

  Future<User> getUserById({required String id}) async {
    final userDataRef = await FirebaseFirestore.instance
        .collection(User.collectionName)
        .doc(id)
        .get();
    final userData = userDataRef.data();

    if (userData == null) {
      return User();
    }

    return User.fromMap(map: userData);
  }

  Future<TebReturn> save({required User user}) async {
    try {
      if (user.id.isEmpty) {
        final credential = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: user.email,
          password: TebUtil.encrypt(user.password),
        );
        if (credential.user == null) return TebReturn.error('Erro ao criar usuário');

        if (fb_auth.FirebaseAuth.instance.currentUser != null) {
          fb_auth.FirebaseAuth.instance.currentUser!.updateDisplayName(user.name);
        }

        user.id = credential.user!.uid;
      }

      if (user.isPasswordChanged) {
        user.password = TebUtil.encrypt(user.password);
        if (fb_auth.FirebaseAuth.instance.currentUser != null) {
          fb_auth.FirebaseAuth.instance.currentUser!.updatePassword(user.password);
        }
      }

      if (fb_auth.FirebaseAuth.instance.currentUser != null) {
        if (user.email != fb_auth.FirebaseAuth.instance.currentUser!.email) {
          fb_auth.FirebaseAuth.instance.currentUser!.verifyBeforeUpdateEmail(user.email);
        }
      }

      if (fb_auth.FirebaseAuth.instance.currentUser != null) {
        if (user.name != fb_auth.FirebaseAuth.instance.currentUser!.displayName) {
          fb_auth.FirebaseAuth.instance.currentUser!.verifyBeforeUpdateEmail(user.name);
        }
      }

      user.childHasPhoto = (user.userType == UserType.child && user.childLocalPhotoPath.isNotEmpty);

      await FirebaseFirestore.instance.collection(User.collectionName).doc(user.id).set(user.toMap);

      if (user.userType == UserType.child) {
        if (user.childLocalPhotoPath.isNotEmpty) await _fireStoreImageManager(user: user);
      } else {
        LocalDataController().saveUser(user: user);
        _currentUser = User.fromMap(map: user.toMap);
      }

      return TebReturn.sucess;
    } on fb_auth.FirebaseException catch (e) {
      return TebReturn.authSignUpError(e.code);
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  Future<List<User>> getChildList({required String familyId}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(User.collectionName)
        .where("familyId", isEqualTo: familyId)
        .where("userType", isEqualTo: UserType.child.toString())
        .get();

    List<User> childList = [];

    for (var doc in snapshot.docs) {
      final user = User.fromMap(map: doc.data());
      childList.add(user);
    }

    return childList;
  }

  Future<TebReturn> _fireStoreImageManager({required User user}) async {
    try {
      final storageInstance = FirebaseStorage.instance.ref();

      // if image is marked to be deleted

      // Create the file metadata
      final metadata = SettableMetadata(contentType: "image/jpeg");
      // if image have a path value it should be send to FireStore
      if (user.childLocalPhotoPath.isNotEmpty) {
        if (kIsWeb) {
          user.childUint8ListPhoto = resizeImage(user.childUint8ListPhoto!);
          await storageInstance.child(user.imagePath).putData(user.childUint8ListPhoto!, metadata);
        } else {
          final file = File(user.childLocalPhotoPath);
          storageInstance.child(user.imagePath).putFile(file, metadata);
        }
      }

      return TebReturn.sucess;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  Uint8List resizeImage(Uint8List data) {
    Uint8List resizedData = data;
    Image? img = decodeImage(data);
    if (img == null) return resizedData;

    Image resized = copyResize(img, width: 200);

    resizedData = encodeJpg(resized);
    return resizedData;
  }

  void clearCurrentUser() async {
    _currentUser = User();
  }
}
