import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/widget/main_drawer_widget.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/screen_widgets/teb_scaffold.dart';

class MainScreenStructureWidget extends StatefulWidget {
  final Widget body;
  final int cartItensCount;
  final int notificationsCount;
  final User user;
  final Family family;
  const MainScreenStructureWidget({
    super.key,
    required this.user,
    required this.family,
    required this.body,
    this.cartItensCount = 0,
    this.notificationsCount = 0,
  });

  @override
  State<MainScreenStructureWidget> createState() => _MainScreenStructureWidgetState();
}

class _MainScreenStructureWidgetState extends State<MainScreenStructureWidget> {
  @override
  Widget build(BuildContext context) {
    return TebScaffold(
      endDrawer: MainDrawerWidget(user: widget.user, family: widget.family),
      widthPercentage: 0.95,
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: Icon(FontAwesomeIcons.bars, color: Theme.of(context).primaryIconTheme.color),
              );
            },
          ),
        ], //remove drawer button
        backgroundColor: Theme.of(context).primaryColor,
        title: Align(
          alignment: Alignment.centerLeft,
          child: TebText(
            'Família ${widget.family.name}',
            textSize: 20,
            textWeight: FontWeight.bold,
          ),
        ),
      ),
      body: widget.body,
    );
  }
}
