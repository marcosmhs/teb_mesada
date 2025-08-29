import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class YearMonthSelectorWidget extends StatefulWidget {
  final Function(DateTime dateTime) onChange;
  const YearMonthSelectorWidget({super.key, required this.onChange});

  @override
  State<YearMonthSelectorWidget> createState() => _YearMonthSelectorWidgetState();
}

class _YearMonthSelectorWidgetState extends State<YearMonthSelectorWidget> {
  late int _selectedYear;
  late int _selectedMonth;

  final List<String> _months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
  }

  void _onChange() {
    var dateTime = DateTime(_selectedYear, _selectedMonth, 1);
    widget.onChange(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // year
        IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => setState(() {
            _selectedYear--;
            _onChange();
          }),
        ),
        TebText(_selectedYear.toString(), textSize: 20, textWeight: FontWeight.bold),
        IconButton(
          icon: const Icon(FontAwesomeIcons.arrowRight),
          onPressed: () => setState(() {
            _selectedYear++;
            _onChange();
          }),
        ),
        const SizedBox(width: 20),
        // month
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isExpanded: true,
              value: _selectedMonth,
              items: List.generate(12, (index) {
                final monthNumber = index + 1;
                return DropdownMenuItem<int>(
                  value: monthNumber,
                  child: TebText(_months[index], textSize: 20, textWeight: FontWeight.bold),
                );
              }),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedMonth = newValue;
                    _onChange();
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
