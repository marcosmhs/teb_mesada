import 'package:flutter/material.dart';
import 'package:teb_mesada/core/routes.dart';
import 'package:teb_mesada/core/widget/screen_structure_widget.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/schedule/model/schedule.dart';
import 'package:teb_mesada/features/schedule/schedule_controller.dart';
import 'package:teb_mesada/features/schedule/widget/schedule_item_widget.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_package/control_widgets/teb_info_text.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/teb_package.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
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
      title: 'Programação das atividades',
      newItemOnPressed: () {
        Navigator.of(context).pushNamed(Routes.scheduleForm, arguments: {'family': _family});
      },
      body: FutureBuilder(
        future: ScheduleController(family: _family).getScheduleList(),
        builder: (context, snapshot) {
          List<Schedule> scheduleList = [];

          if (snapshot.hasError) {
            return Center(child: TebText(snapshot.error.toString()));
          }

          if (!snapshot.hasError && snapshot.hasData) {
            scheduleList = snapshot.data!;
          }

          if (scheduleList.isEmpty) {
            return TebText('Nenhuma atividade programada até agora');
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              children: [
                TebInfoText(text: 'Clique em uma das atividades agendadas para alterá-la'),
                ...scheduleList.map((schedule) {
                  return ScheduleItemWidget(
                    family: _family,
                    user: User(),
                    schedule: schedule,
                    scheduleCardType: ScheduleCardType.list,
                    onTap: (s) {
                      Navigator.of(context).pushNamed(
                        Routes.scheduleForm,
                        arguments: {'family': _family, 'schedule': schedule},
                      );
                    },
                  );
                }),
              ],
            );
          }
        },
      ),
    );
  }
}
