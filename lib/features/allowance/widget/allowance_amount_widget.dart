import 'package:flutter/material.dart';
import 'package:teb_mesada/features/allowance/allowance_controller.dart';
import 'package:teb_mesada/features/allowance/model/allowance.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/util/teb_util.dart';

class AllowanceAmountWidget extends StatelessWidget {
  final User childUser;
  final int year;
  final int month;
  const AllowanceAmountWidget({
    super.key,
    required this.childUser,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AllowanceController(
        childUser: childUser,
      ).getAllowanceByMonth(year: year, month: month),
      builder: (context, snapshot) {
        var error = false;
        var allowance = Allowance();

        error = snapshot.hasError;

        if (!snapshot.hasError && snapshot.hasData) {
          allowance = snapshot.data!;
        }

        return Card(
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: Column(
              children: [
                TebText(
                  'Sua Mesada',
                  textSize: 22,
                  textWeight: FontWeight.bold,
                  textColor: Theme.of(context).primaryColor,
                ),
                TebText(
                  TebUtil.formatedCurrencyValue(value: allowance.totalValue),
                  textSize: 50,
                  textWeight: FontWeight.bold,
                  textColor: Theme.of(context).primaryColor,
                ),
                TebText(
                  error ? 'Houve um erro para obter o saldo' : 'Seu valor atual',
                  textSize: 16,
                  textWeight: FontWeight.bold,
                  textColor: error ? Theme.of(context).colorScheme.error : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
