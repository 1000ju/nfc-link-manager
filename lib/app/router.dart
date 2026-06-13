import 'package:go_router/go_router.dart';

import '../core/utils/ndef_size_calculator.dart';
import '../core/utils/url_normalizer.dart';
import '../features/link_writer/link_writer_state.dart';
import '../features/link_writer/screens/custom_url_input_screen.dart';
import '../features/link_writer/screens/home_screen.dart';
import '../features/link_writer/screens/instagram_input_screen.dart';
import '../features/link_writer/screens/link_type_select_screen.dart';
import '../features/link_writer/screens/nfc_read_screen.dart';
import '../features/link_writer/screens/nfc_write_screen.dart';
import '../features/link_writer/screens/tag_check_screen.dart';
import '../features/link_writer/screens/url_preview_screen.dart';
import '../features/link_writer/screens/verify_screen.dart';
import '../features/link_writer/screens/write_result_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const linkTypes = '/link-types';
  static const instagramInput = '/instagram-input';
  static const customUrlInput = '/custom-url-input';
  static const urlPreview = '/url-preview';
  static const nfcWrite = '/nfc-write';
  static const writeResult = '/write-result';
  static const verify = '/verify';
  static const nfcRead = '/nfc-read';
  static const tagCheck = '/tag-check';
}

GoRouter createAppRouter(LinkWriterState linkWriterState) {
  return GoRouter(
    refreshListenable: linkWriterState,
    redirect: (context, state) => _guardRoute(linkWriterState, state),
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.linkTypes,
        builder: (context, state) => const LinkTypeSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.instagramInput,
        builder: (context, state) => const InstagramInputScreen(),
      ),
      GoRoute(
        path: AppRoutes.customUrlInput,
        builder: (context, state) => const CustomUrlInputScreen(),
      ),
      GoRoute(
        path: AppRoutes.urlPreview,
        builder: (context, state) => const UrlPreviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.nfcWrite,
        builder: (context, state) => const NfcWriteScreen(),
      ),
      GoRoute(
        path: AppRoutes.writeResult,
        builder: (context, state) => const WriteResultScreen(),
      ),
      GoRoute(
        path: AppRoutes.verify,
        builder: (context, state) => const VerifyScreen(),
      ),
      GoRoute(
        path: AppRoutes.nfcRead,
        builder: (context, state) => const NfcReadScreen(),
      ),
      GoRoute(
        path: AppRoutes.tagCheck,
        builder: (context, state) => const TagCheckScreen(),
      ),
    ],
  );
}

String? _guardRoute(LinkWriterState linkWriterState, GoRouterState state) {
  final path = state.uri.path;
  final draft = linkWriterState.draft;
  final hasValidDraft =
      draft != null &&
      draft.isValid &&
      UrlNormalizer.isValidHttpUrl(draft.normalizedUrl);
  final canWriteDraft =
      hasValidDraft &&
      NdefSizeCalculator.canStoreInNtag213(draft.normalizedUrl);

  if ((path == AppRoutes.urlPreview || path == AppRoutes.nfcWrite) &&
      !hasValidDraft) {
    return AppRoutes.linkTypes;
  }

  if (path == AppRoutes.nfcWrite && !canWriteDraft) {
    return AppRoutes.urlPreview;
  }

  if (path == AppRoutes.writeResult && linkWriterState.writeResult == null) {
    return AppRoutes.home;
  }

  final writeResult = linkWriterState.writeResult;
  final hasSuccessfulWrite = writeResult != null && writeResult.success;
  if (path == AppRoutes.verify && !hasSuccessfulWrite) {
    return AppRoutes.home;
  }

  return null;
}
