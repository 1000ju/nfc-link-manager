import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../core/widgets/app_action_card.dart';
import '../link_writer_state.dart';
import '../models/link_input_mode.dart';
import '../models/link_type.dart';

class LinkTypeSelectScreen extends StatelessWidget {
  const LinkTypeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            8,
            AppSpacing.screenPadding,
            AppSpacing.bottomSafePadding,
          ),
          children: [
            Text(
              '링크 유형을 선택하세요',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '저장할 링크의 유형에 맞는 입력 방식을 선택하세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            for (final linkType in LinkType.values) ...[
              AppActionCard(
                icon: _iconFor(linkType.iconName),
                title: linkType.label,
                description: linkType.description,
                iconBackgroundColor: _iconBackgroundFor(linkType.id),
                onTap: () => _selectLinkType(context, linkType),
              ),
              const SizedBox(height: AppSpacing.itemGap),
            ],
          ],
        ),
      ),
    );
  }

  void _selectLinkType(BuildContext context, LinkType linkType) {
    context.read<LinkWriterState>().selectLinkType(linkType);
    if (linkType.inputMode == LinkInputMode.username) {
      context.push(AppRoutes.instagramInput);
    } else {
      context.push(AppRoutes.customUrlInput);
    }
  }

  IconData _iconFor(String iconName) {
    return switch (iconName) {
      'instagram' => Icons.camera_alt_outlined,
      'linkedin' => Icons.business_center_outlined,
      'github' => Icons.code,
      'linktree' => Icons.hub_outlined,
      'portfolio' => Icons.desktop_mac_outlined,
      _ => Icons.link,
    };
  }

  Color _iconBackgroundFor(String id) {
    return switch (id) {
      'instagram' => const Color(0xFFE1306C),
      'linkedin' => const Color(0xFF0A66C2),
      'github' => const Color(0xFF111827),
      'linktree' => const Color(0xFF22C55E),
      'portfolio' => const Color(0xFF64748B),
      _ => AppColors.textSecondary,
    };
  }
}
