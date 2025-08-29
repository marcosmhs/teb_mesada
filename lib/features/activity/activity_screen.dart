import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/routes.dart';
import 'package:teb_mesada/core/widget/screen_structure_widget.dart';
import 'package:teb_mesada/features/activity/activity.dart';
import 'package:teb_mesada/features/activity/activity_controller.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  var _family = Family();
  var _initializing = true;

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _family = arguments['family'] ?? Family();
      _initializing = false;
    }
    return ScreenStructureWidget(
      title: 'Atividades',
      newItemOnPressed: () {
        Navigator.of(context).pushNamed(Routes.activityForm, arguments: {'family': _family});
      },
      body: FutureBuilder(
        future: ActivityController(family: _family).getActivityList,
        builder: (context, snapshot) {
          List<Activity> acitivyList = [];

          if (!snapshot.hasError && snapshot.hasData) {
            acitivyList = snapshot.data!;
          }

          if (acitivyList.isEmpty) {
            return TebText('Nenhuma atividade encontrada');
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: acitivyList.length,
              itemBuilder: (context, index) {
                return ScreenStructureWidget.listItem(
                  title: acitivyList[index].name,
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(Routes.activityForm, arguments: {'family': _family, 'activity': acitivyList[index]});
                    },
                    icon: Icon(FontAwesomeIcons.pen),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
