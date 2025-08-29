import 'package:flutter/material.dart';
import 'package:teb_mesada/core/visualization/error_screen.dart';
import 'package:teb_mesada/core/visualization/main_screen.dart';
import 'package:teb_mesada/features/family/family_form.dart';
import 'package:teb_mesada/features/user/user_controller.dart';
import 'package:teb_mesada/features/user/user_local_data_controller.dart';
import 'package:teb_mesada/features/user/visualization/login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    var userLocalDataController = UserLocalDataController();
    var userController = UserController();
    return FutureBuilder(
      //future: userLocalDataController.chechLocalData(),
      future: userController.canLoginByUserLocalData(),
      builder: (ctx, snapshot) {
        // enquanto está carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.error != null) {
            userLocalDataController.clearUserData();
            return ErrorScreen(errorMessage: snapshot.error.toString());
          } else {
            if (userController.currentUser.id.isEmpty) {
              return LayoutBuilder(builder: (context, constraints) => LoginScreen());
            } else {
              // irá avaliar se o usuário possui login ou não
              if (userController.currentUser.familyId.isEmpty) {
                return LayoutBuilder(builder: (context, constraints) => FamilyForm(user: userController.currentUser));
              } else {
                return LayoutBuilder(builder: (context, constraints) => MainScreen(user: userController.currentUser));
              }
            }
          }
        }
      },
    );
  }
}
