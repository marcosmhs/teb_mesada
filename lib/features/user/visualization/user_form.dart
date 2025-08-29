// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teb_mesada/core/routes.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_mesada/features/user/user_controller.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_info_text.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/control_widgets/teb_text_edit.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/screen_widgets/teb_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  var _saveingData = false;
  var _initializing = true;
  var _family = Family();
  var _familyInvite = false;
  var _user = User();
  var _newUser = false;
  var _newChild = false;

  void _submit({required bool sendToFamilyForm}) async {
    if (_saveingData) return;

    setState(() => _saveingData = true);

    if (!(_formKey.currentState?.validate() ?? true)) {
      setState(() => _saveingData = false);
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var userController = UserController();
      TebReturn retorno;
      try {
        retorno = await userController.save(user: _user);
        if (retorno.returnType == TebReturnType.sucess) {
          if (_newChild) {
            TebMessage.sucess(context, message: 'Conta da Criança criada com sucesso');
            Navigator.of(context).pop();
          } else {
            if (_newUser) {
              TebMessage.sucess(context, message: 'Sua conta foi criada com sucesso');
              if (_familyInvite) {
                Navigator.of(context).popAndPushNamed(Routes.loginScreen);
              } else {
                Navigator.of(context).popAndPushNamed(
                  Routes.familyForm,
                  arguments: {'user': userController.currentUser},
                );
              }
            } else {
              TebMessage.sucess(context, message: 'Dados Alterado com sucesso');
              if (sendToFamilyForm) {
                Navigator.of(context).popAndPushNamed(
                  Routes.familyForm,
                  arguments: {'user': userController.currentUser},
                );
              } else {
                Navigator.of(context).pop();
              }
            }
          }
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == TebReturnType.error) {
          TebMessage.error(context, message: retorno.message);
        }
      } finally {
        setState(() => _saveingData = false);
      }
    }
  }

  Widget _childPhotoWidget() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).canvasColor,
            backgroundImage: NetworkImage(
              _user.childLocalPhotoPath.isNotEmpty ? _user.childLocalPhotoPath : _user.imageUrl,
            ),
          ),
          const SizedBox(width: 20),
          TebButton(
            label: 'Carregar foto da criança',
            onPressed: () async {
              ImagePicker imagePicker = ImagePicker();
              XFile? selectedPhoto = await imagePicker.pickImage(source: ImageSource.gallery);
              if (selectedPhoto != null) {
                setState(() {
                  _user.childLocalPhotoPath = selectedPhoto.path;
                  selectedPhoto.readAsBytes().then((value) {
                    _user.childUint8ListPhoto = value;
                  });
                });
              }
              //}
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _family = arguments['family'] ?? Family();
      _familyInvite = arguments['familyInvite'] ?? false;
      _user = arguments['user'] ?? User();
      _user = User.fromMap(map: _user.toMap);
      _newUser = _user.id.isEmpty;
      _newChild = arguments['newChild'] ?? false;

      if (_familyInvite) _user.familyId = _family.id;

      if (_newChild) {
        _user.familyId = _family.id;
        _user.userType = UserType.child;
      }

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
                if (_user.id.isEmpty)
                  TitleTextWidget(
                    text: _user.userType == UserType.child
                        ? 'Informe os dados da criança'
                        : 'Preencha os dados abaixo para criar sua conta',
                  ),
                if (_user.id.isNotEmpty)
                  TitleTextWidget(
                    text: _user.userType == UserType.child
                        ? 'Altere os dados da criança'
                        : 'Altere os dados de sua conta',
                  ),
                if (_user.userType == UserType.child) _childPhotoWidget(),

                if (_familyInvite)
                  TebInfoText(
                    text:
                        'Você foi convidado para participar da família ${_family.name}! Preencha seus dados abaixo para criar sua conta de acesso',
                  ),

                // name
                TebTextEdit(
                  context: context,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.only(bottom: 10),
                  controller: _user.nameTextController,
                  labelText: 'Nome',
                  hintText: 'Informe seu nome',
                  onSave: (value) => _user.name = value ?? '',
                  prefixIcon: Icons.person,
                  textInputAction: TextInputAction.next,
                  focusNode: _nameFocus,
                  nextFocusNode: _phoneFocus,
                  stringValueValidatorMessage: 'O nome deve ser informado',
                ),
                // phone
                TebTextEdit(
                  context: context,
                  controller: _user.phoneTextController,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.only(bottom: 10),
                  labelText: 'Celular',
                  hintText: 'Seu celular',
                  onSave: (value) => _user.phone = value ?? '',
                  prefixIcon: FontAwesomeIcons.phone,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _phoneFocus,
                  nextFocusNode: _emailFocus,
                  validator: (value) {
                    final finalValue = value ?? '';
                    if (_user.userType != UserType.child &&
                        (finalValue.trim().isEmpty || finalValue.trim() == '55')) {
                      return 'O celular deve ser informado';
                    }

                    return null;
                  },
                ),
                if (_newChild)
                  TebInfoText(
                    text:
                        'O e-mail da criança deve ser diferente do e-mail dos responsáveis para que ela possa acessar sua conta de forma individual',
                  ),
                // e-mail
                TebTextEdit(
                  context: context,
                  controller: _user.emailTextController,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.only(bottom: 10),
                  labelText: 'Email',
                  hintText: 'Seu e-mail',
                  onSave: (value) => _user.email = value ?? '',
                  prefixIcon: Icons.person,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _emailFocus,
                  nextFocusNode: _passwordFocus,
                  stringValueValidatorMessage: 'O e-mail deve ser informado',
                ),
                // password
                TebTextEdit(
                  context: context,
                  controller: _user.passwordTextController,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.only(bottom: 10),
                  labelText: 'Senha',
                  hintText: 'Informe sua senha',
                  isPassword: true,
                  onSave: (value) {
                    if (value != null && value.isNotEmpty) _user.setPassword(value);
                  },
                  prefixIcon: Icons.lock,
                  textInputAction: TextInputAction.next,
                  focusNode: _passwordFocus,
                  nextFocusNode: _confirmPasswordFocus,
                  validator: (value) {
                    final finalValue = value ?? '';
                    // em uma edição a checagem só deve ser feita se houve edição
                    if (finalValue.trim().isNotEmpty &&
                        _confirmPasswordController.text.isNotEmpty) {
                      if (finalValue.trim().isEmpty) return 'Informe a senha';
                      if (finalValue.trim().length < 6) {
                        return 'Senha deve possuir 6 ou mais caracteres';
                      }
                      if (finalValue != _confirmPasswordController.text) {
                        return 'As senhas digitadas não são iguais';
                      }
                    }

                    return null;
                  },
                ),
                // password confirmation
                TebTextEdit(
                  context: context,
                  controller: _confirmPasswordController,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.only(bottom: 10),
                  labelText: 'Repita a senha',
                  hintText: 'Informe sua senha novamente',
                  isPassword: true,
                  prefixIcon: Icons.lock,
                  textInputAction: TextInputAction.next,
                  focusNode: _confirmPasswordFocus,
                  validator: (value) {
                    final finalValue = value ?? '';
                    if (finalValue.trim().isNotEmpty &&
                        _user.passwordTextController.text.isNotEmpty) {
                      if (finalValue.trim().isEmpty) return 'Informe a senha';
                      if (finalValue.trim().length < 6) {
                        return 'Senha deve possuir 6 ou mais caracteres';
                      }
                      if (finalValue != _user.passwordTextController.text) {
                        return 'As senhas digitadas não são iguais';
                      }
                    }
                    return null;
                  },
                ),

                if (_newUser && _user.userType != UserType.child && !_familyInvite)
                  TebButton(
                    onPressed: () => _submit(sendToFamilyForm: true),
                    size: Size(250, 50),
                    buttonType: TebButtonType.elevatedButton,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: TebText(
                      'Dados de sua família  ->',
                      textSize: 20,
                      textColor: Theme.of(context).canvasColor,
                    ),
                  )
                else
                  TebButton(
                    onPressed: () => _submit(sendToFamilyForm: false),
                    size: Size(250, 50),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    enabled: !_saveingData,
                    child: _saveingData
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Theme.of(context).canvasColor),
                              TebText(
                                'Salvando dados',
                                padding: EdgeInsets.only(left: 20),
                                textSize: 20,
                                textColor: Theme.of(context).canvasColor,
                              ),
                            ],
                          )
                        : TebText(
                            'Confirmar',
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
