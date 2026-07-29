import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

class ReaderPackage {
  const ReaderPackage({
    required this.title,
    required this.author,
    required this.totalCharacters,
    required this.chapters,
    required this.assets,
  });

  final String? title;
  final String? author;
  final int totalCharacters;
  final List<ReaderChapter> chapters;
  final Map<String, Uint8List> assets;

  static ReaderPackage fromBytes(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final files = <String, List<int>>{};
    for (final file in archive.files) {
      if (file.isFile) files[file.name] = file.content as List<int>;
    }
    final manifest =
        jsonDecode(utf8.decode(files['manifest.json'] ?? const []))
            as Map<String, dynamic>;
    final chapters = <ReaderChapter>[];
    for (final item in (manifest['chapters'] as List<dynamic>? ?? const [])) {
      final entry = item as Map<String, dynamic>;
      final raw = files[entry['file'] as String];
      if (raw == null) continue;
      chapters.add(
        ReaderChapter.fromJson(
          jsonDecode(utf8.decode(raw)) as Map<String, dynamic>,
        ),
      );
    }
    final assets = <String, Uint8List>{};
    for (final entry in files.entries) {
      if (entry.key.startsWith('assets/')) {
        assets[entry.key] = Uint8List.fromList(entry.value);
      }
    }
    return ReaderPackage(
      title: manifest['title'] as String?,
      author: manifest['author'] as String?,
      totalCharacters: (manifest['totalCharacters'] as num?)?.toInt() ?? 0,
      chapters: chapters,
      assets: assets,
    );
  }
}

class ReaderChapter {
  const ReaderChapter({
    required this.id,
    required this.title,
    required this.blocks,
  });

  final String id;
  final String title;
  final List<ReaderBlock> blocks;

  factory ReaderChapter.fromJson(Map<String, dynamic> json) => ReaderChapter(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    blocks: (json['blocks'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ReaderBlock.fromJson)
        .toList(growable: false),
  );
}

class ReaderBlock {
  const ReaderBlock({
    required this.id,
    required this.type,
    this.text = '',
    this.asset,
    this.alt,
    this.rows = const [],
  });

  final String id;
  final String type;
  final String text;
  final String? asset;
  final String? alt;
  final List<List<String>> rows;

  factory ReaderBlock.fromJson(Map<String, dynamic> json) => ReaderBlock(
    id: json['id'] as String,
    type: json['type'] as String? ?? 'paragraph',
    text: json['text'] as String? ?? '',
    asset: json['asset'] as String?,
    alt: json['alt'] as String?,
    rows: (json['rows'] as List<dynamic>? ?? const [])
        .map(
          (row) => (row as List<dynamic>)
              .map((cell) => '$cell')
              .toList(growable: false),
        )
        .toList(growable: false),
  );
}
