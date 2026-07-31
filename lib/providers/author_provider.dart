import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog_book.dart';
import '../services/backend/catalog_service.dart';

/// Author surfaces:
/// - Top authors + portraits: nightly snapshot served from our backend/DB.
/// - Author profile enrichment: Wikipedia, loaded only after opening a profile.
/// - An author's books: our backend catalog search.

typedef TopAuthor = ({String name, String? imageUrl, int downloads});

typedef AuthorDetails = ({
  String? tagline, // e.g. "English novelist" (Wikipedia short description)
  String? bio, // Wikipedia extract paragraph
  String? imageUrl,
  List<CatalogBook> books,
});

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

/// One fast DB-backed request; external enrichment happens in the nightly
/// Python batch, never while Home is loading.
final topAuthorsProvider = FutureProvider<List<TopAuthor>>((ref) async {
  final authors = await ref.watch(catalogServiceProvider).topAuthors(limit: 8);
  return [
    for (final author in authors)
      (
        name: author.name,
        imageUrl: author.imageUrl,
        downloads: author.downloadCount,
      ),
  ];
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
