import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_package/control_widgets/teb_info_text.dart';

class ModalScreenWidget extends StatefulWidget {
  final String title;
  final String infoText;
  final Widget body;
  final double heightPercentage;
  const ModalScreenWidget({
    super.key,
    required this.title,
    required this.infoText,
    required this.body,
    this.heightPercentage = 0.8,
  });

  @override
  State<ModalScreenWidget> createState() => _ModalScreenWidgetState();
}

class _ModalScreenWidgetState extends State<ModalScreenWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.10,
      ),
      child: SizedBox(
        width: size.width * 0.9,
        height: size.height * widget.heightPercentage,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: TitleTextWidget(text: widget.title)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(FontAwesomeIcons.xmark),
                  ),
                ],
              ),
              if (widget.infoText.isNotEmpty) const SizedBox(height: 20),
              if (widget.infoText.isNotEmpty) TebInfoText(text: widget.infoText),
              widget.body,
            ],
          ),
        ),
      ),
    );
  }
}
