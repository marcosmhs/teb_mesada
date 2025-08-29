// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_mesada/features/activity/activity_widget.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/schedule/model/schedule.dart';
import 'package:teb_mesada/features/schedule/schedule_controller.dart';
import 'package:teb_mesada/features/schedule/widget/schedule_frequency_widget.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_mesada/features/user/user_controller.dart';
import 'package:teb_mesada/features/user/user_local_data_controller.dart';
import 'package:teb_mesada/features/user/widget/child_widget.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_checkbox.dart';
import 'package:teb_package/control_widgets/teb_datetimeselector.dart';
import 'package:teb_package/control_widgets/teb_info_text.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/control_widgets/teb_text_edit.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/screen_widgets/teb_scaffold.dart';

import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_util.dart';

class ScheduleForm extends StatefulWidget {
  const ScheduleForm({super.key});

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();

  var _initializing = true;
  var _saveingData = false;
  var _family = Family();
  var _schedule = Schedule();
  var _childUser = User(userType: UserType.child);
  int _index = 0;

  void _submit() async {
    if (_saveingData) return;

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var scheduleController = ScheduleController(family: _family);
      TebReturn tebReturn;
      try {
        tebReturn = await scheduleController.save(schedule: _schedule);
        if (tebReturn.returnType == TebReturnType.sucess) {
          TebMessage.sucess(context, message: 'Dados Alterado com sucesso');
          Navigator.of(context).pop();
        } else {
          TebMessage.error(context, message: tebReturn.message);
        }
      } finally {
        _saveingData = false;
      }
    }
  }

  // Summary

  Widget _scheduleSummaryWidget() {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              _schedule.childUserId.isNotEmpty
                  ? FontAwesomeIcons.solidSquareCheck
                  : FontAwesomeIcons.square,
              color: _schedule.childUserId.isNotEmpty ? Theme.of(context).primaryColor : null,
            ),
            TebText(
              'Criança:',
              textSize: 18,
              textWeight: FontWeight.bold,
              padding: EdgeInsets.only(left: 10),
            ),
            TebText(_childUser.firstName, textSize: 18, padding: EdgeInsets.only(left: 10)),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(
              _schedule.activity.id.isNotEmpty
                  ? FontAwesomeIcons.solidSquareCheck
                  : FontAwesomeIcons.square,
              color: _schedule.activity.id.isNotEmpty ? Theme.of(context).primaryColor : null,
            ),
            TebText(
              'Atividade:',
              textSize: 18,
              textWeight: FontWeight.bold,
              padding: EdgeInsets.only(left: 10),
            ),
            TebText(
              '${_schedule.activity.name} ${_schedule.mandatory ? '(Obrigatório)' : ''}',
              textSize: 18,
              padding: EdgeInsets.only(left: 10),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(FontAwesomeIcons.solidSquareCheck, color: Theme.of(context).primaryColor),
            TebText(
              'Frequência:',
              textSize: 18,
              textWeight: FontWeight.bold,
              padding: EdgeInsets.only(left: 10),
            ),
            TebText(
              Schedule.scheduleFrequencyName(_schedule.scheduleFrequency),
              textSize: 18,
              padding: EdgeInsets.only(left: 10),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(FontAwesomeIcons.solidSquareCheck, color: Theme.of(context).primaryColor),
            TebText(
              'Resultado:',
              textSize: 18,
              textWeight: FontWeight.bold,
              padding: EdgeInsets.only(left: 10),
            ),
            TebText(
              _schedule.positiveConsequence ? 'Premiação ao concluir' : 'Sem premiação',
              textSize: 18,
              padding: EdgeInsets.only(left: 10),
            ),
          ],
        ),
      ],
    );
  }

  // Buttons

  Widget _navitagionButtons() {
    return Row(
      mainAxisAlignment: _index == 0 ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
      children: [
        if (_index > 0)
          TebButton(
            onPressed: () => setState(() => _index--),
            size: const Size(120, 50),
            child: TebText('Anterior', textSize: 16, textColor: Theme.of(context).canvasColor),
          ),
        if (_index < 3)
          TebButton(
            onPressed: () => setState(() => _index++),
            size: const Size(120, 50),
            child: TebText('Próxima', textSize: 16, textColor: Theme.of(context).canvasColor),
          ),
        if (_index == 3)
          TebButton(
            onPressed: () => _submit(),
            size: const Size(120, 50),
            enabled: _schedule.activityId.isNotEmpty && _schedule.childUserId.isNotEmpty,
            child: TebText('Concluir', textSize: 16, textColor: Theme.of(context).canvasColor),
          ),
      ],
    );
  }

  // Tabs

  List<Widget> _childTab() {
    return [
      ChildWidget(
        family: _family,
        childUser: _childUser,
        childImageRadius: 25,
        showAsList: true,
        onSelectChild: (childUser) {
          if (childUser.id.isNotEmpty) {
            setState(() {
              _schedule.childUserId = childUser.id;
              _childUser = childUser;
            });
          }
        },
      ),
    ];
  }

  List<Widget> _activityTab() {
    return [
      TebInfoText(text: 'Esta atividade é obrigatória?'),
      TebCheckBox(
        context: context,
        value: _schedule.mandatory,
        title: 'Atividade Obrigatória',
        onChanged: (value) => setState(() => _schedule.mandatory = value ?? false),
      ),
      SizedBox(height: 10),
      TebInfoText(text: 'Qual atividade a criança deverá realizar?'),
      ActivityWidget(
        family: _family,
        activity: _schedule.activity,
        showAsList: true,
        onSelectActivity: (activity) {
          setState(() {
            _schedule.activity = activity;
            _schedule.activityId = activity.id;
          });
        },
      ),
    ];
  }

  List<Widget> _frequencyTab() {
    return [
      TebInfoText(text: 'Qual será a frequência da atividade?'),
      ScheduleFrequencyWidget(
        scheduleFrequency: _schedule.scheduleFrequency,
        showAsList: true,
        onSelectActivity: (scheduleType) {
          setState(() {
            _schedule.scheduleFrequency = scheduleType;
          });
        },
      ),

      const SizedBox(height: 10),
      if (_schedule.scheduleFrequency == ScheduleFrequency.daily)
        TebInfoText(text: 'Esta atividade deverá ser executada diariamente, durante todo o mês'),
      if (_schedule.scheduleFrequency == ScheduleFrequency.weekDay) _weekDaySelectionWidget(),
      if (_schedule.scheduleFrequency == ScheduleFrequency.selectedDates) _selectedDatesWidget(),
    ];
  }

  List<Widget> _consequenceTab() {
    return [
      TebInfoText(
        text: 'Se a tarefa for concluída, como combinado. Será adicionado um valor a mesada?',
      ),
      const SizedBox(height: 10),
      TebCheckBox(
        context: context,
        value: _schedule.positiveConsequence,
        title: 'Sim',
        onChanged: (value) => setState(() {
          if ((value ?? false) == true) _schedule.positiveConsequence = true;
        }),
      ),
      const SizedBox(height: 10),
      TebCheckBox(
        context: context,
        value: !_schedule.positiveConsequence,
        title: 'Não',
        onChanged: (value) => setState(() {
          if ((value ?? false) == true) _schedule.positiveConsequence = false;
        }),
      ),
      if (_schedule.positiveConsequence)
        TebTextEdit(
          context: context,
          controller: _schedule.consequenceValueTextController,
          labelText: 'Valor',
          hintText: 'Informe o valor',
          keyboardType: TextInputType.numberWithOptions(),
          onSave: (value) => _schedule.consequenceValue = double.tryParse(value ?? '') ?? 0,
          validator: (price) {
            if (!_schedule.positiveConsequence) return null;
            if ((double.tryParse(price ?? '') ?? 0) == 0) {
              return 'Informe o valor';
            }
            return null;
          },
        ),
    ];
  }

  // Frequency options

  Widget _selectedDatesWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TebInfoText(text: 'Adicione as datas desejadas'),
        const SizedBox(height: 10),

        TebDateTimeSelector(
          ctx: context,
          displayName: 'Adicionar novas datas',
          buttonText: 'Selecionar',
          initialValue: DateTime.now(),
          textSize: 20,
          onSelected: (date) {
            if (date != null) {
              setState(() => _schedule.selectedDates.add(TebUtil.getOnlyDate(date)));
            }
          },
        ),

        Wrap(
          runSpacing: 5,
          spacing: 5,
          children: _schedule.selectedDates.map((date) {
            return TebButton(
              label: TebUtil.dateTimeFormat(date: date),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              onPressed: () => setState(() => _schedule.selectedDates.remove(date)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _weekDaySelectionWidget() {
    return Column(
      children: [
        TebInfoText(text: 'Selecione os dias da semana que a atividade deverá ser executada'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 20,
          runSpacing: 15,
          children: List<Widget>.generate(Schedule.daysOfWeek.length, (index) {
            return ChoiceChip(
              label: TebText(
                Schedule.daysOfWeek[index],
                textSize: 18,
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              ),
              selectedColor: Theme.of(context).colorScheme.tertiary,
              selected: _schedule.weekSelectedDay.contains(Schedule.daysOfWeek[index]),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _schedule.weekSelectedDay.add(Schedule.daysOfWeek[index]);
                  } else {
                    _schedule.weekSelectedDay.remove(Schedule.daysOfWeek[index]);
                  }
                });
              },
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _family = arguments['family'] ?? Family();
      _schedule = arguments['schedule'] ?? Schedule();

      if (_schedule.childUserId.isEmpty) {
        UserLocalDataController().getLocalSelectedChild.then((childUser) {
          setState(() {
            _childUser = childUser;
            _schedule.childUserId = childUser.id;
          });
        });
      } else {
        UserController().getUserById(id: _schedule.childUserId).then((childUser) {
          setState(() {
            _childUser = childUser;
            _schedule.childUserId = childUser.id;
          });
        });
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
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_schedule.id.isEmpty)
                  TitleTextWidget(text: 'Programar uma atividade para seu filho'),
                if (_schedule.id.isNotEmpty)
                  TitleTextWidget(text: 'Alterar uma atividade programada'),
                const SizedBox(height: 10),
                _scheduleSummaryWidget(),
                const SizedBox(height: 10),
                _navitagionButtons(),
                const SizedBox(height: 10),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(_index > 0 ? 1.0 : -1.0, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(_index),

                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_index == 0) ..._childTab(),
                        if (_index == 1) ..._activityTab(),
                        if (_index == 2) ..._frequencyTab(),
                        if (_index == 3) ..._consequenceTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
