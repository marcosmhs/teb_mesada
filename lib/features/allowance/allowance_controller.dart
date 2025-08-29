import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teb_mesada/features/allowance/model/allowance.dart';
import 'package:teb_mesada/features/allowance/model/allowance_entrance.dart';
import 'package:teb_mesada/features/schedule/model/schedule.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_package/teb_package.dart';

class AllowanceController {
  final User childUser;

  AllowanceController({required this.childUser});

  Future<Allowance> getAllowanceByMonth({required int year, required int month}) async {
    var snapshot = await FirebaseFirestore.instance
        .collection(User.collectionName)
        .doc(childUser.id)
        .collection(Allowance.collectionName)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .get();

    if (snapshot.docs.isEmpty) return Allowance();

    return Allowance.fromMap(snapshot.docs.first.data());
  }

  Future<List<AllowanceEntrance>> getAllowanceEntranceListByMonth({
    required int year,
    required int month,
  }) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    snapshot = await FirebaseFirestore.instance
        .collection(User.collectionName)
        .doc(childUser.id)
        .collection(AllowanceEntrance.collectionName)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .get();

    List<AllowanceEntrance> allowanceEntranceList = [];

    if (snapshot.docs.isEmpty) return allowanceEntranceList;

    for (var doc in snapshot.docs) {
      final allowanceEntrance = AllowanceEntrance.fromMap(doc.data());
      allowanceEntranceList.add(allowanceEntrance);
    }

    return allowanceEntranceList;
  }

  Future<AllowanceEntrance> getAllowanceEntranceListByActivityId({
    required int year,
    required int month,
    String activityId = '',
  }) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    snapshot = await FirebaseFirestore.instance
        .collection(User.collectionName)
        .doc(childUser.id)
        .collection(AllowanceEntrance.collectionName)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .where('activityId', isEqualTo: activityId)
        .get();

    var allowanceEntrance = AllowanceEntrance();
    if (snapshot.docs.isEmpty) return allowanceEntrance;
    allowanceEntrance = AllowanceEntrance.fromMap(snapshot.docs.first.data());
    return allowanceEntrance;
  }

  Future<TebReturn> addAllowanceValueByActivity({
    required Schedule schedule,
    required DateTime date,
  }) async {
    if (!schedule.hasAppointment(date)) {
      return TebReturn.error('A atividade não foi concluída');
    }

    try {
      var allowanceEntrance = AllowanceEntrance();
      allowanceEntrance.activityId = schedule.activityId;
      allowanceEntrance.scheduleId = schedule.id;
      allowanceEntrance.bonusValue = schedule.consequenceValue;
      allowanceEntrance.observation = schedule.activity.name;
      allowanceEntrance.year = date.year;
      allowanceEntrance.month = date.month;

      return await addAllowanceValue(allowanceEntrance: allowanceEntrance);
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  Future<TebReturn> addAllowanceValue({required AllowanceEntrance allowanceEntrance}) async {
    try {
      var today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      var allowance = await getAllowanceByMonth(
        year: allowanceEntrance.year,
        month: allowanceEntrance.month,
      );

      if (allowance.id.isEmpty) {
        allowance.id = TebUidGenerator.firestoreUid;
        allowance.familyId = childUser.familyId;
        allowance.childUserId = childUser.id;
        allowance.year = allowanceEntrance.year;
        allowance.month = allowanceEntrance.month;
      }

      if (allowanceEntrance.id.isEmpty) {
        allowanceEntrance.id = TebUidGenerator.firestoreUid;
        allowanceEntrance.familyId = childUser.familyId;
        allowanceEntrance.childUserId = childUser.id;
        allowanceEntrance.dateTime = today;
        allowanceEntrance.year = today.year;
        allowanceEntrance.month = today.month;
        allowance.totalBonusValue = allowance.totalBonusValue + allowanceEntrance.bonusValue;
        allowance.totalPunishmentValue =
            allowance.totalPunishmentValue + allowanceEntrance.punishmentValue;
      }

      await FirebaseFirestore.instance
          .collection(User.collectionName)
          .doc(childUser.id)
          .collection(AllowanceEntrance.collectionName)
          .doc(allowanceEntrance.id)
          .set(allowanceEntrance.toMap);

      await FirebaseFirestore.instance
          .collection(User.collectionName)
          .doc(childUser.id)
          .collection(Allowance.collectionName)
          .doc(allowance.id)
          .set(allowance.toMap);

      return TebReturn.sucess;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  Future<TebReturn> removeAllowanceValue({required AllowanceEntrance allowanceEntrance}) async {
    try {
      var allowance = await getAllowanceByMonth(
        year: allowanceEntrance.year,
        month: allowanceEntrance.month,
      );

      allowance.totalBonusValue = allowance.totalBonusValue - allowanceEntrance.bonusValue;
      allowance.totalPunishmentValue =
          allowance.totalPunishmentValue - allowanceEntrance.punishmentValue;

      await FirebaseFirestore.instance
          .collection(User.collectionName)
          .doc(childUser.id)
          .collection(AllowanceEntrance.collectionName)
          .doc(allowanceEntrance.id)
          .delete();

      await FirebaseFirestore.instance
          .collection(User.collectionName)
          .doc(childUser.id)
          .collection(Allowance.collectionName)
          .doc(allowance.id)
          .set(allowance.toMap);

      return TebReturn.sucess;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }
}
