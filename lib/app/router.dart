import 'package:go_router/go_router.dart';

import '../features/link_writer/screens/custom_url_input_screen.dart';
import '../features/link_writer/screens/home_screen.dart';
import '../features/link_writer/screens/instagram_input_screen.dart';
import '../features/link_writer/screens/link_type_select_screen.dart';
import '../features/link_writer/screens/url_preview_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const linkTypes = '/link-types';
  static const instagramInput = '/instagram-input';
  static const customUrlInput = '/custom-url-input';
  static const urlPreview = '/url-preview';
}

GoRouter createAppRouter() {
  return GoRouter(
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
    ],
  );
}
