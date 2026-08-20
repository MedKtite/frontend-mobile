import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../widgets/share_import_sheet.dart';

/// Listens for system share intents (EPUB/PDF files, shared quotes) sent to Marginalia.
class SharingIntentService {
  SharingIntentService._();
  static final SharingIntentService instance = SharingIntentService._();

  StreamSubscription<List<SharedMediaFile>>? _intentSub;
  GlobalKey<NavigatorState>? _navigatorKey;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;

    // Listen to media shared while the app is running in memory
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      _handleSharedMedia,
      onError: (err) {
        debugPrint('[SharingIntent] Error receiving stream: $err');
      },
    );

    // Get media shared when the app was closed
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isNotEmpty) {
        _handleSharedMedia(files);
        ReceiveSharingIntent.instance.reset();
      }
    }).catchError((err) {
      debugPrint('[SharingIntent] Error getting initial media: $err');
    });
  }

  void _handleSharedMedia(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    final navContext = _navigatorKey?.currentContext;
    if (navContext == null) return;

    final first = files.first;
    final path = first.path;

    if (first.type == SharedMediaType.text) {
      showSharedQuoteSheet(navContext, quoteText: path);
    } else {
      final lower = path.toLowerCase();
      if (lower.endsWith('.epub') || lower.endsWith('.pdf')) {
        showSharedFileImportSheet(navContext, filePath: path);
      } else if (first.type == SharedMediaType.file) {
        // Fallback for file shares
        showSharedFileImportSheet(navContext, filePath: path);
      }
    }
  }

  void dispose() {
    _intentSub?.cancel();
  }
}
