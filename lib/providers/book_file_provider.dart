import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../services/backend/book_service.dart';

/// Identifies a downloadable book file: its id and format (epub|pdf|m4b|mp3).
typedef BookFileRef = ({String id, String format});

/// Resolves a readable book to a local [File], downloading the uploaded file
/// from its presigned URL on first open and caching it under
/// `<appDocuments>/books/<id>.<format>`. Subsequent opens are offline.
///
/// The download uses a bare [Dio] (no auth cookies sent to S3). The presigned
/// URL expires, so we cache the bytes, never the URL. autoDispose keeps the
/// provider out of the cache once the reader closes (the file on disk stays).
final bookFileProvider =
    FutureProvider.autoDispose.family<File, BookFileRef>((ref, key) async {
  final docs = await getApplicationDocumentsDirectory();
  final booksDir = Directory('${docs.path}/books');
  if (!booksDir.existsSync()) booksDir.createSync(recursive: true);

  final file = File('${booksDir.path}/${key.id}.${key.format}');
  if (file.existsSync() && file.lengthSync() > 0) return file;

  final dl = await ref.watch(bookServiceProvider).downloadUrl(key.id);

  final raw = Dio();
  try {
    final res = await raw.get<List<int>>(
      dl.downloadUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    await file.writeAsBytes(res.data ?? const [], flush: true);
  } finally {
    raw.close();
  }
  return file;
});
