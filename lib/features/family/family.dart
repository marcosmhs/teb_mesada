import 'package:flutter/material.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class Family {
  static const collectionName = 'family';

  late String id;
  late String name;
  late String invitationCode;
  late String ownerUserId;

  late TextEditingController nameTextController = TextEditingController();
  late TextEditingController invitationCodeTextController = TextEditingController();

  Family({this.id = '', this.name = '', String invitationCode = '', this.ownerUserId = ''}) {
    this.invitationCode = invitationCode.isNotEmpty
        ? invitationCode
        : TebUidGenerator.customInvitationCode();
    nameTextController.text = name;
    invitationCodeTextController.text = this.invitationCode;
  }

  String get invitationUrl {
    return 'https://wa.me/?text=Acesse "https://teb-mesada.web.app/#family_invite e utilize o código $invitationCode para entrar para a família ${nameTextController.text}"';
  }

  static Family fromMap(Map<String, dynamic> map) {
    var family = Family();

    family = Family(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      invitationCode: map['invitationCode'] ?? '',
      ownerUserId: map['ownerUserId'] ?? '',
    );

    return family;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};

    r = {'id': id, 'name': name, 'invitationCode': invitationCode, 'ownerUserId': ownerUserId};

    return r;
  }
}
