import 'package:flutter/material.dart';
import 'package:teb_mesada/core/widget/about_widget.dart';
import 'package:teb_mesada/core/widget/main_screen_structure_widget.dart';
import 'package:teb_mesada/core/widget/year_month_selector_widget.dart';
import 'package:teb_mesada/features/allowance/widget/allowance_amount_widget.dart';
import 'package:teb_mesada/features/allowance/widget/allowance_entrance_form_widget.dart';
import 'package:teb_mesada/features/allowance/widget/allowance_entrance_list_widget.dart';
import 'package:teb_mesada/features/family/family_controller.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/schedule/widget/schedule_calendar_widget.dart';
import 'package:teb_mesada/core/widget/feedback_animation_widget.dart';
import 'package:teb_mesada/features/schedule/widget/schedule_item_widget.dart';
import 'package:teb_mesada/features/schedule/widget/schedule_list_widget.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_mesada/core/local_data_controller.dart';
import 'package:teb_mesada/features/user/widget/child_widget.dart';
import 'package:teb_package/teb_package.dart';

class MainScreen extends StatefulWidget {
  final User? user;
  final Family? family;
  const MainScreen({super.key, this.user, this.family});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  var _initializing = true;
  var _user = User();
  var _family = Family();
  var _childUser = User(userType: UserType.child);
  var _selectedDate = DateTime.now();

  final GlobalKey<FeedbackAnimationWidgetState> _feedbackAnimationKey = GlobalKey();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Widget _tabActivities() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            child: Builder(
              builder: (context) {
                if (_family.id.isEmpty || _childUser.id.isEmpty) {
                  return TebText('Criar família, selecionar criança');
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // today activities
                      ScheduleListWidget(
                        family: _family,
                        user: _user,
                        childUser: _childUser,
                        title: '🌟  Hoje (${TebUtil.dateTimeFormat(date: DateTime.now())})',
                        date: DateTime.now(),
                        scheduleCardType: ScheduleCardType.cardModel2,
                        showScheduleItemOptions: true,
                        feedbackAnimationKey: _feedbackAnimationKey,
                      ),
                      // tomorrow activities
                      const SizedBox(height: 20),
                      ScheduleListWidget(
                        family: _family,
                        user: _user,
                        childUser: _childUser,
                        title:
                            '🚀  Amanhã (${TebUtil.dateTimeFormat(date: DateTime.now().add(Duration(days: 1)))})...',
                        date: DateTime.now().add(Duration(days: 1)),
                        scheduleCardType: ScheduleCardType.cardModel2,
                      ),

                      //calendar
                      const SizedBox(height: 20),
                      ScheduleCalendarWidget(family: _family, user: _user, childUser: _childUser),
                      AboutWidget(),
                    ],
                  );
                }
              },
            ),
          ),
        ),
        FeedbackAnimationWidget(key: _feedbackAnimationKey),
      ],
    );
  }

  Widget _tabAllowance() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Builder(
          builder: (context) {
            if (_family.id.isEmpty || _childUser.id.isEmpty) {
              return TebText('Criar família, selecionar criança');
            } else {
              return Column(
                children: [
                  YearMonthSelectorWidget(
                    onChange: (selectedDate) => setState(() => _selectedDate = selectedDate),
                  ),

                  const SizedBox(height: 20),
                  AllowanceAmountWidget(
                    childUser: _childUser,
                    year: _selectedDate.year,
                    month: _selectedDate.month,
                  ),

                  if (_user.userType == UserType.parent) const SizedBox(height: 20),
                  if (_user.userType == UserType.parent)
                    AllowanceEntranceFormWidget(
                      family: _family,
                      childUser: _childUser,
                      date: _selectedDate,
                      onSave: () => setState(() {}),
                    ),

                  const SizedBox(height: 20),
                  AllowanceEntranceListWidet(
                    user: _user,
                    childUser: _childUser,
                    date: _selectedDate,
                    onRemove: () => setState(() {}),
                  ),
                  AboutWidget(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void _loadData() {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

    _user = arguments['user'] ?? User();
    if (widget.user != null && widget.user!.id.isNotEmpty) _user = widget.user!;

    _family = arguments['family'] ?? Family();
    if (widget.family != null && widget.family!.id.isNotEmpty) _family = widget.family!;

    if (_user.familyId.isNotEmpty && _family.id.isEmpty) {
      FamilyController(user: _user).getFamilyById(id: _user.familyId).then((family) {
        setState(() => _family = family);
      });
    }

    if (_user.userType == UserType.child) {
      _childUser = _user;
    } else {
      LocalDataController().getLocalSelectedChild.then((childUser) {
        setState(() => _childUser = childUser);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      _loadData();

      _initializing = false;
    }

    return MainScreenStructureWidget(
      user: _user,
      family: _family,
      body: Column(
        children: [
          const SizedBox(height: 10),
          if (_family.id.isNotEmpty)
            ChildWidget(
              family: _family,
              childUser: _childUser,
              childImageRadius: 30,
              onSelectChild: _user.userType == UserType.child
                  ? null
                  : (childUser) {
                      if (childUser.id.isNotEmpty) {
                        LocalDataController().saveSelectedChild(childUser: childUser);
                        setState(() => _childUser = childUser);
                      }
                    },
            ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 1),
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.secondary.withAlpha(10),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TebButton(
                    buttonType: TebButtonType.outlinedButton,
                    onPressed: () => setState(() => _tabController.index = 0),
                    child: TebText(
                      '📋 Atividades',
                      textSize: _tabController.index == 0 ? 18 : 20,
                      textWeight: _tabController.index == 0 ? FontWeight.bold : FontWeight.normal,
                      textColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  TebButton(
                    buttonType: TebButtonType.outlinedButton,
                    backgroundColor: _tabController.index == 0
                        ? null
                        : Theme.of(context).colorScheme.secondary.withAlpha(50),
                    onPressed: () => setState(() => _tabController.index = 1),
                    child: TebText(
                      '💰 Dinheiro',
                      textSize: _tabController.index == 1 ? 18 : 20,
                      textWeight: _tabController.index == 1 ? FontWeight.bold : FontWeight.normal,
                      textColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_tabActivities(), _tabAllowance()],
            ),
          ),
        ],
      ),
    );
  }
}
