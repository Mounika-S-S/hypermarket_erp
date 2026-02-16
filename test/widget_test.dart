import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    expect(find.text('Login'), findsOneWidget);

  });
}
