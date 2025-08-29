class Allowance {
  static const collectionName = 'allowance';

  late String id;
  late String familyId;
  late String childUserId;
  late int year;
  late int month;
  late double totalBonusValue;
  late double totalPunishmentValue;

  Allowance({
    this.id = '',
    this.familyId = '',
    this.childUserId = '',
    this.year = 0,
    this.month = 0,
    this.totalBonusValue = 0.0,
    this.totalPunishmentValue = 0.0,
  });

  double get totalValue => totalBonusValue - totalPunishmentValue;

  static Allowance fromMap(Map<String, dynamic> map) {
    var family = Allowance();

    family = Allowance(
      id: map['id'] ?? '',
      familyId: map['familyId'] ?? '',
      childUserId: map['childUserId'] ?? '',
      year: map['year'] ?? 0,
      month: map['month'] ?? 0,
      totalBonusValue: map['totalBonusValue'] ?? 0.0,
      totalPunishmentValue: map['totalPunishmentValue'] ?? 0.0,
    );

    return family;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};

    r = {
      'id': id,
      'familyId': familyId,
      'childUserId': childUserId,
      'year': year,
      'month': month,
      'totalBonusValue': totalBonusValue,
      'totalPunishmentValue': totalPunishmentValue,
    };

    return r;
  }
}
