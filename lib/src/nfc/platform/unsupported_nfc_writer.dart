import '../nfc_writer.dart';

final class UnsupportedNfcWriter implements NfcWriter {
  const UnsupportedNfcWriter();

  @override
  String get availabilityLabel => '플랫폼 구현 미연결';

  @override
  Future<NfcWriteResult> writeLink(NfcWritePayload payload) async {
    return const NfcWriteResult(
      isSuccess: false,
      message: 'NFC 쓰기는 다음 단계에서 Android/iOS 플랫폼 구현으로 연결합니다.',
    );
  }
}
