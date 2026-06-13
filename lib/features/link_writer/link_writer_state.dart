import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/utils/url_normalizer.dart';
import 'models/link_type.dart';
import 'models/nfc_read_result.dart';
import 'models/nfc_tag_info.dart';
import 'models/nfc_verify_result.dart';
import 'models/nfc_write_result.dart';
import 'models/url_draft.dart';
import 'services/recent_url_store.dart';

final class LinkWriterState extends ChangeNotifier {
  LinkWriterState({RecentUrlStore? recentUrlStore})
    : _recentUrlStore =
          recentUrlStore ?? const SharedPreferencesRecentUrlStore() {
    unawaited(loadRecentUrl());
  }

  final RecentUrlStore _recentUrlStore;

  LinkType? _selectedLinkType;
  UrlDraft? _draft;
  NfcWriteResult? _writeResult;
  NfcVerifyResult? _verifyResult;
  NfcReadResult? _readResult;
  NfcTagInfo? _checkedTagInfo;
  String? _recentUrl;

  LinkType? get selectedLinkType => _selectedLinkType;
  UrlDraft? get draft => _draft;
  NfcWriteResult? get writeResult => _writeResult;
  NfcVerifyResult? get verifyResult => _verifyResult;
  NfcReadResult? get readResult => _readResult;
  NfcTagInfo? get checkedTagInfo => _checkedTagInfo;
  String? get recentUrl => _recentUrl;

  Future<void> loadRecentUrl() async {
    final String? storedRecentUrl;
    try {
      storedRecentUrl = await _recentUrlStore.loadRecentUrl();
    } catch (_) {
      return;
    }

    final nextRecentUrl =
        storedRecentUrl != null && UrlNormalizer.isValidHttpUrl(storedRecentUrl)
            ? storedRecentUrl
            : null;

    if (_recentUrl == nextRecentUrl) {
      return;
    }

    _recentUrl = nextRecentUrl;
    notifyListeners();
  }

  void selectLinkType(LinkType linkType) {
    _selectedLinkType = linkType;
    _draft = null;
    _clearNfcResults();
    notifyListeners();
  }

  void setDraft(UrlDraft draft) {
    _selectedLinkType = draft.linkType;
    _draft = draft;
    _clearNfcResults();
    _rememberRecentUrl(draft);
    notifyListeners();
  }

  void setWriteResult(NfcWriteResult result) {
    _writeResult = result;
    notifyListeners();
  }

  void setVerifyResult(NfcVerifyResult result) {
    _verifyResult = result;
    notifyListeners();
  }

  void setReadResult(NfcReadResult result) {
    _readResult = result;
    notifyListeners();
  }

  void setCheckedTagInfo(NfcTagInfo tagInfo) {
    _checkedTagInfo = tagInfo;
    notifyListeners();
  }

  void clear() {
    _selectedLinkType = null;
    _draft = null;
    _clearNfcResults();
    notifyListeners();
  }

  Future<void> clearRecentUrl() async {
    if (_recentUrl != null) {
      _recentUrl = null;
      notifyListeners();
    }

    try {
      await _recentUrlStore.clearRecentUrl();
    } catch (_) {
      return;
    }
  }

  void _clearNfcResults() {
    _writeResult = null;
    _verifyResult = null;
    _readResult = null;
    _checkedTagInfo = null;
  }

  void _rememberRecentUrl(UrlDraft draft) {
    if (!draft.isValid || !UrlNormalizer.isValidHttpUrl(draft.normalizedUrl)) {
      return;
    }

    _recentUrl = draft.normalizedUrl;
    unawaited(_saveRecentUrl(draft.normalizedUrl));
  }

  Future<void> _saveRecentUrl(String url) async {
    try {
      await _recentUrlStore.saveRecentUrl(url);
    } catch (_) {
      return;
    }
  }
}
