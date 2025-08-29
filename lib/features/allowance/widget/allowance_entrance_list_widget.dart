// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_mesada/features/allowance/allowance_controller.dart';
import 'package:teb_mesada/features/allowance/model/allowance_entrance.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/messaging/teb_dialog.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_util.dart';

class AllowanceEntranceListWidet extends StatefulWidget {
  final User childUser;
  final User user;
  final DateTime date;
  final void Function()? onRemove;

  const AllowanceEntranceListWidet({
    super.key,
    required this.user,
    required this.childUser,
    required this.date,
    this.onRemove,
  });

  @override
  State<AllowanceEntranceListWidet> createState() => _AllowanceEntranceListWidetState();
}

class _AllowanceEntranceListWidetState extends State<AllowanceEntranceListWidet> {
  void _removeAllowanceEntrange({required AllowanceEntrance allowanceEntrance}) {
    TebDialog(context: context).confirmationDialog(message: 'Remover valor do histórico?').then((
      value,
    ) {
      if ((value ?? false)) {
        AllowanceController(
          childUser: widget.childUser,
        ).removeAllowanceValue(allowanceEntrance: allowanceEntrance).then((tebReturn) {
          if (tebReturn.returnType == TebReturnType.sucess) {
            if (widget.onRemove != null) widget.onRemove!();
            TebMessage.sucess(context, message: 'Valor removido!');
          } else {
            TebMessage.error(context, message: tebReturn.message);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleTextWidget(text: '📊  Histórico do mês'),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            width: double.infinity,
            child: FutureBuilder(
              future: AllowanceController(
                childUser: widget.childUser,
              ).getAllowanceEntranceListByMonth(year: widget.date.year, month: widget.date.month),
              builder: (context, snapshot) {
                List<AllowanceEntrance> allowanceEntranceList = [];
                if (snapshot.hasError) {
                  return Center(child: TebText(snapshot.error.toString()));
                }

                if (!snapshot.hasError && snapshot.hasData) {
                  allowanceEntranceList = snapshot.data!;
                }

                allowanceEntranceList.sort((a, b) {
                  int dateComparison = b.dateTime.compareTo(a.dateTime);
                  if (dateComparison != 0) return dateComparison;
                  return a.observation.compareTo(b.observation);
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: allowanceEntranceList.map((allowanceEntrance) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(color: Theme.of(context).primaryColor, width: 5),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TebText(
                                    allowanceEntrance.observation,
                                    textSize: 20,
                                    textWeight: FontWeight.bold,
                                  ),
                                  TebText(
                                    TebUtil.dateTimeFormat(date: allowanceEntrance.dateTime),
                                    textSize: 16,
                                  ),
                                ],
                              ),
                            ),
                            TebText(
                              '${allowanceEntrance.signal}${TebUtil.formatedCurrencyValue(value: allowanceEntrance.value)}',

                              textSize: 20,
                              textColor: allowanceEntrance.signal == '+'
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.error,
                              textWeight: FontWeight.bold,
                            ),

                            if (widget.user.userType == UserType.parent)
                              IconButton(
                                onPressed: () =>
                                    _removeAllowanceEntrange(allowanceEntrance: allowanceEntrance),
                                color: Theme.of(context).colorScheme.error,
                                icon: Icon(FontAwesomeIcons.trashCan),
                              ),
                            SizedBox(width: 5),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
