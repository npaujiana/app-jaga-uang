import 'package:flutter_test/flutter_test.dart';
import 'package:jaga_uang/main.dart';

void main() {
  testWidgets('JagaUang app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JagaUangApp());
    expect(find.text('JagaUang'), findsWidgets);
    expect(find.text('Beranda'), findsWidgets);
  });
}
