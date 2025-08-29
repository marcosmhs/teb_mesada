import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:teb_mesada/firebase_options.dart';

enum UserType { parent, child }

class User {
  static const collectionName = 'user';

  late String id;
  late String email;
  late String password;
  late String token;
  late String name;
  late String phone;
  late String familyId;
  late UserType userType;
  late bool childHasPhoto;
  late String childLocalPhotoPath;
  late Uint8List? childUint8ListPhoto;
  late DateTime creationDate;

  late bool _passwordChanged = false;

  late final TextEditingController emailTextController = TextEditingController();
  late final TextEditingController passwordTextController = TextEditingController();
  late final TextEditingController nameTextController = TextEditingController();
  late final TextEditingController phoneTextController = TextEditingController();

  User({
    this.id = '',
    this.email = '',
    this.password = '',
    this.token = '',
    this.name = '',
    this.phone = '',
    this.familyId = '',
    this.userType = UserType.parent,
    this.childHasPhoto = false,
    this.childLocalPhotoPath = '',
    this.childUint8ListPhoto,

    DateTime? creationDate,
  }) {
    this.creationDate = creationDate ?? DateTime.now();
    nameTextController.text = name;
    emailTextController.text = email;
    phoneTextController.text = phone.isEmpty ? '55' : phone;
  }

  void setPassword(String value) {
    password = value;
    _passwordChanged = true;
  }

  bool get isPasswordChanged {
    return _passwordChanged;
  }

  String get firstName {
    return name.split(' ').isNotEmpty ? name.split(' ')[0] : '';
  }

  String get initials {
    if (name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts[0] : '';
    final second = parts.length > 1 ? parts[1] : '';
    return (first.isNotEmpty ? first[0] : '') + (second.isNotEmpty ? second[0] : '');
  }

  String get childPhotoUrl {
    return '';
  }

  String get imagePath {
    return 'images/mesada/$familyId/child_photos/$id.jpg';
  }

  String get imageUrl {
    if (!childHasPhoto) return '$storageUrlBase/child_no_photo.png?alt=media';

    String mainPath = 'images%2Fmesada%2F$familyId%2Fchild_photos';
    return '$storageUrlBase/$mainPath%2F$id.jpg?alt=media';
  }

  static UserType userTypeFromString(String value) {
    return value == UserType.parent.toString() ? UserType.parent : UserType.child;
  }

  static User fromMap({
    required Map<String, dynamic> map,
    String setEmail = '',
    String setToken = '',
  }) {
    var user = User();

    user = User(
      id: map['id'] ?? '',
      email: setEmail.isNotEmpty ? setEmail : map['email'] ?? '',
      password: map['password'] ?? '',
      token: setToken.isNotEmpty ? setToken : map['token'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      familyId: map['familyId'] ?? '',
      userType: (map['userType'] ?? '') == ''
          ? UserType.parent
          : userTypeFromString(map['userType']),
      childHasPhoto: map['childHasImage'] ?? false,
      creationDate: map['creationDate'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['creationDate']),
    );

    return user;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> user = {};
    user = {
      'id': id,
      'email': email,
      'password': password,
      'token': token,
      'name': name,
      'phone': phone,
      'familyId': familyId,
      'userType': userType.toString(),
      'childHasImage': childHasPhoto,
      'creationDate': creationDate.toString(),
    };

    return user;
  }
}
