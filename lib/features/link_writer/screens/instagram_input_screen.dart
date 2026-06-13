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

class InstagramInputScreen extends StatefulWidget {
  const InstagramInputScreen({super.key});

  @override
  State<InstagramInputScreen> createState() => _InstagramInputScreenState();
}

class _InstagramInputScreenState extends State<InstagramInputScreen> {
  final _controller = TextEditingController();

  String? get _normalizedUrl {
    return UrlNormalizer.normalizeInstagramUsername(_controller.text);
  }

  bool get _hasInput => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              'Instagram 계정명을 입력하세요',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '계정명만 입력하면 자동으로 Instagram URL을 생성합니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            const _InstagramVisual(),
            const SizedBox(height: 24),
            AppTextField(
              controller: _controller,
              label: '계정명',
              hintText: '@romrom_official',
              errorText: showError ? '올바른 계정명을 입력해 주세요.' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            AppInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '생성 URL 미리보기',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    normalizedUrl ?? '계정명을 입력하면 URL이 표시됩니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          normalizedUrl == null
                              ? AppColors.textTertiary
                              : AppColors.link,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            AppPrimaryButton(
              label: '다음',
              onPressed:
                  normalizedUrl == null
                      ? null
                      : () => _goToPreview(normalizedUrl),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPreview(String normalizedUrl) {
    final draft = UrlDraft(
      linkType: LinkType.instagram,
      originalInput: _controller.text,
      normalizedUrl: normalizedUrl,
      estimatedBytes: NdefSizeCalculator.estimateUrlRecordBytes(normalizedUrl),
      isValid: UrlNormalizer.isValidHttpUrl(normalizedUrl),
    );

    context.read<LinkWriterState>().setDraft(draft);
    context.push(AppRoutes.urlPreview);
  }
}

class _InstagramVisual extends StatelessWidget {
  const _InstagramVisual();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 86,
        height: 86,
        decoration: const BoxDecoration(
          color: Color(0xFFFFEEF5),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.camera_alt_outlined,
          color: Color(0xFFE1306C),
          size: 42,
        ),
      ),
    );
  }
}
