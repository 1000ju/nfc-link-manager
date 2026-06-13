import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/ndef_size_calculator.dart';
import '../../../core/utils/url_normalizer.dart';
import '../../../core/widgets/app_info_card.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_secondary_button.dart';
import '../link_writer_state.dart';
import '../models/link_type.dart';
import '../models/nfc_error.dart';
import '../models/nfc_read_result.dart';
import '../models/url_draft.dart';
import '../services/nfc_service.dart';
import '../widgets/nfc_status_widgets.dart';

class NfcReadScreen extends StatefulWidget {
  const NfcReadScreen({super.key});

  @override
  State<NfcReadScreen> createState() => _NfcReadScreenState();
}

class _NfcReadScreenState extends State<NfcReadScreen> {
  late NfcService _nfcService;
  bool _isReading = false;
  NfcError? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nfcService = context.read<NfcService>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRead());
  }

  @override
  void dispose() {
    _nfcService.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = context.watch<LinkWriterState>().readResult;

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
            Text('NFC 태그 읽기', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'NFC 태그를 가까이 대세요. 저장된 URL과 태그 정보를 읽습니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (_error != null)
              NfcErrorCard(
                error: _error!,
                onPrimaryAction: _startRead,
                onSecondaryAction: () => context.go(AppRoutes.home),
              )
            else if (result == null || _isReading)
              const NfcScanningView(
                title: '태그 스캔 대기 중',
                description: 'NFC 태그를 휴대폰 뒷면에 가까이 대 주세요.',
                icon: Icons.sensors,
              )
            else
              _ReadResultView(result: result),
          ],
        ),
      ),
    );
  }

  Future<void> _startRead() async {
    if (_isReading) {
      return;
    }

    setState(() {
      _isReading = true;
      _error = null;
    });

    try {
      final result = await _nfcService.readTag();
      if (!mounted) {
        return;
      }

      context.read<LinkWriterState>().setReadResult(result);
    } on NfcException catch (error) {
      if (mounted) {
        setState(() => _error = error.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isReading = false);
      }
    }
  }
}

class _ReadResultView extends StatelessWidget {
  const _ReadResultView({required this.result});

  final NfcReadResult result;

  @override
  Widget build(BuildContext context) {
    final url = result.url;
    final isValidUrl = url != null && UrlNormalizer.isValidHttpUrl(url);

    return Column(
      children: [
        AppInfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('저장된 URL', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 8),
              Text(
                url ?? 'NDEF URL Record가 없습니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: url == null ? AppColors.textTertiary : AppColors.link,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        NfcTagInfoCard(tagInfo: result.tagInfo),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: AppSecondaryButton(
                label: 'URL 복사',
                icon: Icons.copy,
                onPressed: url == null ? null : () => _copyUrl(context, url),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppSecondaryButton(
                label: 'URL 열기',
                icon: Icons.open_in_new,
                onPressed:
                    isValidUrl
                        ? () => _showSnackBar(context, 'URL 열기는 다음 단계에서 연결합니다.')
                        : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppPrimaryButton(
          label: '다시 쓰기',
          icon: Icons.edit_square,
          onPressed: isValidUrl ? () => _rewrite(context, url) : null,
        ),
      ],
    );
  }

  Future<void> _copyUrl(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      _showSnackBar(context, 'URL을 복사했습니다.');
    }
  }

  void _rewrite(BuildContext context, String url) {
    final draft = UrlDraft(
      linkType: LinkType.custom,
      originalInput: url,
      normalizedUrl: url,
      estimatedBytes: NdefSizeCalculator.estimateUrlRecordBytes(url),
      isValid: UrlNormalizer.isValidHttpUrl(url),
    );

    context.read<LinkWriterState>().setDraft(draft);
    context.go(AppRoutes.urlPreview);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
