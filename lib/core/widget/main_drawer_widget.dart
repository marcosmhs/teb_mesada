// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:teb_mesada/core/routes.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_mesada/features/user/user_controller.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/messaging/teb_dialog.dart';
import 'package:teb_package/util/teb_util.dart';

class MainDrawerWidget extends StatefulWidget {
  final User user;
  final Family family;
  const MainDrawerWidget({super.key, required this.user, required this.family});

  @override
  State<MainDrawerWidget> createState() => _MainDrawerWidgetState();
}

class _MainDrawerWidgetState extends State<MainDrawerWidget> {
  var _info = TebUtil.packageInfo;
  var _initializing = true;

  Widget _userdata() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: GestureDetector(
        onTap: () => Navigator.of(
          context,
        ).popAndPushNamed(Routes.userForm, arguments: {'user': widget.user}),
        child: Row(
          children: [
            SizedBox(width: 10),
            CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).canvasColor,
              child: TebText(
                widget.user.initials,
                textColor: Theme.of(context).primaryColor,
                textSize: 25,
                textWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TebText(
                  widget.user.firstName,
                  textColor: Theme.of(context).canvasColor,
                  textSize: 16,
                  padding: EdgeInsets.only(bottom: 10),
                ),
                TebText('Ver Perfil >', textColor: Theme.of(context).canvasColor, textSize: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      TebUtil.version.then((info) => setState(() => _info = info));
      _initializing = false;
    }

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _userdata(),
          const SizedBox(height: 20),
          if (widget.user.userType == UserType.parent)
            ListTile(
              title: const TebText('Dados Família'),
              onTap: () => Navigator.of(context).popAndPushNamed(
                Routes.familyForm,
                arguments: {'user': widget.user, 'family': widget.family},
              ),
            ),
          if (widget.user.userType == UserType.parent)
            ListTile(
              title: const TebText('Crianças'),
              onTap: () => Navigator.of(context).popAndPushNamed(
                Routes.childScreen,
                arguments: {'user': widget.user, 'family': widget.family},
              ),
            ),
          if (widget.user.userType == UserType.parent)
            ListTile(
              title: const TebText('Atividades'),
              onTap: () => Navigator.of(
                context,
              ).popAndPushNamed(Routes.activityScreen, arguments: {'family': widget.family}),
            ),
          if (widget.user.userType == UserType.parent)
            ListTile(
              title: const TebText('Programação das atividades'),
              onTap: () => Navigator.of(
                context,
              ).popAndPushNamed(Routes.scheduleScreen, arguments: {'family': widget.family}),
            ),

          const Spacer(),

          if (widget.user.id.isNotEmpty)
            ListTile(
              title: const TebText('Sair'),
              onTap: () {
                TebDialog(
                  context: context,
                ).confirmationDialog(message: 'Deseja realmente sair?').then((value) {
                  if ((value ?? false)) {
                    UserController().logoff();
                    Navigator.restorablePushNamedAndRemoveUntil(
                      context,
                      Routes.loginScreen,
                      (route) => false,
                    );
                  }
                });
              },
            ),
          ListTile(
            title: TebText(
              "v${_info.version}.${_info.buildNumber}",
              textColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.only(top: 10),
            ),
          ),
          if (widget.user.id.isNotEmpty) SizedBox(height: 20),
        ],
      ),
    );
  }
}
