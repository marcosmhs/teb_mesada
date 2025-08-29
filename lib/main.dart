import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teb_mesada/core/routes.dart';
import 'package:teb_mesada/core/visualization/error_screen.dart';
import 'package:teb_mesada/core/visualization/landing_screen.dart';
import 'package:teb_mesada/core/visualization/screen_not_found.dart';
import 'package:teb_mesada/features/activity/activity_form.dart';
import 'package:teb_mesada/features/activity/activity_screen.dart';
import 'package:teb_mesada/features/allowance/allowance_form.dart';
import 'package:teb_mesada/features/allowance/allowance_screen.dart';
import 'package:teb_mesada/features/family/family_form.dart';
import 'package:teb_mesada/features/schedule/visualization/schedule_form.dart';
import 'package:teb_mesada/features/schedule/visualization/schedule_screen.dart';
import 'package:teb_mesada/features/user/visualization/child_screen.dart';
import 'package:teb_mesada/features/user/visualization/family_invite.dart';
import 'package:teb_mesada/features/user/visualization/login_screen.dart';
import 'package:teb_mesada/features/user/visualization/user_form.dart';
import 'package:teb_mesada/firebase_options.dart';
import 'package:teb_mesada/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(Mesada());
}

class Mesada extends StatefulWidget {
  const Mesada({super.key});

  @override
  State<Mesada> createState() => _Home();
}

class _Home extends State<Mesada> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('en', ''), Locale('pt-br', '')],
      title: 'Mesada',
      routes: {
        Routes.errorScreen: (ctx) => const ErrorScreen(),
        Routes.landingScreen: (ctx) => const LandingScreen(),
        //user
        Routes.loginScreen: (ctx) => const LoginScreen(),
        Routes.userForm: (ctx) => UserForm(),

        //family
        Routes.familyForm: (ctx) => FamilyForm(),
        Routes.childScreen: (ctx) => ChildScreen(),
        Routes.familyInvite: (ctx) => FamilyInvite(),

        //activity
        Routes.activityScreen: (ctx) => ActivityScreen(),
        Routes.activityForm: (ctx) => ActivityForm(),

        //schedule
        Routes.scheduleScreen: (ctx) => ScheduleScreen(),
        Routes.scheduleForm: (ctx) => ScheduleForm(),

        //allowance
        Routes.allowanceScreen: (ctx) => AllowanceScreen(),
        Routes.allowanceForm: (ctx) => AllowanceForm(),
      },
      //theme: widget.themeData,
      theme: appTheme,
      initialRoute: Routes.landingScreen,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) {
            return ScreenNotFound(settings.name.toString());
          },
        );
      },
    );
  }
}
