import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/control_widgets/teb_text_edit.dart';
import 'package:teb_package/screen_widgets/teb_scaffold.dart';

class ScreenStructureWidget extends StatefulWidget {
  final String title;
  final bool isLoading;
  final TextEditingController? searchTextController;
  final String searchLabelText;
  final List<Object>? listedItens;
  final String empytListText;
  final Widget body;
  final Function(String?)? onFieldSubmitted;
  final Function()? newItemOnPressed;
  final bool showNewItemButton;

  const ScreenStructureWidget({
    super.key,
    required this.title,
    this.searchTextController,
    this.searchLabelText = '',
    this.listedItens,
    this.empytListText = '',
    this.isLoading = false,
    required this.body,
    this.newItemOnPressed,
    this.onFieldSubmitted,
    this.showNewItemButton = true,
  });

  @override
  State<ScreenStructureWidget> createState() => _ScreenStructureWidgetState();

  static Widget listItem({Widget? leadingIcon, required String title, String subtitle = '', Widget? trailing}) {
    return ListTile(
      leading: leadingIcon,
      title: TebText(title, textSize: 16),
      subtitle: subtitle.isEmpty ? null : TebText(subtitle, textSize: 14),
      trailing: trailing,
      contentPadding: EdgeInsets.symmetric(vertical: 5),
    );
  }
}

class _ScreenStructureWidgetState extends State<ScreenStructureWidget> {
  @override
  @override
  Widget build(BuildContext context) {
    return TebScaffold(
      widthPercentage: 0.95,
      appBar: AppBar(
        title: TebText(widget.title, textColor: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).canvasColor,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        elevation: 0,
      ),
      floatingActionButton: !widget.showNewItemButton
          ? null
          : FloatingActionButton(onPressed: widget.newItemOnPressed, child: Icon(FontAwesomeIcons.plus)),
      body: Column(
        children: [
          if (widget.searchTextController != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TebTextEdit(
                controller: widget.searchTextController,
                labelText: widget.searchLabelText,
                prefixIcon: FontAwesomeIcons.magnifyingGlass,
                onFieldSubmitted: widget.onFieldSubmitted,
              ),
            ),
          SingleChildScrollView(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : widget.listedItens != null && widget.listedItens!.isEmpty
                ? Center(child: TebText(widget.empytListText))
                : widget.body,
          ),
        ],
      ),
    );
  }
}
