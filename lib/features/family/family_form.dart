// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/routes.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_mesada/features/family/family_controller.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_info_text.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/control_widgets/teb_text_edit.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/screen_widgets/teb_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:url_launcher/url_launcher.dart';

class FamilyForm extends StatefulWidget {
  final User? user;
  const FamilyForm({super.key, this.user});

  @override
  State<FamilyForm> createState() => _FamilyFormState();
}

class _FamilyFormState extends State<FamilyForm> {
  final _formKey = GlobalKey<FormState>();

  var _initializing = true;
  var _saveingData = false;
  var _newFamily = false;
  var _user = User();
  var _family = Family();

  void _submit({required bool sendToAdressForm}) async {
    if (_saveingData) return;

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var familyController = FamilyController(user: _user);
      TebReturn tebReturn;
      try {
        tebReturn = await familyController.save(family: _family, user: _user);
        if (tebReturn.returnType == TebReturnType.sucess) {
          if (_newFamily) {
            TebMessage.sucess(context, message: 'Dados de sua família criados com sucesso');
            Navigator.of(context).popAndPushNamed(Routes.landingScreen);
          } else {
            TebMessage.sucess(context, message: 'Dados Alterado com sucesso');
            Navigator.of(context).pop();
          }
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (tebReturn.returnType == TebReturnType.error) {
          TebMessage.error(context, message: tebReturn.message);
        }
      } finally {
        _saveingData = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();
      if (widget.user != null && widget.user!.id.isNotEmpty) _user = widget.user!;
      _family = arguments['family'] ?? Family();
      _newFamily = _family.id.isEmpty;

      _initializing = false;
    }

    return TebScaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        elevation: 0,
      ),
      widthPercentage: 0.95,
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_family.id.isEmpty)
                  TitleTextWidget(text: 'Preencha as informações de sua família'),
                if (_family.id.isNotEmpty)
                  TitleTextWidget(text: 'Altere as informações de sua família'),
                // name
                TebTextEdit(
                  context: context,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.only(bottom: 10),
                  controller: _family.nameTextController,
                  labelText: 'Nome',
                  hintText: 'Qual o nome de sua família',
                  onSave: (value) => _family.name = value ?? '',
                  textInputAction: TextInputAction.next,
                  stringValueValidatorMessage: 'O nome deve ser informado',
                ),
                TebInfoText(
                  padding: EdgeInsets.only(bottom: 10, top: 20),
                  text:
                      'Utilize o código abaixo para convidar outras pessoas para fazerem parte de sua família.'
                      ' Utilize as opções ao lado para: Enviar o código para um contato no WhatsApp ou para'
                      ' copiar para sua área de transferência',
                ),
                // invitation code
                Row(
                  children: [
                    Expanded(
                      child: TebTextEdit(
                        context: context,
                        controller: _family.invitationCodeTextController,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        labelText: 'Código de convite',
                        enabled: false,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton.outlined(
                      onPressed: () {
                        if (_family.nameTextController.text.isEmpty) {
                          TebMessage.error(
                            context,
                            message: 'Preencha o nome de sua família antes',
                          );
                          return;
                        }
                        canLaunchUrl(Uri.parse(_family.invitationUrl)).then((value) {
                          if (value) {
                            launchUrl(Uri.parse(_family.invitationUrl));
                          } else {
                            TebMessage.error(
                              context,
                              message:
                                  'Não possível abrir o WhatsApp, verifique seu telefone ou '
                                  'utilize a opção para copiar para área de transferência!',
                            );
                          }
                        });
                      },
                      icon: Icon(FontAwesomeIcons.whatsapp),
                    ),
                    const SizedBox(width: 10),
                    IconButton.outlined(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _family.invitationCodeTextController.text),
                        );
                        TebMessage.sucess(
                          context,
                          message: 'Código copiado para sua área de transferência!',
                        );
                      },
                      icon: Icon(FontAwesomeIcons.copy),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TebButton(
                  onPressed: () => _submit(sendToAdressForm: false),
                  size: Size(250, 50),
                  buttonType: TebButtonType.elevatedButton,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: TebText(
                    'Salvar',
                    textSize: 20,
                    textColor: Theme.of(context).canvasColor,
                  ),
                ),
                const SizedBox(height: 10),
                TebButton(
                  size: Size(150, 50),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  onPressed: () => Navigator.of(context).pop(),
                  enabled: !_saveingData,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: TebText('Cancelar', textSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
