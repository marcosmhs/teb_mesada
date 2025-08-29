import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_mesada/features/user/user_controller.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class FamilyController {
  final User user;

  FamilyController({required this.user});

  Future<TebReturn> save({required Family family, required User user}) async {
    try {
      var newFamily = family.id.isEmpty;
      if (family.id.isEmpty) family.id = TebUidGenerator.firestoreUid;

      await FirebaseFirestore.instance.collection(Family.collectionName).doc(family.id).set(family.toMap);

      if (newFamily) {
        user.familyId = family.id;
        var tebReturn = await UserController().save(user: user);
        if (tebReturn.returnType == TebReturnType.error) {
          return tebReturn;
        }
      }
      return TebReturn.sucess;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  Future<Family> getFamilyById({required String id}) async {
    final dataRef = await FirebaseFirestore.instance.collection(Family.collectionName).doc(id).get();
    final data = dataRef.data();

    if (data == null) return Family();

    return Family.fromMap(data);
  }

  Future<Family> getFamilyInvitationCode({required String invitationCode}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(Family.collectionName)
        .where("invitationCode", isEqualTo: invitationCode)
        .get();

    if (snapshot.docs.isEmpty) return Family();

    List<Family> familyList = [];

    for (var doc in snapshot.docs) {
      final activity = Family.fromMap(doc.data());
      familyList.add(activity);
    }

    return familyList.first;
  }
}
