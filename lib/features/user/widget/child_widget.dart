import 'package:flutter/material.dart';
import 'package:teb_mesada/core/widget/modal_screen_widget.dart';
import 'package:teb_mesada/core/widget/title_text_widget.dart';
import 'package:teb_mesada/features/family/family.dart';
import 'package:teb_mesada/features/user/model/user.dart';
import 'package:teb_mesada/features/user/user_controller.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class ChildWidget extends StatelessWidget {
  final Family family;
  final User childUser;
  final double childImageRadius;
  final bool showAsList;
  final Function(User childUser)? onSelectChild;

  const ChildWidget({
    super.key,
    required this.family,
    required this.childUser,
    this.onSelectChild,
    this.childImageRadius = 25,
    this.showAsList = false,
  });

  Widget _childList() {
    return FutureBuilder(
      future: UserController().getChildList(familyId: family.id),
      builder: (context, snapshot) {
        List<User> childList = [];

        if (!snapshot.hasError && snapshot.hasData) {
          childList = snapshot.data!;
        }

        if (childList.isEmpty) {
          return TebText('Nenhuma criança foi encontrada');
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: childList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (onSelectChild != null) onSelectChild!(childList[index]);
                  if (!showAsList) Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: childList[index].id == childUser.id
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: childImageRadius,
                          backgroundColor: Theme.of(context).canvasColor,
                          backgroundImage: NetworkImage(childList[index].imageUrl),
                        ),
                        const SizedBox(width: 10),
                        TebText(
                          childList[index].firstName,
                          textSize: 16,
                          textWeight: childList[index].id == childUser.id
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  void _onOpenSelectScreen(BuildContext context) {
    if (onSelectChild == null) return;
    showDialog(
      context: context,
      builder: (context) {
        return ModalScreenWidget(
          title: 'Selecione uma criança',
          infoText: 'Toque na foto da criança para selecioná-la',
          body: _childList(),
        );
      },
    );
    if (onSelectChild != null) onSelectChild!(User());
  }

  @override
  Widget build(BuildContext context) {
    if (showAsList) {
      return _childList();
    } else {
      return GestureDetector(
        onTap: () => _onOpenSelectScreen(context),
        child: Row(
          children: [
            CircleAvatar(
              radius: childImageRadius,
              backgroundColor: Theme.of(context).canvasColor,
              backgroundImage: NetworkImage(childUser.imageUrl),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TitleTextWidget(
                text: childUser.id.isEmpty
                    ? 'Você ainda não selecionou uma criança'
                    : childUser.firstName,
                textSize: 20,
              ),
            ),
          ],
        ),
      );
    }
  }
}
