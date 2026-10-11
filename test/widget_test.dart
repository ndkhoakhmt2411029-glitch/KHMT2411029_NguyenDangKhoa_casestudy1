import 'package:flutter_test/flutter_test.dart';
import 'package:project1/main.dart';

void main() {
  testWidgets('Hiện màn hình chào mừng', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseApp(showWelcome: true));

    expect(find.text('Expense Manager'), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
  });
}