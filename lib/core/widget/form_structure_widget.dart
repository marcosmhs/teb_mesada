// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/messaging/teb_dialog.dart';
import 'package:teb_package/screen_widgets/teb_scaffold.dart';

enum ActionType { create, edit }

class FormStructureWidget extends StatefulWidget {
  final String title;
  final ActionType actionType;
  final String newSubtitleText;
  final String editSubtitleText;
  final Widget formBody;
  final void Function()? onSubmit;
  final String submitText;
  final String deleteMessage;
  final void Function()? onDelete;
  const FormStructureWidget({
    super.key,
    this.actionType = ActionType.create,
    this.title = '',
    required this.newSubtitleText,
    required this.editSubtitleText,
    required this.formBody,
    this.onSubmit,
    this.submitText = 'Confirmar',
    this.deleteMessage = '',
    this.onDelete,
  });

  @override
  State<FormStructureWidget> createState() => _FormStructureWidgetState();
}

class _FormStructureWidgetState extends State<FormStructureWidget> {
  @override
  Widget build(BuildContext context) {
    return TebScaffold(
      appBar: AppBar(
        title: widget.title.isEmpty ? null : TebText(widget.title, textColor: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).canvasColor,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        elevation: 0,
      ),
      widthPercentage: 0.95,
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (widget.actionType == ActionType.create && widget.newSubtitleText.isNotEmpty)
                TitleTextWidget(text: widget.newSubtitleText),
              if (widget.actionType == ActionType.edit && widget.editSubtitleText.isNotEmpty)
                TitleTextWidget(text: widget.editSubtitleText),
              widget.formBody,
              if (widget.onSubmit != null)
                TebButton(
                  onPressed: widget.onSubmit,
                  size: Size.fromHeight(50),
                  padding: EdgeInsets.all(20),
                  child: TebText(widget.submitText, textSize: 20),
                ),
              if (widget.onSubmit != null)
                TebButton(
                  buttonType: TebButtonType.outlinedButton,
                  size: Size.fromHeight(50),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: TebText('Cancelar', textSize: 16),
                ),
              if (widget.actionType != ActionType.create && widget.onDelete != null)
                GestureDetector(
                  onTap: () {
                    TebDialog(context: context).confirmationDialog(message: widget.deleteMessage).then((value) {
                      if ((value ?? false)) widget.onDelete;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.trashCan, color: Theme.of(context).colorScheme.error),
                          TebText(
                            'Excluir',
                            textSize: 16,
                            textColor: Theme.of(context).colorScheme.error,
                            padding: const EdgeInsets.only(left: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
