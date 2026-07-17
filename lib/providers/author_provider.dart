import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog_book.dart';
import '../services/backend/catalog_service.dart';
import 'trending_provider.dart';

/// Author surfaces, no backend/DB required:
/// - Top authors: aggregated from Gutendex's most-downloaded books.
/// - Portrait / tagline / bio: Wikipedia's public summary API.
/// - An author's books: Gutendex search (all readable in-app).

typedef TopAuthor = ({String name, String? imageUrl, int downloads});

typedef AuthorDetails = ({
  String? tagline, // e.g. "English novelist" (Wikipedia short description)
  String? bio, // Wikipedia extract paragraph
  String? imageUrl,
  List<CatalogBook> books,
});

/// Gutendex lists authors as "Last, First" — flip to display order.
String _displayAuthor(String raw) {
  final parts = raw.split(', ');
  return parts.length == 2 ? '${parts[1]} ${parts[0]}' : raw;
}

Future<Map<String, dynamic>?> _wikiSummary(Dio dio, String name) async {
  try {
    final res = await dio.get<Map<String, dynamic>>(
      'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(name)}',
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    return res.data;
  } on DioException {
    return null; // no article / offline — surfaces hide what's missing
  }
}

/// Most-downloaded Gutenberg authors, with Wikipedia portraits. One fetch per
/// session (non-autoDispose) — the ranking barely moves.
final topAuthorsProvider = FutureProvider<List<TopAuthor>>((ref) async {
  final results = await ref.watch(popularGutenbergResultsProvider.future);
  final dio = Dio();
  try {
    final downloadsByAuthor = <String, int>{};
    for (final r in results) {
      final authors = r['authors'];
      if (authors is! List || authors.isEmpty) continue;
      final name = (authors.first as Map?)?['name'] as String?;
      if (name == null || name.isEmpty) continue;
      final display = _displayAuthor(name);
      downloadsByAuthor[display] =
          (downloadsByAuthor[display] ?? 0) +
          ((r['download_count'] as num?)?.toInt() ?? 0);
    }
    final ranked = downloadsByAuthor.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = ranked.take(8).toList();

    // Portraits in parallel, best-effort — a missing photo becomes initials.
    final portraits = await Future.wait(
      top.map((e) async {
        final s = await _wikiSummary(dio, e.key);
        return (s?['thumbnail'] as Map?)?['source'] as String?;
      }),
    );

    return [
      for (var i = 0; i < top.length; i++)
        (name: top[i].key, imageUrl: portraits[i], downloads: top[i].value),
    ];
  } finally {
    dio.close();
  }
});

/// Profile + bibliography for one author (keyed by display name).
///
/// Bio/portrait: Wikipedia. Books: OUR backend catalog search — the local
/// Gutenberg index answers instantly (direct Gutendex search proved too slow
/// from devices) and the Google layer adds in-copyright titles, so modern
/// authors get a bibliography too.
final authorDetailsProvider = FutureProvider.family<AuthorDetails, String>((
  ref,
  name,
) async {
  // Fire both in parallel; each is independently best-effort.
  final dio = Dio();
  final wikiF = _wikiSummary(dio, name);
  final booksF = ref
      .read(catalogServiceProvider)
      .search(name, limit: 30)
      .catchError((Object _) => const <CatalogBook>[]);

  final wiki = await wikiF;
  dio.close();
  final raw = await booksF;

  // The query matches titles too — keep only results this author wrote.
  final nameWords = name
      .toLowerCase()
      .split(RegExp(r'[^a-z]+'))
      .where((w) => w.length > 2)
      .toSet();
  bool byThisAuthor(CatalogBook c) {
    final a = (c.author ?? '').toLowerCase();
    return nameWords.any(a.contains);
  }

  final seen = <String>{};
  final books = [
    for (final c in raw)
      if (byThisAuthor(c) && seen.add(c.title.toLowerCase())) c,
  ];
  // Readable-in-app first, then the rest.
  books.sort((a, b) => (b.isReadable ? 1 : 0).compareTo(a.isReadable ? 1 : 0));

  return (
    tagline: wiki?['description'] as String?,
    bio: wiki?['extract'] as String?,
    imageUrl:
        ((wiki?['originalimage'] as Map?)?['source'] ??
                (wiki?['thumbnail'] as Map?)?['source'])
            as String?,
    books: books,
  );
});
