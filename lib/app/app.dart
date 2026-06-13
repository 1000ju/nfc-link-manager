import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/link_writer/link_writer_state.dart';
import '../features/link_writer/services/nfc_service.dart';
import 'router.dart';
import 'theme.dart';

class NfcLinkWriterApp extends StatefulWidget {
  const NfcLinkWriterApp({super.key, this.nfcService, this.linkWriterState});

  final NfcService? nfcService;
  final LinkWriterState? linkWriterState;

  @override
  State<NfcLinkWriterApp> createState() => _NfcLinkWriterAppState();
}

class _NfcLinkWriterAppState extends State<NfcLinkWriterApp> {
  late final _linkWriterState = widget.linkWriterState ?? LinkWriterState();
  late final _router = createAppRouter(_linkWriterState);
  late final _nfcService = widget.nfcService ?? NfcManagerNfcService();

  @override
  void dispose() {
    _router.dispose();
    if (widget.linkWriterState == null) {
      _linkWriterState.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _linkWriterState),
        Provider<NfcService>.value(value: _nfcService),
      ],
      child: MaterialApp.router(
        title: 'NFC Link Manager',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: _router,
      ),
    );
  }
}
