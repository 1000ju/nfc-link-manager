import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/link_writer/link_writer_state.dart';
import 'router.dart';
import 'theme.dart';

class NfcLinkWriterApp extends StatefulWidget {
  const NfcLinkWriterApp({super.key});

  @override
  State<NfcLinkWriterApp> createState() => _NfcLinkWriterAppState();
}

class _NfcLinkWriterAppState extends State<NfcLinkWriterApp> {
  late final _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LinkWriterState(),
      child: MaterialApp.router(
        title: 'NFC Link Writer',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: _router,
      ),
    );
  }
}
