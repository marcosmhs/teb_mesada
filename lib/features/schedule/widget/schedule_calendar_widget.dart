import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/widget/modal_screen_widget.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_mesada/core/widget/year_month_selector_widget.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/schedule/model/schedule.dart';
import 'package:teb_mesada/features/schedule/schedule_controller.dart';
import 'package:teb_mesada/features/schedule/widget/schedule_item_widget.dart';
import 'package:teb_mesada/features/schedule/widget/schedule_list_widget.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/util/teb_util.dart';

class ScheduleCalendarWidget extends StatefulWidget {
  final Family family;
  final User user;
  final User childUser;
  const ScheduleCalendarWidget({
    super.key,
    required this.family,
    required this.childUser,
    required this.user,
  });

  @override
  State<ScheduleCalendarWidget> createState() => _ScheduleCalendarWidgetState();
}

class _ScheduleCalendarWidgetState extends State<ScheduleCalendarWidget> {
  var startDate = DateTime.now();

  Widget _calendar({required List<Schedule> scheduleList}) {
    // Calcula o primeiro e o último dia do mês da data inicial
    var firstDay = DateTime(startDate.year, startDate.month, 1);
    var lastDay = DateTime(startDate.year, startDate.month + 1, 0);

    // Descobre o índice do primeiro dia da semana (0 = domingo, 1 = segunda, ...)
    final firstWeekday = firstDay.weekday % 7; // Flutter: 1=segunda, 7=domingo. %7 faz domingo=0

    // Gera a lista de dias do mês
    final days = List<DateTime>.generate(
      lastDay.day,
      (i) => DateTime(startDate.year, startDate.month, i + 1),
    );

    // Adiciona espaços vazios antes do primeiro dia do mês
    var calendarDays = List<DateTime?>.filled(firstWeekday, null) + days;

    // Nomes dos dias da semana (ajustado para começar em domingo)
    final weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Linha com nomes dos dias da semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays
                .map(
                  (name) =>
                      Expanded(child: TebText(name, textWeight: FontWeight.bold, textSize: 20)),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          // Calendário em grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 0.5,
            ),
            itemCount: calendarDays.length,
            itemBuilder: (context, index) {
              final date = calendarDays[index];
              if (date == null) return Container();

              List<Schedule> scheduleListByDay = [];

              scheduleListByDay = scheduleList.where((s) => s.hasScheduleOnDate(date)).toList();

              var isToday = date.day == DateTime.now().day;

              var allDone = scheduleListByDay.where((s) => !s.hasAppointment(date)).isEmpty;

              //calendar date
              return GestureDetector(
                onTap: () => _openScheduleDateList(date: date),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isToday
                        ? Colors.deepPurple
                        : allDone
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.secondary.withAlpha(20),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      TebText(
                        '${date.day}',
                        textSize: 20,
                        textWeight: FontWeight.w900,
                        textColor: isToday
                            ? Theme.of(context).canvasColor
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      Icon(
                        allDone ? FontAwesomeIcons.solidSquareCheck : FontAwesomeIcons.square,
                        size: 22,
                        color: allDone
                            ? Theme.of(context).canvasColor
                            : isToday
                            ? Theme.of(context).canvasColor.withAlpha(200)
                            : Theme.of(context).colorScheme.secondary.withAlpha(150),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openScheduleDateList({required DateTime date}) {
    showDialog(
      context: context,
      builder: (context) {
        return ModalScreenWidget(
          title: 'Atividades do dia ${TebUtil.dateTimeFormat(date: date)}',
          infoText: '',
          body: ScheduleListWidget(
            family: widget.family,
            user: widget.user,
            childUser: widget.childUser,
            date: date,
            scheduleCardType: ScheduleCardType.cardModel2,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleTextWidget(text: '📅  Resumo do mês'),
            const SizedBox(height: 5),
            YearMonthSelectorWidget(onChange: (date) => startDate = date),
            FutureBuilder(
              future: ScheduleController(
                family: widget.family,
              ).getScheduleList(childUser: widget.childUser),
              builder: (context, snapshot) {
                List<Schedule> scheduleList = [];

                if (snapshot.hasError) {
                  return Center(child: TebText(snapshot.error.toString()));
                }

                if (!snapshot.hasError && snapshot.hasData) {
                  scheduleList = snapshot.data!;
                }

                return _calendar(scheduleList: scheduleList);
              },
            ),
          ],
        ),
      ),
    );
  }
}
