import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_mesada/features/activity/activity.dart';
import 'package:teb_mesada/features/activity/activity_controller.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_package/control_widgets/teb_info_text.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class ActivityWidget extends StatelessWidget {
  final Family family;
  final Activity activity;
  final bool showAsList;
  final Function(Activity activity)? onSelectActivity;

  const ActivityWidget({super.key, required this.family, this.onSelectActivity, required this.activity, this.showAsList = false});

  Widget activityList() {
    return FutureBuilder(
      future: ActivityController(family: family).getActivityList,
      builder: (context, snapshot) {
        List<Activity> activityList = [];

        if (!snapshot.hasError && snapshot.hasData) {
          activityList = snapshot.data!;
        }

        if (activityList.isEmpty) {
          return TebText('Nenhuma atividade foi encontrada');
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: activityList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (onSelectActivity != null) onSelectActivity!(activityList[index]);
                  if (!showAsList) Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ListTile(
                    leading: Icon(
                      activity.id == activityList[index].id ? FontAwesomeIcons.solidSquareCheck : FontAwesomeIcons.square,
                      color: activity.id == activityList[index].id ? Theme.of(context).primaryColor : null,
                    ),
                    title: TebText(
                      activityList[index].name,
                      textSize: 20,
                      textWeight: activity.id == activityList[index].id ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          );
        }
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
          insetPadding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.10),
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
                      Expanded(child: TitleTextWidget(text: 'Selecione uma Atividade')),
                      IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(FontAwesomeIcons.xmark)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  TebInfoText(text: 'Toque/clique na atividade para selecioná-la'),
                  activityList(),
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
      return activityList();
    } else {
      return GestureDetector(
        onTap: () => _onOpenSelectScreen(context),
        child: Row(
          children: [
            Expanded(
              child: TitleTextWidget(
                text: activity.id.isEmpty ? 'Você ainda não selecionou uma atividade' : activity.name,
                textSize: 18,
              ),
            ),
          ],
        ),
      );
    }
  }
}
