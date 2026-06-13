import 'package:flutter/material.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/widgets/app_info_card.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_secondary_button.dart';
import '../models/nfc_error.dart';
import '../models/nfc_tag_info.dart';

class NfcScanningView extends StatelessWidget {
  const NfcScanningView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: const BoxDecoration(
              color: AppColors.backgroundSubtle,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 52),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          const LinearProgressIndicator(minHeight: 6),
        ],
      ),
    );
  }
}

class NfcErrorCard extends StatelessWidget {
  const NfcErrorCard({
    super.key,
    required this.error,
    required this.onPrimaryAction,
    this.onSecondaryAction,
    this.secondaryActionLabel = '홈으로 이동',
  });

  final NfcError error;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final String secondaryActionLabel;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.errorBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, color: AppColors.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            error.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          AppPrimaryButton(
            label: error.actionLabel,
            icon: Icons.refresh,
            onPressed: onPrimaryAction,
          ),
          if (onSecondaryAction != null) ...[
            const SizedBox(height: 10),
            AppSecondaryButton(
              label: secondaryActionLabel,
              icon: Icons.home_outlined,
              onPressed: onSecondaryAction,
            ),
          ],
        ],
      ),
    );
  }
}

class NfcTagInfoCard extends StatelessWidget {
  const NfcTagInfoCard({super.key, required this.tagInfo});

  final NfcTagInfo tagInfo;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NfcInfoRow(label: '태그 ID', value: tagInfo.displayTagId),
          const SizedBox(height: 12),
          NfcInfoRow(label: '태그 타입', value: tagInfo.tagType ?? '알 수 없음'),
          const SizedBox(height: 12),
          NfcInfoRow(
            label: 'NDEF 지원',
            value: _formatBool(tagInfo.ndefAvailable),
          ),
          const SizedBox(height: 12),
          NfcInfoRow(label: '쓰기 가능', value: _formatBool(tagInfo.isWritable)),
          const SizedBox(height: 12),
          NfcInfoRow(label: '최대 용량', value: '${tagInfo.maxSize} byte'),
          const SizedBox(height: 12),
          NfcInfoRow(label: '현재 사용량', value: '${tagInfo.currentSize} byte'),
          const SizedBox(height: 12),
          NfcInfoRow(label: '읽기 전용', value: _formatBool(tagInfo.isReadOnly)),
        ],
      ),
    );
  }

  String _formatBool(bool value) => value ? '예' : '아니오';
}

class NfcInfoRow extends StatelessWidget {
  const NfcInfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(width: 12),
        Expanded(
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

class NfcResultVisual extends StatelessWidget {
  const NfcResultVisual({
    super.key,
    required this.success,
    required this.title,
    required this.description,
  });

  final bool success;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final background =
        success ? AppColors.successBackground : AppColors.errorBackground;
    final foreground = success ? AppColors.success : AppColors.error;

    return AppInfoCard(
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: foreground,
              size: 48,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
