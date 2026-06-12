import 'package:flutter/material.dart';

import '../../nfc/nfc_writer.dart';

class NfcWriteScreen extends StatelessWidget {
  const NfcWriteScreen({super.key, required this.nfcWriter});

  final NfcWriter nfcWriter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC 쓰기')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('NFC 쓰기 준비', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text('이 화면은 NFC 쓰기 플로우의 UI 진입점입니다.'),
          const SizedBox(height: 20),
          _NfcBoundaryCard(nfcWriter: nfcWriter),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.nfc),
            label: const Text('다음 단계에서 NFC 쓰기 연결'),
          ),
        ],
      ),
    );
  }
}

class _NfcBoundaryCard extends StatelessWidget {
  const _NfcBoundaryCard({required this.nfcWriter});

  final NfcWriter nfcWriter;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.device_hub),
            const SizedBox(height: 12),
            const Text('UI와 플랫폼 로직 분리'),
            const SizedBox(height: 8),
            const Text(
              '화면은 NFC 추상화에만 의존하고, 실제 Android/iOS 구현은 플랫폼 어댑터에서 연결합니다.',
            ),
            const SizedBox(height: 12),
            Text('현재 어댑터: ${nfcWriter.availabilityLabel}'),
          ],
        ),
      ),
    );
  }
}
