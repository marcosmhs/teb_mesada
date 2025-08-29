// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:teb_mesada/core/routes.dart';
import 'package:teb_mesada/features/family/family_controller.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_info_text.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/control_widgets/teb_text_edit.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/screen_widgets/teb_scaffold.dart';

class FamilyInvite extends StatefulWidget {
  const FamilyInvite({super.key});

  @override
  State<FamilyInvite> createState() => _FamilyInviteState();
}

class _FamilyInviteState extends State<FamilyInvite> {
  var _wait = false;
  void _submit() {
    setState(() => _wait = true);
    FamilyController(user: User())
        .getFamilyInvitationCode(invitationCode: '123')
        .then((family) {
          if (family.id.isEmpty) {
            TebMessage.error(context, message: 'Convite inválido!');
            setState(() => _wait = false);
            return;
          }
          Navigator.of(
            context,
          ).popAndPushNamed(Routes.userForm, arguments: {'family': family, 'familyInvite': true});
        })
        .onError((error, stackTrace) {
          TebMessage.error(context, message: 'Ocorreu um erro :(');
          setState(() => _wait = false);
        });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return TebScaffold(
      showAppBar: false,
      widthPercentage: 0.75,
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              Image(
                width: size.width * 0.55,
                fit: BoxFit.cover,
                image: const AssetImage('assets/img/logo.png'),
              ),
              TebInfoText(
                text:
                    'Se você foi convitedo para entrar para uma família no APP Mesada, informe abaixo o código do convite e clique em enviar',
              ),
              TebTextEdit(
                context: context,
                hintText: 'Informe o convite',
                labelText: 'Convite',
                padding: EdgeInsets.only(top: 20),
              ),

              TebButton(
                padding: EdgeInsets.only(top: 10),
                enabled: !_wait,
                size: Size.fromHeight(50),
                onPressed: () => _submit(),
                child: _wait
                    ? Row(
                        children: [CircularProgressIndicator(), TebText('Aguarde!', textSize: 20)],
                      )
                    : TebText(
                        'Entrar para a familia',
                        textSize: 20,
                        textColor: Theme.of(context).canvasColor,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
