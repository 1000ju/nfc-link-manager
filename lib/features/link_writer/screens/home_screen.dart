import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../core/widgets/app_action_card.dart';
import '../../../core/widgets/app_info_card.dart';
import '../../../core/widgets/app_secondary_button.dart';
import '../link_writer_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recentUrl = context.watch<LinkWriterState>().recentUrl;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            36,
            AppSpacing.screenPadding,
            AppSpacing.bottomSafePadding,
          ),
          children: [
            Text(
              'NFC Link Manager',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'NFC 태그에 원하는 링크를 저장하세요',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Instagram, GitHub, LinkedIn, Portfolio 등 다양한 링크를 NFC 태그에 담아보세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            _HeroCard(),
            if (recentUrl != null) ...[
              const SizedBox(height: 18),
              _RecentUrlCard(recentUrl: recentUrl),
            ],
            const SizedBox(height: 28),
            AppActionCard(
              icon: Icons.edit_square,
              title: 'NFC 태그 만들기',
              description: '새로운 링크를 NFC 태그에 저장할 준비를 합니다.',
              onTap: () => context.push(AppRoutes.linkTypes),
            ),
            const SizedBox(height: AppSpacing.itemGap),
            AppActionCard(
              icon: Icons.sensors,
              title: 'NFC 태그 읽기',
              description: '기존 NFC 태그의 링크를 확인합니다.',
              iconBackgroundColor: const Color(0xFF3B82F6),
              onTap: () => context.push(AppRoutes.nfcRead),
            ),
            const SizedBox(height: AppSpacing.itemGap),
            AppActionCard(
              icon: Icons.verified_user,
              title: '태그 상태 확인',
              description: 'NFC 태그가 URL 저장에 적합한지 확인합니다.',
              iconBackgroundColor: const Color(0xFF7C3AED),
              onTap: () => context.push(AppRoutes.tagCheck),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentUrlCard extends StatelessWidget {
  const _RecentUrlCard({required this.recentUrl});

  final String recentUrl;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('최근 URL', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Text(
            recentUrl,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.link,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          AppSecondaryButton(
            label: '최근 URL 삭제',
            icon: Icons.delete_outline,
            onPressed: () => context.read<LinkWriterState>().clearRecentUrl(),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: AppColors.backgroundSubtle,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.nfc, color: AppColors.primary, size: 36),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              'URL을 만들고 용량을 확인한 뒤 NFC 쓰기 단계로 넘기는 기본 흐름입니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
