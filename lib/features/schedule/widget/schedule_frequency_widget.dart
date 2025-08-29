import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_mesada/features/schedule/model/schedule.dart';
import 'package:teb_package/control_widgets/teb_info_text.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class ScheduleFrequencyWidget extends StatelessWidget {
  final ScheduleFrequency scheduleFrequency;
  final bool showAsList;
  final Function(ScheduleFrequency scheduleType)? onSelectActivity;

  const ScheduleFrequencyWidget({
    super.key,
    this.onSelectActivity,
    required this.scheduleFrequency,
    this.showAsList = false,
  });

  Widget scheduleTypeList() {
    List<ScheduleFrequency> scheduleTypeList = ScheduleFrequency.values;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: scheduleTypeList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (onSelectActivity != null) onSelectActivity!(scheduleTypeList[index]);
            if (!showAsList) Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              leading: Icon(
                scheduleFrequency.name == scheduleTypeList[index].name
                    ? FontAwesomeIcons.solidSquareCheck
                    : FontAwesomeIcons.square,
                color: scheduleFrequency.name == scheduleTypeList[index].name
                    ? Theme.of(context).primaryColor
                    : null,
              ),
              title: TebText(
                Schedule.scheduleFrequencyName(scheduleTypeList[index]),
                textSize: 20,
                textWeight: scheduleFrequency.name == scheduleTypeList[index].name
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onOpenSelectScreen(BuildContext context) {
    if (onSelectActivity == null) return;
    showDialog(
      context: context,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.10,
          ),
          child: SizedBox(
            width: size.width * 0.9,
            height: size.height * 0.8,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: TitleTextWidget(text: 'Selecione a frequência da atividade')),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(FontAwesomeIcons.xmark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TebInfoText(text: 'Toque/clique no nome para selecioná-lo'),
                  scheduleTypeList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showAsList) {
      return scheduleTypeList();
    } else {
      return GestureDetector(
        onTap: () => _onOpenSelectScreen(context),
        child: Row(
          children: [
            Expanded(
              child: TitleTextWidget(
                text: Schedule.scheduleFrequencyName(scheduleFrequency),
                textSize: 18,
              ),
            ),
          ],
        ),
      );
    }
  }
}
