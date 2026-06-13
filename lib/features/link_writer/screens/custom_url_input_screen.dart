import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/ndef_size_calculator.dart';
import '../../../core/utils/url_normalizer.dart';
import '../../../core/widgets/app_info_card.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../link_writer_state.dart';
import '../models/link_type.dart';
import '../models/url_draft.dart';

class CustomUrlInputScreen extends StatefulWidget {
  const CustomUrlInputScreen({super.key});

  @override
  State<CustomUrlInputScreen> createState() => _CustomUrlInputScreenState();
}

class _CustomUrlInputScreenState extends State<CustomUrlInputScreen> {
  final _controller = TextEditingController();
  bool _removeTrackingParams = true;

  String? get _normalizedUrl {
    final normalized = UrlNormalizer.normalizeFullUrl(_controller.text);
    if (normalized == null) {
      return null;
    }
    return _removeTrackingParams
        ? UrlNormalizer.removeTrackingParams(normalized)
        : normalized;
  }

  bool get _hasInput => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLinkType =
        context.watch<LinkWriterState>().selectedLinkType ?? LinkType.custom;
    final normalizedUrl = _normalizedUrl;
    final showError = _hasInput && normalizedUrl == null;

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
              'URL을 입력하세요',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${selectedLinkType.label} 링크를 입력하면 자동으로 정리해드립니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            AppTextField(
              controller: _controller,
              label: 'URL',
              hintText: selectedLinkType.placeholder,
              keyboardType: TextInputType.url,
              errorText:
                  showError ? 'http:// 또는 https:// URL만 사용할 수 있습니다.' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            AppInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '정리된 URL 미리보기',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        normalizedUrl == null
                            ? Icons.info_outline
                            : Icons.check_circle,
                        color:
                            normalizedUrl == null
                                ? AppColors.textTertiary
                                : AppColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          normalizedUrl ?? 'URL을 입력하면 정리된 결과가 표시됩니다.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                normalizedUrl == null
                                    ? AppColors.textTertiary
                                    : AppColors.link,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _TrackingToggle(
              value: _removeTrackingParams,
              onChanged:
                  (value) => setState(() => _removeTrackingParams = value),
            ),
            const SizedBox(height: 28),
            AppPrimaryButton(
              label: '다음',
              onPressed:
                  normalizedUrl == null
                      ? null
                      : () => _goToPreview(selectedLinkType, normalizedUrl),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPreview(LinkType linkType, String normalizedUrl) {
    final draft = UrlDraft(
      linkType: linkType,
      originalInput: _controller.text,
      normalizedUrl: normalizedUrl,
      estimatedBytes: NdefSizeCalculator.estimateUrlRecordBytes(normalizedUrl),
      isValid: UrlNormalizer.isValidHttpUrl(normalizedUrl),
    );

    context.read<LinkWriterState>().setDraft(draft);
    context.push(AppRoutes.urlPreview);
  }
}

class _TrackingToggle extends StatelessWidget {
  const _TrackingToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추적 파라미터 제거',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'utm_source, utm_medium, utm_campaign, igsh 제거',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
