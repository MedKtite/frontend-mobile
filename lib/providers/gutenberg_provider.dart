import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Thrown when a title isn't in Project Gutenberg's catalog (e.g. in-copyright) —
/// the reader maps this to "upload your copy" rather than a hard error.
class GutenbergNotFound implements Exception {
  const GutenbergNotFound();
}

typedef GutenbergRef = ({String id, String title, String? author});

/// EPUB download progress (0–1) for [gutenbergEpubProvider], keyed by book id.
/// Stays 0 while still searching Gutendex; driven by the download's byte counts.
final gutenbergProgressProvider =
    StateProvider.autoDispose.family<double, String>((ref, bookId) => 0);

/// Finds a public-domain title on Project Gutenberg (via the open Gutendex API)
/// by title + author, downloads its clean reflowable EPUB, and caches it at
/// `<appDocs>/books/<id>.gutenberg.epub`. Reuses the `_EpubReader` render path,
/// so a catalog classic reads as crisp serif text — not scanned page images.
///
/// Prefers Gutenberg's **no-images** EPUB (text only — ~0.5 MB vs tens of MB for
/// the illustrated build), so the reader opens fast; falls back to the format
/// Gutendex advertised. External hosts → a bare [Dio] (no auth cookies). Throws
/// [GutenbergNotFound] when there's no free EPUB match.
final gutenbergEpubProvider =
    FutureProvider.autoDispose.family<File, GutenbergRef>((ref, key) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}/books');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  final file = File('${dir.path}/${key.id}.gutenberg.epub');
  if (file.existsSync() && file.lengthSync() > 0) return file;

  void reportProgress(double v) =>
      ref.read(gutenbergProgressProvider(key.id).notifier).state =
          v.clamp(0.0, 1.0);
  reportProgress(0);

  final dio = Dio();
  try {
    // 1) Match the book on Gutenberg by title + author.
    final query = [key.title, key.author]
        .where((s) => s != null && s.trim().isNotEmpty)
        .join(' ');
    final search = await dio.get<Map<String, dynamic>>(
      'https://gutendex.com/books/',
      queryParameters: {'search': query},
    );
    final results = (search.data?['results'] as List?) ?? const [];

    String? epubUrl;
    for (final r in results) {
      final formats = (r as Map)['formats'];
      if (formats is Map) {
        final url = formats['application/epub+zip'];
        if (url is String && url.isNotEmpty) {
          epubUrl = url;
          break;
        }
      }
    }
    if (epubUrl == null) throw const GutenbergNotFound();

    // 2) Download — try the lightweight no-images build first.
    final id = RegExp(r'ebooks/(\d+)').firstMatch(epubUrl)?.group(1);
    final candidates = <String>[
      if (id != null) 'https://www.gutenberg.org/ebooks/$id.epub.noimages',
      epubUrl,
    ];

    for (final url in candidates) {
      try {
        final res = await dio.get<List<int>>(
          url,
          onReceiveProgress: (received, total) {
            if (total > 0) reportProgress(received / total);
          },
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: const Duration(seconds: 120),
          ),
        );
        final bytes = res.data ?? const [];
        // An EPUB is a ZIP — it must start with the "PK" signature; anything
        // else (an HTML gate / 404 page) we skip and try the next candidate.
        if (bytes.length > 2 && bytes[0] == 0x50 && bytes[1] == 0x4B) {
          await file.writeAsBytes(bytes, flush: true);
          return file;
        }
      } on DioException {
        // try the next candidate
      }
    }
    throw const GutenbergNotFound();
  } finally {
    dio.close();
  }
});
