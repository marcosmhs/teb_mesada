import 'package:flutter/material.dart';

class Activity {
  static const collectionName = 'activity';

  late String id;
  late String familyId;
  late String name;

  late TextEditingController nameTextController = TextEditingController();

  Activity({this.id = '', this.name = '', this.familyId = ''}) {
    nameTextController.text = name;
  }

  static Activity fromMap(Map<String, dynamic> map) {
    var family = Activity();

    family = Activity(
      id: map['id'] ?? '',
      familyId: map['familyId'] ?? '',
      name: map['name'] ?? '',
    );

    return family;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};

    r = {'id': id, 'familyId': familyId, 'name': name,};

    return r;
  }
}
