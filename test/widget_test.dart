import 'package:flutter_test/flutter_test.dart';
import 'package:hypermarket_erp/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const HypermarketERP());
    expect(find.text('Hypermarket ERP'), findsOneWidget);
  });
}
