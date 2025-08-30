// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/routes.dart';
import 'package:teb_mesada/core/widget/about_widget.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_mesada/features/user/user_controller.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/control_widgets/teb_text_edit.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/screen_widgets/teb_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  var _initializing = true;

  late String _email = '';
  late String _password = '';

  // utilizado para o controle de foco
  final _passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    setState(() => _isLoading = true);
    if (!(_formKey.currentState?.validate() ?? true)) {
      setState(() => _isLoading = false);
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var userController = UserController();
      try {
        User user = User();
        user.email = _email;
        user.setPassword(TebUtil.encrypt(_password));
        var loginReturnMap = await userController.login(user: user);
        var loginReturn = loginReturnMap['TebReturn'] as TebReturn;

        if (loginReturn.returnType == TebReturnType.sucess) {
          if (loginReturnMap['nextRoute'] == Routes.userAdressForm) {
            TebMessage.info(context, message: 'Você precisa informar seu endereço para continuar');
            Navigator.of(context).popAndPushNamed(
              loginReturnMap['nextRoute'],
              arguments: {'user': userController.currentUser},
            );
          } else {
            Navigator.restorablePushNamedAndRemoveUntil(
              context,
              loginReturnMap['nextRoute'],
              (route) => false,
            );
          }
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (loginReturn.returnType == TebReturnType.error) {
          TebMessage.error(context, message: loginReturn.message);
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _logo(Size size) {
    return Image(
      width: size.width * 0.90,
      fit: BoxFit.cover,
      image: const AssetImage('assets/img/logo.png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      _initializing = false;
      if (_password.isNotEmpty) _passwordController.text = _password;
      if (_email.isNotEmpty) _emailController.text = _email;
    }
    final Size size = MediaQuery.of(context).size;

    return TebScaffold(
      showAppBar: false,
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const TebText('Mesada', textSize: 50, textWeight: FontWeight.bold),
              const SizedBox(height: 20),
              _logo(size),
              const SizedBox(height: 20),
              SizedBox(
                width: size.width * 0.95,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TebTextEdit(
                            context: context,
                            controller: _emailController,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            isDense: false,
                            labelText: 'E-mail',
                            hintText: 'Informe seu e-mail',
                            onSave: (value) => _email = value ?? '',
                            prefixIcon: const Icon(FontAwesomeIcons.user).icon,
                            nextFocusNode: _passwordFocus,
                            validator: (value) {
                              final finalValue = value ?? '';
                              if (finalValue.trim().isEmpty) return 'Informe o e-mail';
                              if (!finalValue.contains('@') || !finalValue.contains('.')) {
                                return 'Informe um e-mail válido';
                              }
                              return null;
                            },
                          ),
                          TebTextEdit(
                            context: context,
                            controller: _passwordController,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            isDense: false,
                            labelText: 'Senha',
                            hintText: 'Informe sua senha',
                            isPassword: true,
                            onSave: (value) => _password = value ?? '',
                            prefixIcon: const FaIcon(FontAwesomeIcons.lock).icon,
                            textInputAction: TextInputAction.done,
                            focusNode: _passwordFocus,
                            validator: (value) {
                              final finalValue = value ?? '';
                              if (finalValue.trim().isEmpty) return 'Informe a senha';
                              if (finalValue.trim().length < 6) {
                                return 'Senha deve possuir 6 ou mais caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          _isLoading
                              ? const CircularProgressIndicator.adaptive()
                              : Column(
                                  children: [
                                    TebButton(
                                      onPressed: _login,
                                      size: Size(150, 50),
                                      child: TebText(
                                        'Entrar',
                                        textSize: 22,
                                        textColor: Theme.of(context).canvasColor,
                                      ),
                                    ),
                                    TebText(
                                      'Entrar para uma família',
                                      textSize: 16,
                                      textWeight: FontWeight.bold,
                                      padding: EdgeInsets.only(top: 40, bottom: 20),
                                      onTap: () => Navigator.of(
                                        context,
                                      ).popAndPushNamed(Routes.familyInvite),
                                    ),

                                    TebText(
                                      'Criar sua conta',
                                      textSize: 16,
                                      textWeight: FontWeight.bold,
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      onTap: () =>
                                          Navigator.of(context).popAndPushNamed(Routes.userForm),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              AboutWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
