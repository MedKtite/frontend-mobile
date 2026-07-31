import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../core/dio_client.dart';
import '../services/backend/book_service.dart';

/// Identifies a downloadable book file: its id and format (reader-v1|epub|pdf|m4b|mp3).
typedef BookFileRef = ({String id, String format});
typedef ReadableBookFile = ({File file, String format});

/// Remove every cached representation of a book (original or derived reader
/// copy). The backend remains the source of truth; this only clears device
/// files after a successful DELETE.
Future<void> deleteCachedBookFiles(String bookId) async {
  final docs = await getApplicationDocumentsDirectory();
  final booksDir = Directory('${docs.path}/books');
  if (!booksDir.existsSync()) return;

  await for (final entity in booksDir.list()) {
    if (entity is! File) continue;
    final name = entity.path.split(Platform.pathSeparator).last;
    if (name.startsWith('$bookId.')) {
      try {
        await entity.delete();
      } on FileSystemException {
        // Server deletion already succeeded; stale cache cleanup is best effort.
      }
    }
  }
}

/// Resolves a readable book to a local [File], downloading the uploaded file
/// from its presigned URL on first open and caching it under
/// `<appDocuments>/books/<id>.<format>`. Subsequent opens are offline.
///
/// The download uses a bare [Dio] (no auth cookies sent to S3). The presigned
/// URL expires, so we cache the bytes, never the URL. autoDispose keeps the
/// provider out of the cache once the reader closes (the file on disk stays).
final bookFileProvider = FutureProvider.autoDispose
    .family<ReadableBookFile, BookFileRef>((ref, key) async {
      final docs = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${docs.path}/books');
      if (!booksDir.existsSync()) booksDir.createSync(recursive: true);

      // A first open can enqueue Python Gutenberg processing. Keep polling the
      // backend while that shared reader-v1 package is being prepared.
      ({String downloadUrl, String format})? dl;
      for (var attempt = 0; attempt < 15; attempt++) {
        try {
          dl = await ref.watch(bookServiceProvider).readingDownloadUrl(key.id);
          break;
        } on ApiError catch (error) {
          if (error.status != 404 || attempt == 14) rethrow;
          await Future<void>.delayed(
            Duration(milliseconds: 750 + (attempt * 100)),
          );
        }
      }
      final download = dl!;
      final readableFormat = download.format;
      final file = File(
        '${booksDir.path}/${key.id}.reading-v5.$readableFormat',
      );
      if (file.existsSync() && file.lengthSync() > 0) {
        return (file: file, format: readableFormat);
      }

      final raw = Dio();
      try {
        final res = await raw.get<List<int>>(
          download.downloadUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        await file.writeAsBytes(res.data ?? const [], flush: true);
      } finally {
        raw.close();
      }
      return (file: file, format: readableFormat);
    });
