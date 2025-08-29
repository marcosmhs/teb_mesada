import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/routes.dart';
import 'package:teb_mesada/core/widget/screen_structure_widget.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_mesada/features/user/user_controller.dart';
import 'package:teb_package/teb_package.dart';

class ChildScreen extends StatefulWidget {
  const ChildScreen({super.key});

  @override
  State<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
  var _family = Family();
  var _initializing = true;

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

      _family = arguments['family'] ?? Family();
      _initializing = false;
    }
    return ScreenStructureWidget(
      title: 'Crianças da família',
      newItemOnPressed: () {
        Navigator.of(context).pushNamed(Routes.userForm, arguments: {'family': _family, 'newChild': true});
      },
      body: FutureBuilder(
        future: UserController().getChildList(familyId: _family.id),
        builder: (context, snapshot) {
          List<User> childList = [];

          if (!snapshot.hasError && snapshot.hasData) {
            childList = snapshot.data!;
          }

          if (childList.isEmpty) {
            return TebText('Nenhuma atividade encontrada');
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: childList.length,
              itemBuilder: (context, index) {
                return ScreenStructureWidget.listItem(
                  leadingIcon: CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).canvasColor,
                    backgroundImage: NetworkImage(childList[index].imageUrl),
                  ),
                  title: childList[index].name,
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.userForm, arguments: {'family': _family, 'user': childList[index]});
                    },
                    icon: Icon(FontAwesomeIcons.pen),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
