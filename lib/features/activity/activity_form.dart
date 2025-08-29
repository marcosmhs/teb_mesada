// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_mesada/features/activity/activity.dart';
import 'package:teb_mesada/features/activity/activity_controller.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/control_widgets/teb_text_edit.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/screen_widgets/teb_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';

class ActivityForm extends StatefulWidget {
  const ActivityForm({super.key});

  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final _formKey = GlobalKey<FormState>();

  var _initializing = true;
  var _saveingData = false;
  var _family = Family();
  var _activity = Activity();

  void _submit() async {
    if (_saveingData) return;

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var activityController = ActivityController(family: _family);
      TebReturn tebReturn;
      try {
        tebReturn = await activityController.save(activity: _activity);
        if (tebReturn.returnType == TebReturnType.sucess) {
          TebMessage.sucess(context, message: 'Dados Alterado com sucesso');
          Navigator.of(context).pop();
        } else
        // se houve um erro no login ou no cadastro exibe o erro
        {
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
      _family = arguments['family'] ?? Family();
      _activity = arguments['activity'] ?? Activity();
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
                if (_activity.id.isEmpty) TitleTextWidget(text: 'Crie uma nova atividade'),
                if (_activity.id.isNotEmpty) TitleTextWidget(text: 'Altere o nome de uma atividade'),
                // name
                TebTextEdit(
                  context: context,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.only(bottom: 10),
                  controller: _activity.nameTextController,
                  labelText: 'Nome',
                  hintText: 'Nome da atividade',
                  onSave: (value) => _activity.name = value ?? '',
                  textInputAction: TextInputAction.next,
                  stringValueValidatorMessage: 'O nome deve ser informado',
                ),

                TebButton(
                  onPressed: () => _submit(),
                  size: Size.fromHeight(50),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: TebText('Confirmar', textSize: 20),
                ),

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
