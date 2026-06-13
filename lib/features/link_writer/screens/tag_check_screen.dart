import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/ndef_size_calculator.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_secondary_button.dart';
import '../link_writer_state.dart';
import '../models/nfc_error.dart';
import '../models/nfc_tag_info.dart';
import '../services/nfc_service.dart';
import '../widgets/nfc_status_widgets.dart';

class TagCheckScreen extends StatefulWidget {
  const TagCheckScreen({super.key});

  @override
  State<TagCheckScreen> createState() => _TagCheckScreenState();
}

class _TagCheckScreenState extends State<TagCheckScreen> {
  late NfcService _nfcService;
  bool _isChecking = false;
  NfcError? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nfcService = context.read<NfcService>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCheck());
  }

  @override
  void dispose() {
    _nfcService.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagInfo = context.watch<LinkWriterState>().checkedTagInfo;

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
            Text('태그 상태 확인', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'NDEF 지원, 쓰기 가능 여부, 용량을 확인합니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (_error != null)
              NfcErrorCard(
                error: _error!,
                onPrimaryAction: _startCheck,
                onSecondaryAction: () => context.go(AppRoutes.home),
              )
            else if (tagInfo == null || _isChecking)
              const NfcScanningView(
                title: '태그 스캔 대기 중',
                description: '상태를 확인할 NFC 태그를 휴대폰 뒷면에 가까이 대 주세요.',
                icon: Icons.verified_user,
              )
            else
              _TagCheckResultView(tagInfo: tagInfo, onRescan: _startCheck),
          ],
        ),
      ),
    );
  }

  Future<void> _startCheck() async {
    if (_isChecking) {
      return;
    }

    setState(() {
      _isChecking = true;
      _error = null;
    });

    try {
      final tagInfo = await _nfcService.checkTag();
      if (!mounted) {
        return;
      }

      context.read<LinkWriterState>().setCheckedTagInfo(tagInfo);
    } on NfcException catch (error) {
      if (mounted) {
        setState(() => _error = error.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }
}

class _TagCheckResultView extends StatelessWidget {
  const _TagCheckResultView({required this.tagInfo, required this.onRescan});

  final NfcTagInfo tagInfo;
  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context) {
    final canStore = tagInfo.canStoreNtag213Url;

    return Column(
      children: [
        NfcResultVisual(
          success: canStore,
          title: canStore ? 'URL 저장에 적합합니다' : '저장 조건을 확인하세요',
          description:
              canStore
                  ? 'NTAG213 기준 ${NdefSizeCalculator.maxBytes} byte URL 저장 조건을 만족합니다.'
                  : 'NDEF 지원, 쓰기 가능 여부, 용량 또는 읽기 전용 상태를 확인해야 합니다.',
        ),
        const SizedBox(height: 18),
        NfcTagInfoCard(tagInfo: tagInfo),
        const SizedBox(height: 18),
        AppPrimaryButton(
          label: '다시 스캔',
          icon: Icons.refresh,
          onPressed: onRescan,
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
}
