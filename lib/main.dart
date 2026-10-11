import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_theme.dart';
import 'database_helper.dart';
import 'main_shell.dart';
import 'welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN');
  final welcomed = await DatabaseHelper.instance.getSetting('welcomed') == '1';
  runApp(ExpenseApp(showWelcome: !welcomed));
}

class ExpenseApp extends StatelessWidget {
  final bool showWelcome;
  const ExpenseApp({super.key, required this.showWelcome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: showWelcome ? const WelcomeScreen() : const MainShell(),
    );
  }
}
