import 'package:flutter/material.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/schedule/model/schedule.dart';
import 'package:teb_mesada/features/schedule/schedule_controller.dart';
import 'package:teb_mesada/features/schedule/widget/schedule_item_widget.dart';
import 'package:teb_mesada/core/widget/feedback_animation_widget.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class ScheduleListWidget extends StatefulWidget {
  final Family family;
  final User user;
  final User childUser;
  final String title;

  final bool showScheduleItemOptions;
  final void Function(Schedule? schedule)? onTap;
  final DateTime? date;
  final ScheduleCardType scheduleCardType;
  final GlobalKey<FeedbackAnimationWidgetState>? feedbackAnimationKey;
  const ScheduleListWidget({
    super.key,
    required this.family,
    required this.user,
    required this.childUser,
    this.title = '',
    this.showScheduleItemOptions = false,
    this.date,
    this.scheduleCardType = ScheduleCardType.list,
    this.onTap,
    this.feedbackAnimationKey,
  });

  @override
  State<ScheduleListWidget> createState() => _ScheduleListWidgetState();
}

class _ScheduleListWidgetState extends State<ScheduleListWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != '') TitleTextWidget(text: widget.title),
            FutureBuilder(
              future: ScheduleController(
                family: widget.family,
              ).getScheduleList(childUser: widget.childUser),
              builder: (context, snapshot) {
                List<Schedule> scheduleFullList = [];
                List<Schedule> scheduleFinalList = [];

                var baseDate = widget.date ?? DateTime.now();

                if (snapshot.hasError) {
                  return Center(child: TebText(snapshot.error.toString()));
                }

                if (!snapshot.hasError && snapshot.hasData) {
                  scheduleFullList = snapshot.data!;
                }

                scheduleFinalList.addAll(
                  scheduleFullList.where((s) => s.hasScheduleOnDate(baseDate)),
                );

                scheduleFinalList.sort((a, b) => a.activity.name.compareTo(b.activity.name));

                if (scheduleFinalList.isEmpty) {
                  return TebText("Não há atividades");
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: scheduleFinalList.map((schedule) {
                      return ScheduleItemWidget(
                        family: widget.family,
                        schedule: schedule,
                        user: widget.user,
                        date: widget.date,
                        scheduleCardType: widget.scheduleCardType,
                        showOption: widget.showScheduleItemOptions,
                        onTap: widget.onTap,
                        feedbackAnimationKey: widget.scheduleCardType == ScheduleCardType.cardModel2
                            ? widget.feedbackAnimationKey
                            : null,
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
