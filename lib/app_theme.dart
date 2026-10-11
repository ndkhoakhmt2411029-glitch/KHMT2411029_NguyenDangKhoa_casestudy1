import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const kBlue = Color(0xFF1F6FEB);
const kBg = Color(0xFFF5F7FB);
const kGreen = Color(0xFF2EA043);
const kRed = Color(0xFFE5484D);
const kRedSoft = Color(0xFFFF6B6B);
const kBorder = Color(0xFFE6EAF2);

/// 5000000 -> "5.000.000 ₫"
String fmtMoney(double v) =>
    '${NumberFormat('#,###', 'en_US').format(v).replaceAll(',', '.')} ₫';

String fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

BoxDecoration cardDecoration([Color color = Colors.white]) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: kBorder),
);

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: kBlue, primary: kBlue),
  scaffoldBackgroundColor: kBg,
  appBarTheme: const AppBarTheme(
    backgroundColor: kBg,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
        color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
  ),
);