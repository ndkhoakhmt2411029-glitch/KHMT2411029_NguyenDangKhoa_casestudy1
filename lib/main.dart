import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dashboard_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN');
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardScreen(),
  ));
}