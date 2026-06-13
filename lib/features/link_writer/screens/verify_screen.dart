import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../core/widgets/app_info_card.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_secondary_button.dart';
import '../link_writer_state.dart';
import '../models/nfc_error.dart';
import '../models/nfc_verify_result.dart';
import '../services/nfc_service.dart';
import '../widgets/nfc_status_widgets.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  late NfcService _nfcService;
  bool _isReading = false;
  NfcError? _error;

  String? get _expectedUrl {
    final state = context.read<LinkWriterState>();
    return state.writeResult?.url ?? state.draft?.normalizedUrl;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nfcService = context.read<NfcService>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startVerify());
  }

  @override
  void dispose() {
    _nfcService.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = context.watch<LinkWriterState>().verifyResult;
    final expectedUrl = _expectedUrl;

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
            Text('쓰기 검증', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              '같은 NFC 태그를 다시 스캔해 저장된 URL이 일치하는지 확인합니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (expectedUrl == null)
              _MissingExpectedUrlView(onHome: () => context.go(AppRoutes.home))
            else if (_error != null)
              NfcErrorCard(
                error: _error!,
                onPrimaryAction: _startVerify,
                onSecondaryAction: () => context.go(AppRoutes.home),
              )
            else if (result == null || _isReading)
              NfcScanningView(
                title: '같은 태그를 다시 대세요',
                description: '저장 직후 사용한 NFC 태그를 휴대폰 뒷면에 가까이 대 주세요.',
                icon: Icons.verified_outlined,
              )
            else
              _VerifyResultView(result: result),
          ],
        ),
      ),
    );
  }

  Future<void> _startVerify() async {
    final expectedUrl = _expectedUrl;
    if (expectedUrl == null || _isReading) {
      return;
    }

    setState(() {
      _isReading = true;
      _error = null;
    });

    try {
      final readResult = await _nfcService.readTag();
      if (!mounted) {
        return;
      }

      final verifyResult = NfcVerifyResult(
        expectedUrl: expectedUrl,
        actualUrl: readResult.url,
        isMatched: expectedUrl == readResult.url,
      );
      context.read<LinkWriterState>().setVerifyResult(verifyResult);
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

class _VerifyResultView extends StatelessWidget {
  const _VerifyResultView({required this.result});

  final NfcVerifyResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NfcResultVisual(
          success: result.isMatched,
          title: result.isMatched ? '검증 성공' : 'URL 불일치',
          description:
              result.isMatched
                  ? 'NFC 태그에 저장된 URL이 예상 URL과 일치합니다.'
                  : '같은 태그가 아니거나 저장된 URL이 예상 URL과 다릅니다.',
        ),
        const SizedBox(height: 18),
        AppInfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NfcInfoRow(label: '예상 URL', value: result.expectedUrl),
              const SizedBox(height: 12),
              NfcInfoRow(
                label: '실제 URL',
                value: result.actualUrl ?? '읽은 URL 없음',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (result.isMatched)
          AppPrimaryButton(
            label: 'URL 복사',
            icon: Icons.copy,
            onPressed: () => _copyUrl(context, result.actualUrl),
          )
        else
          AppPrimaryButton(
            label: '다시 쓰기',
            icon: Icons.refresh,
            onPressed: () => context.go(AppRoutes.nfcWrite),
          ),
        const SizedBox(height: 10),
        AppSecondaryButton(
          label: '홈으로 이동',
          icon: Icons.home_outlined,
          onPressed: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }

  Future<void> _copyUrl(BuildContext context, String? url) async {
    if (url == null) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL을 복사했습니다.')));
    }
  }
}

class _MissingExpectedUrlView extends StatelessWidget {
  const _MissingExpectedUrlView({required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppInfoCard(child: Text('검증할 URL이 없습니다. URL 입력부터 다시 진행해 주세요.')),
        const SizedBox(height: 16),
        AppPrimaryButton(label: '홈으로 이동', onPressed: onHome),
      ],
    );
  }
}
