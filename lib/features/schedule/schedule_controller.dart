import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teb_mesada/features/activity/activity.dart';
import 'package:teb_mesada/features/activity/activity_controller.dart';
import 'package:teb_mesada/features/allowance/allowance_controller.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/schedule/model/schedule.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_mesada/features/user/user_controller.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class ScheduleController {
  final Family family;

  ScheduleController({required this.family});

  Future<List<Schedule>> getScheduleList({User? childUser}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (childUser != null && childUser.id.isNotEmpty) {
      snapshot = await FirebaseFirestore.instance
          .collection(Family.collectionName)
          .doc(family.id)
          .collection(Schedule.collectionName)
          .where('childUserId', isEqualTo: childUser.id)
          .get();
    } else {
      snapshot = await FirebaseFirestore.instance
          .collection(Family.collectionName)
          .doc(family.id)
          .collection(Schedule.collectionName)
          .get();
    }

    List<Schedule> scheduleList = [];

    if (snapshot.docs.isEmpty) return scheduleList;

    List<Activity> activityList = await ActivityController(family: family).getActivityList;

    for (var doc in snapshot.docs) {
      final schedule = Schedule.fromMap(doc.data());
      schedule.activity = activityList.singleWhere((a) => a.id == schedule.activityId);
      scheduleList.add(schedule);
    }

    return scheduleList;
  }

  Future<Schedule> getScheduleById({required String id}) async {
    final dataRef = await FirebaseFirestore.instance
        .collection(Family.collectionName)
        .doc(family.id)
        .collection(Schedule.collectionName)
        .doc(id)
        .get();

    final data = dataRef.data();

    if (data == null) return Schedule();

    var schedule = Schedule.fromMap(data);
    schedule.activity = await ActivityController(
      family: family,
    ).getActivityById(id: schedule.activityId);

    return schedule;
  }

  Future<TebReturn> save({required Schedule schedule}) async {
    try {
      if (schedule.id.isEmpty) schedule.id = TebUidGenerator.firestoreUid;

      await FirebaseFirestore.instance
          .collection(Family.collectionName)
          .doc(family.id)
          .collection(Schedule.collectionName)
          .doc(schedule.id)
          .set(schedule.toMap);

      return TebReturn.sucess;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  Future<TebReturn> delete({required Schedule schedule}) async {
    try {
      await FirebaseFirestore.instance
          .collection(Family.collectionName)
          .doc(family.id)
          .collection(Schedule.collectionName)
          .doc(schedule.id)
          .delete();

      return TebReturn.sucess;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  Future<TebReturn> registerAppointment({
    required Schedule schedule,
    required bool done,
    required DateTime date,
  }) async {
    try {
      var appointmentDate = DateTime(date.year, date.month, date.day);

      if (schedule.positiveConsequence && schedule.consequenceValue == 0) {
        return TebReturn.error(
          'Esta atividade possui deveria possuir um valor para ser adicionado a mesada',
        );
      }

      schedule.appointments[appointmentDate] = done;

      var tebReturn = await ScheduleController(family: family).save(schedule: schedule);

      if (!schedule.positiveConsequence) {
        return tebReturn;
      } else {
        if (tebReturn.returnType == TebReturnType.error) {
          return TebReturn.error(tebReturn.message);
        } else {
          var childUser = await UserController().getUserById(id: schedule.childUserId);
          var allowanceController = AllowanceController(childUser: childUser);
          if (done) {
            return await allowanceController.addAllowanceValueByActivity(
              schedule: schedule,
              date: date,
            );
          } else {
            var allowanceEntrance = await allowanceController.getAllowanceEntranceListByActivityId(
              year: date.year,
              month: date.month,
              activityId: schedule.activityId,
            );

            // existe apenas uma entrada
            return await allowanceController.removeAllowanceValue(
              allowanceEntrance: allowanceEntrance,
            );
          }
        }
      }
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }
}
