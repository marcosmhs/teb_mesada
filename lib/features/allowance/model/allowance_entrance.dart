import 'package:flutter/material.dart';

class AllowanceEntrance {
  static const collectionName = 'allowance_entrance';

  late String id;
  late String familyId;
  late String childUserId;
  late String activityId;
  late String scheduleId;
  late String observation;
  late DateTime dateTime;
  late int year;
  late int month;
  late double bonusValue;
  late double punishmentValue;

  late TextEditingController observationTextController = TextEditingController();
  late TextEditingController bonusValueTextController = TextEditingController();
  late TextEditingController punishmentValueTextController = TextEditingController();

  AllowanceEntrance({
    this.id = '',
    this.familyId = '',
    this.childUserId = '',
    this.activityId = '',
    this.scheduleId = '',
    this.observation = '',
    DateTime? dateTime,
    this.year = 0,
    this.month = 0,
    this.bonusValue = 0,
    this.punishmentValue = 0,
  }) {
    this.dateTime = dateTime ?? DateTime.now();
    observationTextController.text = observation;
    bonusValueTextController.text = bonusValue.toString();
    punishmentValueTextController.text = punishmentValue.toString();
  }

  double get value {
    return bonusValue > 0 ? bonusValue : punishmentValue;
  }

  String get signal {
    return bonusValue > 0 ? '+' : '-';
  }

  static AllowanceEntrance fromMap(Map<String, dynamic> map) {
    var allowanceEntrance = AllowanceEntrance();

    allowanceEntrance = AllowanceEntrance(
      id: map['id'] ?? '',
      familyId: map['familyId'] ?? '',
      childUserId: map['childUserId'] ?? '',
      scheduleId: map['scheduleId'] ?? '',
      activityId: map['activityId'] ?? '',
      observation: map['observation'] ?? '',
      dateTime: map['dateTime'] == null
          ? null
          : DateTime.fromMicrosecondsSinceEpoch(map['dateTime'].microsecondsSinceEpoch),
      year: map['year'] ?? 0,
      month: map['month'] ?? 0,
      bonusValue: map['bonusValue'] ?? 0.0,
      punishmentValue: map['punishmentValue'] ?? 0.0,
    );

    return allowanceEntrance;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};

    r = {
      'id': id,
      'familyId': familyId,
      'childUserId': childUserId,
      'activityId': activityId,
      'scheduleId': scheduleId,
      'observation': observation,
      'dateTime': dateTime,
      'year': year,
      'month': month,
      'bonusValue': bonusValue,
      'punishmentValue': punishmentValue,
    };

    return r;
  }
}
