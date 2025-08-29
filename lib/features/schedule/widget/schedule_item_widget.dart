// ignore_for_file: use_build_context_synchronously

import 'package:teb_mesada/core/widget/feedback_animation_widget.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/schedule/model/schedule.dart';
import 'package:teb_mesada/features/schedule/schedule_controller.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_util.dart';

enum ScheduleCardType { list, cardModel2 }

class ScheduleItemWidget extends StatefulWidget {
  final ScheduleCardType scheduleCardType;
  final Family family;
  final Schedule schedule;
  final bool showOption;
  final DateTime? date;
  final User user;
  final void Function(Schedule? schedule)? onTap;
  final GlobalKey<FeedbackAnimationWidgetState>? feedbackAnimationKey;

  const ScheduleItemWidget({
    super.key,
    required this.family,
    required this.schedule,
    this.scheduleCardType = ScheduleCardType.cardModel2,
    this.onTap,
    this.showOption = false,
    this.date,
    required this.user,
    this.feedbackAnimationKey,
  });

  @override
  State<ScheduleItemWidget> createState() => _ScheduleItemWidgetState();
}

class _ScheduleItemWidgetState extends State<ScheduleItemWidget> {
  void _registerAppointment({required schedule, required bool done, bool closeAfterSaving = true}) {
    if (widget.date == null) {
      TebMessage.error(context, message: 'A data da atividade está em branco!');
      return;
    }

    ScheduleController(
      family: widget.family,
    ).registerAppointment(schedule: schedule, done: done, date: widget.date!).then((tebReturn) {
      if (tebReturn.returnType == TebReturnType.error) {
        TebMessage.error(context, message: 'Ops, parece que houve um erro: ${tebReturn.message}');
      } else {
        if (widget.user.userType == UserType.parent) {
          TebMessage.sucess(context, message: 'Atividade registrada.');
        }
        if (widget.feedbackAnimationKey != null) {
          if (done) {
            widget.feedbackAnimationKey!.currentState?.execute(
              annimationType: AnnimationType.starts,
              particleCount: 200,
              duration: 1.5,
              explosionArea: 500,
            );
          } else {
            if (widget.feedbackAnimationKey != null) {
              widget.feedbackAnimationKey!.currentState?.execute(
                annimationType: AnnimationType.sadFace,
                particleCount: 20,
                duration: 4.5,
                explosionArea: 20,
              );
            }
          }
        }
        setState(() {});
      }
      if (closeAfterSaving) Navigator.of(context).pop();
    });
  }

  Widget _scheduleConsequence({required Schedule schedule, bool done = false}) {
    // Acessa as propriedades do widget usando `widget.`
    return TebText(
      schedule.positiveConsequence ? 'Recebe RS ${schedule.consequenceValue} ao concluir' : '',
      textColor: done ? Theme.of(context).colorScheme.primary : null,
      textSize: 16,
    );
  }

  Widget _scheduleCardWidgetModel2({required Schedule schedule}) {
    var done = schedule.hasAppointment(widget.date ?? DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: done ? Theme.of(context).primaryColor.withAlpha(40) : null,
        border: Border.all(color: done ? Theme.of(context).primaryColor : Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TebText(
                  schedule.activity.name,
                  textSize: 20,
                  textWeight: FontWeight.bold,
                  textColor: done ? Theme.of(context).primaryColor : null,
                  strikethrough: done,
                ),
                if (schedule.consequenceValue != 0)
                  _scheduleConsequence(schedule: schedule, done: done),
              ],
            ),
          ),
          if (widget.showOption)
            TebButton(
              onPressed: () => _registerAppointment(
                schedule: widget.schedule,
                done: !done,
                closeAfterSaving: false,
              ),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              backgroundColor: done
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.tertiary,
              icon: Icon(done ? FontAwesomeIcons.solidSquareCheck : FontAwesomeIcons.square),
              child: TebText(
                done ? 'Feito!' : 'Fazer',
                textWeight: FontWeight.bold,
                strikethrough: done,
              ),
            ),
        ],
      ),
    );
  }

  Widget _scheduleListItemWidget({required Schedule schedule}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 5)),
      ),
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TebText(schedule.activity.name, textSize: 20, textWeight: FontWeight.bold),
                if (schedule.mandatory)
                  TebText(
                    'Obrigatório',
                    textSize: 16,
                    textColor: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
          if (schedule.positiveConsequence)
            TebText(
              '+${TebUtil.formatedCurrencyValue(value: schedule.consequenceValue)}',
              textWeight: FontWeight.bold,
              textSize: 16,
              textColor: Theme.of(context).colorScheme.tertiary,
            ),
          IconButton(
            onPressed: () => widget.onTap == null ? null : widget.onTap!(schedule),
            icon: Icon(FontAwesomeIcons.pen),
          ),
          SizedBox(width: 5),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) widget.onTap!(widget.schedule);
      },
      child: widget.scheduleCardType == ScheduleCardType.cardModel2
          ? _scheduleCardWidgetModel2(schedule: widget.schedule)
          : _scheduleListItemWidget(schedule: widget.schedule),
    );
  }
}
