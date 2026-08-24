import 'package:flutter_test/flutter_test.dart';
import 'package:idris_school_app/main.dart';

void main() {
  testWidgets('The app starts with the splash screen', (tester) async {
    await tester.pumpWidget(const IdrisSchoolApp());
    expect(find.text('مؤسسة إدريس'), findsOneWidget);
  });
}
