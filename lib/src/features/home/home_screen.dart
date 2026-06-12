import 'package:flutter/material.dart';

import '../../app/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC Link Manager')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _HomeHeader(),
          SizedBox(height: 20),
          _NavigationTile(
            icon: Icons.link,
            title: '링크 관리',
            description: 'NFC 태그에 쓸 링크를 준비하고 관리합니다.',
            routeName: AppRoutes.links,
          ),
          SizedBox(height: 12),
          _NavigationTile(
            icon: Icons.nfc,
            title: 'NFC 쓰기',
            description: '선택한 링크를 NFC 태그에 기록하는 화면입니다.',
            routeName: AppRoutes.nfcWrite,
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NFC 링크 관리', style: textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Android와 iOS에서 NFC 태그에 링크를 기록하기 위한 기본 앱 구조입니다.',
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.routeName,
  });

  final IconData icon;
  final String title;
  final String description;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pushNamed(routeName),
      ),
    );
  }
}
