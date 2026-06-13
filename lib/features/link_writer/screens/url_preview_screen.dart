import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/ndef_size_calculator.dart';
import '../../../core/widgets/app_info_card.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_secondary_button.dart';
import '../link_writer_state.dart';
import '../models/link_input_mode.dart';
import '../models/url_draft.dart';

class UrlPreviewScreen extends StatelessWidget {
  const UrlPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<LinkWriterState>().draft;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        top: false,
        child:
            draft == null
                ? const _MissingDraftView()
                : _PreviewView(draft: draft),
      ),
    );
  }
}

class _PreviewView extends StatelessWidget {
  const _PreviewView({required this.draft});

  final UrlDraft draft;

  @override
  Widget build(BuildContext context) {
    final canStore = NdefSizeCalculator.canStoreInNtag213(draft.normalizedUrl);
    final usageRatio = (draft.estimatedBytes / NdefSizeCalculator.maxBytes)
        .clamp(0.0, 1.0);
    final percentage = (usageRatio * 100).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        8,
        AppSpacing.screenPadding,
        AppSpacing.bottomSafePadding,
      ),
      children: [
        Text('저장할 링크를 확인하세요', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'NFC 태그에 저장하기 전에 최종 URL과 용량을 확인하세요.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        AppInfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(label: '링크 유형', value: draft.linkType.label),
              const SizedBox(height: 14),
              Text('최종 URL', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 8),
              Text(
                draft.normalizedUrl,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.link,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _InfoRow(label: '예상 크기', value: '${draft.estimatedBytes} byte'),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('사용량', style: Theme.of(context).textTheme.labelSmall),
                  Text(
                    '${draft.estimatedBytes} / ${NdefSizeCalculator.maxBytes} byte ($percentage%)',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.badge),
                child: LinearProgressIndicator(
                  value: usageRatio,
                  minHeight: 7,
                  color: canStore ? AppColors.success : AppColors.error,
                  backgroundColor: AppColors.backgroundSubtle,
                ),
              ),
              const SizedBox(height: 18),
              _StatusBadge(canStore: canStore),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: AppSecondaryButton(
                label: 'URL 열기',
                icon: Icons.open_in_new,
                onPressed:
                    () => _showSnackBar(context, 'URL 열기는 다음 단계에서 연결합니다.'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppSecondaryButton(
                label: '수정하기',
                icon: Icons.edit_outlined,
                onPressed: () => _goToEdit(context, draft),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppPrimaryButton(
          label: 'NFC 태그에 쓰기',
          icon: Icons.nfc,
          onPressed:
              canStore
                  ? () => _showSnackBar(context, 'NFC 쓰기는 다음 작업에서 구현합니다.')
                  : null,
        ),
      ],
    );
  }

  void _goToEdit(BuildContext context, UrlDraft draft) {
    if (draft.linkType.inputMode == LinkInputMode.username) {
      context.go(AppRoutes.instagramInput);
    } else {
      context.go(AppRoutes.customUrlInput);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MissingDraftView extends StatelessWidget {
  const _MissingDraftView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '미리볼 URL이 없습니다',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '링크 유형을 선택하고 URL을 입력한 뒤 다시 확인해 주세요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          AppPrimaryButton(
            label: '링크 유형 선택으로 이동',
            onPressed: () => context.go(AppRoutes.linkTypes),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.canStore});

  final bool canStore;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        canStore ? AppColors.successBackground : AppColors.errorBackground;
    final foregroundColor = canStore ? AppColors.success : AppColors.error;
    final label = canStore ? '저장 가능합니다' : '용량이 부족합니다';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            canStore ? Icons.check_circle : Icons.error,
            size: 18,
            color: foregroundColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: foregroundColor),
          ),
        ],
      ),
    );
  }
}
