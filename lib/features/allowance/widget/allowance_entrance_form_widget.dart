// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_mesada/features/allowance/allowance_controller.dart';
import 'package:teb_mesada/features/allowance/model/allowance_entrance.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_info_text.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/control_widgets/teb_text_edit.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/util/teb_return.dart';

class AllowanceEntranceFormWidget extends StatefulWidget {
  final Family family;
  final User childUser;
  final DateTime date;
  final Function()? onSave;
  const AllowanceEntranceFormWidget({
    super.key,
    required this.family,
    required this.childUser,
    required this.date,
    this.onSave,
  });

  @override
  State<AllowanceEntranceFormWidget> createState() => _AllowanceEntranceFormWidgetState();
}

class _AllowanceEntranceFormWidgetState extends State<AllowanceEntranceFormWidget> {
  final _formKey = GlobalKey<FormState>();
  var _allowanceEntrance = AllowanceEntrance();
  var _saveingData = false;
  var _errorMessage = '';

  final List<String> _months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  void _submit() async {
    if (_saveingData) return;

    setState(() => _errorMessage = '');
    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();

      if (_allowanceEntrance.bonusValue == 0 && _allowanceEntrance.punishmentValue == 0) {
        setState(
          () => _errorMessage = 'Informe um valor para adicionar ou para descontar da mesada',
        );
        _saveingData = false;
        return;
      }

      if (_allowanceEntrance.bonusValue > 0 && _allowanceEntrance.punishmentValue > 0) {
        setState(
          () => _errorMessage =
              'Informe um valor para adicionar OU para descontar da mesada, não é possível informar os dois',
        );
        _saveingData = false;
        return;
      }

      _allowanceEntrance.dateTime = widget.date;
      var allowanceController = AllowanceController(childUser: widget.childUser);
      TebReturn tebReturn;
      try {
        tebReturn = await allowanceController.addAllowanceValue(
          allowanceEntrance: _allowanceEntrance,
        );
        if (tebReturn.returnType == TebReturnType.sucess) {
          if (widget.onSave != null) widget.onSave!();
          _allowanceEntrance = AllowanceEntrance();
          TebMessage.sucess(context, message: 'Valor salvo!');
        } else {
          TebMessage.error(context, message: tebReturn.message);
        }
      } finally {
        _saveingData = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleTextWidget(text: '💵 Adicionar valores manualmente'),
              TebInfoText(
                text:
                    'O valor será adicionado para ${_months[widget.date.month - 1]} de ${widget.date.year}',
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TebTextEdit(
                          labelText: 'Motivo',
                          onSave: (value) => _allowanceEntrance.observation = value ?? '',
                          controller: _allowanceEntrance.observationTextController,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TebTextEdit(
                              labelText: 'Valor',
                              hintText: 'Valor adicionado',
                              width: 140,
                              onSave: (value) =>
                                  _allowanceEntrance.bonusValue = double.tryParse(value ?? '') ?? 0,
                              controller: _allowanceEntrance.bonusValueTextController,
                            ),
                            TebTextEdit(
                              labelText: 'Desconto',
                              hintText: 'Valor removido',
                              width: 140,
                              onSave: (value) => _allowanceEntrance.punishmentValue =
                                  double.tryParse(value ?? '') ?? 0,
                              controller: _allowanceEntrance.punishmentValueTextController,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: TebButton(
                  onPressed: () => _submit(),
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  icon: Icon(FontAwesomeIcons.moneyBill1),
                  child: TebText('Salvar', textWeight: FontWeight.bold),
                ),
              ),

              if (_errorMessage.isNotEmpty)
                TebText(
                  _errorMessage,
                  padding: EdgeInsets.all(8),
                  textColor: Theme.of(context).colorScheme.error,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
