import 'package:flutter/material.dart';
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
import '../models/nfc_error.dart';
import '../models/url_draft.dart';
import '../services/nfc_service.dart';
import '../widgets/nfc_status_widgets.dart';

class NfcWriteScreen extends StatefulWidget {
  const NfcWriteScreen({super.key});

  @override
  State<NfcWriteScreen> createState() => _NfcWriteScreenState();
}

class _NfcWriteScreenState extends State<NfcWriteScreen> {
  late NfcService _nfcService;
  bool _isWriting = false;
  NfcError? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nfcService = context.read<NfcService>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startWrite());
  }

  @override
  void dispose() {
    _nfcService.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<LinkWriterState>().draft;

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
              'NFC 태그에 쓰기',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '휴대폰 뒷면을 NFC 태그에 가까이 대세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (draft == null)
              _MissingDraftView(onBack: () => context.go(AppRoutes.linkTypes))
            else ...[
              if (_error == null)
                NfcScanningView(
                  title: _isWriting ? '태그 대기 중' : '쓰기 준비 완료',
                  description: '태그가 감지되면 아래 URL을 NDEF URL Record로 저장합니다.',
                  icon: Icons.nfc,
                )
              else
                NfcErrorCard(
                  error: _error!,
                  onPrimaryAction: _startWrite,
                  onSecondaryAction: () => context.go(AppRoutes.home),
                ),
              const SizedBox(height: 18),
              AppInfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '저장할 URL',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      draft.normalizedUrl,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.link,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppSecondaryButton(
                label: '취소',
                icon: Icons.close,
                onPressed: _cancel,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startWrite() async {
    final draft = context.read<LinkWriterState>().draft;
    if (draft == null || _isWriting) {
      return;
    }

    final validationError = _validateDraftForWrite(draft);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _isWriting = true;
      _error = null;
    });

    final result = await _nfcService.writeUrl(draft.normalizedUrl);
    if (!mounted) {
      return;
    }

    context.read<LinkWriterState>().setWriteResult(result);

    if (result.success) {
      context.go(AppRoutes.writeResult);
      return;
    }

    setState(() {
      _isWriting = false;
      _error = NfcError.fromCode(result.errorCode);
    });
  }

  Future<void> _cancel() async {
    await _nfcService.stopSession();
    if (mounted) {
      context.pop();
    }
  }

  NfcError? _validateDraftForWrite(UrlDraft draft) {
    if (!draft.isValid || !UrlNormalizer.isValidHttpUrl(draft.normalizedUrl)) {
      return NfcError.invalidUrl;
    }
    if (!NdefSizeCalculator.canStoreInNtag213(draft.normalizedUrl)) {
      return NfcError.capacityExceeded;
    }

    return null;
  }
}

class _MissingDraftView extends StatelessWidget {
  const _MissingDraftView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppInfoCard(child: Text('저장할 URL이 없습니다. 먼저 링크를 입력해 주세요.')),
        const SizedBox(height: 16),
        AppPrimaryButton(label: '링크 유형 선택으로 이동', onPressed: onBack),
      ],
    );
  }
}
