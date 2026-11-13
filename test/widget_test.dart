import 'package:flutter_test/flutter_test.dart';
import 'package:sakukuliah/main.dart';

void main() {
  testWidgets('SakuKuliahApp renders splash and onboarding successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SakuKuliahApp());

    // Verify app name is displayed
    expect(find.text('SakuKuliah'), findsOneWidget);
    expect(find.text('Teman Pintar Perjalanan Kuliahmu'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
  });
}

