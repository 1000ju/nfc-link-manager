import 'package:flutter/material.dart';

class LinkManagementScreen extends StatelessWidget {
  const LinkManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('링크 관리')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('링크 관리 화면', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text('다음 단계에서 링크 등록, 수정, 선택 흐름을 추가합니다.'),
          const SizedBox(height: 20),
          const _EmptyLinkCard(),
        ],
      ),
    );
  }
}

class _EmptyLinkCard extends StatelessWidget {
  const _EmptyLinkCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.link_off),
            SizedBox(height: 12),
            Text('아직 등록된 링크가 없습니다.'),
            SizedBox(height: 4),
            Text('저장소와 편집 UI는 별도 단계에서 연결합니다.'),
          ],
        ),
      ),
    );
  }
}
