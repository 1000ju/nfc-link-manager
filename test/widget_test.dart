import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_link_manager/src/app/nfc_link_manager_app.dart';

void main() {
  testWidgets('home routes to link management and NFC write screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NfcLinkManagerApp());

    expect(find.text('NFC Link Manager'), findsOneWidget);
    expect(find.text('링크 관리'), findsOneWidget);
    expect(find.text('NFC 쓰기'), findsOneWidget);

    await tester.tap(find.text('링크 관리'));
    await tester.pumpAndSettle();

    expect(find.text('링크 관리 화면'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('NFC 쓰기'));
    await tester.pumpAndSettle();

    expect(find.text('NFC 쓰기 준비'), findsOneWidget);
    expect(find.text('현재 어댑터: 플랫폼 구현 미연결'), findsOneWidget);
  });
}
