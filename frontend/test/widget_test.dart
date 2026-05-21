import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahe_sehat_mobile/app.dart';

void main() {
  testWidgets('Rahe-Sehat app renders splash experience', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RaheSehatApp()));
    await tester.pump();

    expect(find.text('Rahe-Sehat\nHealthcare AI'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
