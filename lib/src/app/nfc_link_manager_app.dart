import 'package:flutter/material.dart';

import '../features/home/home_screen.dart';
import '../features/link_management/link_management_screen.dart';
import '../features/nfc_write/nfc_write_screen.dart';
import '../nfc/platform/unsupported_nfc_writer.dart';
import 'app_routes.dart';

class NfcLinkManagerApp extends StatelessWidget {
  const NfcLinkManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Link Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006B5B)),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.links: (_) => const LinkManagementScreen(),
        AppRoutes.nfcWrite:
            (_) => const NfcWriteScreen(nfcWriter: UnsupportedNfcWriter()),
      },
    );
  }
}
