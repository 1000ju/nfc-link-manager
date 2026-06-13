import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../core/widgets/app_info_card.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_secondary_button.dart';
import '../link_writer_state.dart';
import '../models/nfc_error.dart';
import '../models/nfc_write_result.dart';
import '../widgets/nfc_status_widgets.dart';

class WriteResultScreen extends StatelessWidget {
  const WriteResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result = context.watch<LinkWriterState>().writeResult;

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
            Text('쓰기 결과', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'NFC 태그에 URL을 저장한 결과입니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (result == null)
              _MissingResultView(onHome: () => context.go(AppRoutes.home))
            else
              _ResultView(result: result),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});

  final NfcWriteResult result;

  @override
  Widget build(BuildContext context) {
    final error = NfcError.fromCode(result.errorCode);

    return Column(
      children: [
        NfcResultVisual(
          success: result.success,
          title: result.success ? 'URL 저장 완료' : error.title,
          description:
              result.success
                  ? 'NFC 태그에 URL을 저장했습니다. 같은 태그를 다시 읽어 검증할 수 있습니다.'
                  : result.errorMessage ?? error.description,
        ),
        const SizedBox(height: 18),
        AppInfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('저장 URL', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 8),
              Text(
                result.url,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.link,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (result.success)
          AppPrimaryButton(
            label: '검증하기',
            icon: Icons.verified_outlined,
            onPressed: () => context.go(AppRoutes.verify),
          )
        else
          AppPrimaryButton(
            label: '다시 시도',
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
}

class _MissingResultView extends StatelessWidget {
  const _MissingResultView({required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppInfoCard(child: Text('쓰기 결과가 없습니다. URL 입력부터 다시 진행해 주세요.')),
        const SizedBox(height: 16),
        AppPrimaryButton(label: '홈으로 이동', onPressed: onHome),
      ],
    );
  }
}
