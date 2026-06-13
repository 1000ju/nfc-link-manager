import 'package:flutter/foundation.dart';

import 'models/link_type.dart';
import 'models/url_draft.dart';

final class LinkWriterState extends ChangeNotifier {
  LinkType? _selectedLinkType;
  UrlDraft? _draft;

  LinkType? get selectedLinkType => _selectedLinkType;
  UrlDraft? get draft => _draft;

  void selectLinkType(LinkType linkType) {
    _selectedLinkType = linkType;
    _draft = null;
    notifyListeners();
  }

  void setDraft(UrlDraft draft) {
    _selectedLinkType = draft.linkType;
    _draft = draft;
    notifyListeners();
  }

  void clear() {
    _selectedLinkType = null;
    _draft = null;
    notifyListeners();
  }
}
