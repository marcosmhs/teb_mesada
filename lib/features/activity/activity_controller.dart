import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teb_mesada/features/activity/activity.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class ActivityController {
  final Family family;

  ActivityController({required this.family});

  Future<List<Activity>> get getActivityList async {
    final snapshot = await FirebaseFirestore.instance
        .collection(Family.collectionName)
        .doc(family.id)
        .collection(Activity.collectionName)
        .get();

    List<Activity> activityList = [];

    for (var doc in snapshot.docs) {
      final activity = Activity.fromMap(doc.data());
      activityList.add(activity);
    }

    activityList.sort((a, b) => a.name.compareTo(b.name));
    return activityList;
  }

  Future<Activity> getActivityById({required String id}) async {
    final dataRef = await FirebaseFirestore.instance
        .collection(Family.collectionName)
        .doc(family.id)
        .collection(Activity.collectionName)
        .doc(id)
        .get();

    final data = dataRef.data();

    if (data == null) return Activity();

    return Activity.fromMap(data);
  }

  Future<TebReturn> save({required Activity activity}) async {
    try {
      if (activity.id.isEmpty) activity.id = TebUidGenerator.firestoreUid;

      await FirebaseFirestore.instance
          .collection(Family.collectionName)
          .doc(family.id)
          .collection(Activity.collectionName)
          .doc(activity.id)
          .set(activity.toMap);

      return TebReturn.sucess;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  Future<TebReturn> delete({required Activity activity}) async {
    try {
      await FirebaseFirestore.instance
          .collection(Family.collectionName)
          .doc(family.id)
          .collection(Activity.collectionName)
          .doc(activity.id)
          .delete();

      return TebReturn.sucess;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }
}
