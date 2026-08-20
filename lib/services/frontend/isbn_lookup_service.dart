import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../models/catalog_book.dart';

final isbnLookupServiceProvider = Provider<IsbnLookupService>((ref) {
  return IsbnLookupService();
});

/// Service for looking up book metadata via ISBN-10 or ISBN-13 from
/// Google Books API with Open Library API as fallback.
class IsbnLookupService {
  final http.Client _client;

  IsbnLookupService({http.Client? client}) : _client = client ?? http.Client();

  /// Cleans and validates an ISBN string (removes hyphens, spaces).
  static String cleanIsbn(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9X]', caseSensitive: false), '').trim();
  }

  /// Looks up book metadata by ISBN. Returns a [CatalogBook] with populated
  /// metadata, or null if no matching book is found.
  Future<CatalogBook?> lookup(String rawIsbn) async {
    final isbn = cleanIsbn(rawIsbn);
    if (isbn.length != 10 && isbn.length != 13) {
      return null;
    }

    // 1. Try Google Books API first
    try {
      final googleBook = await _lookupGoogleBooks(isbn);
      if (googleBook != null) {
        return googleBook;
      }
    } catch (e) {
      debugPrint('Google Books ISBN lookup error: $e');
    }

    // 2. Fallback to Open Library API
    try {
      final openLibBook = await _lookupOpenLibrary(isbn);
      if (openLibBook != null) {
        return openLibBook;
      }
    } catch (e) {
      debugPrint('Open Library ISBN lookup error: $e');
    }

    return null;
  }

  Future<CatalogBook?> _lookupGoogleBooks(String isbn) async {
    final uri = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&maxResults=1',
    );
    final response = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final totalItems = (data['totalItems'] as num?)?.toInt() ?? 0;
    if (totalItems == 0) return null;

    final items = data['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) return null;

    final first = items.first as Map<String, dynamic>;
    final googleId = first['id'] as String?;
    final info = first['volumeInfo'] as Map<String, dynamic>? ?? {};

    final title = info['title'] as String? ?? 'Untitled';
    final authorsList = (info['authors'] as List<dynamic>?)?.cast<String>();
    final author = authorsList?.join(', ');
    final publisher = info['publisher'] as String?;
    final publishedDate = info['publishedDate'] as String?;
    int? publishedYear;
    if (publishedDate != null && publishedDate.length >= 4) {
      publishedYear = int.tryParse(publishedDate.substring(0, 4));
    }
    final pageCount = (info['pageCount'] as num?)?.toInt();
    final description = info['description'] as String?;
    final imageLinks = info['imageLinks'] as Map<String, dynamic>?;
    String? thumbnailUrl =
        imageLinks?['thumbnail'] as String? ??
        imageLinks?['smallThumbnail'] as String?;
    if (thumbnailUrl != null && thumbnailUrl.startsWith('http://')) {
      thumbnailUrl = thumbnailUrl.replaceFirst('http://', 'https://');
    }
    final avgRating = (info['averageRating'] as num?)?.toDouble();
    final ratingsCount = (info['ratingsCount'] as num?)?.toInt();

    return CatalogBook(
      title: title,
      author: author,
      source: 'GOOGLE',
      googleId: googleId,
      publisher: publisher,
      publishedYear: publishedYear,
      isbn13: isbn,
      pageCount: pageCount,
      description: description,
      thumbnailUrl: thumbnailUrl,
      averageRating: avgRating,
      ratingsCount: ratingsCount,
    );
  }

  Future<CatalogBook?> _lookupOpenLibrary(String isbn) async {
    final key = 'ISBN:$isbn';
    final uri = Uri.parse(
      'https://openlibrary.org/api/books?bibkeys=$key&format=json&jscmd=data',
    );
    final response = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (!data.containsKey(key)) return null;

    final bookData = data[key] as Map<String, dynamic>;
    final title = bookData['title'] as String? ?? 'Untitled';

    final authorsList = bookData['authors'] as List<dynamic>?;
    final authorNames =
        authorsList
            ?.map((a) => (a as Map<String, dynamic>)['name'] as String?)
            .whereType<String>()
            .toList();
    final author = authorNames?.join(', ');

    final publishDate = bookData['publish_date'] as String?;
    int? publishedYear;
    if (publishDate != null) {
      final match = RegExp(r'\b(\d{4})\b').firstMatch(publishDate);
      if (match != null) {
        publishedYear = int.tryParse(match.group(1)!);
      }
    }

    final pageCount = (bookData['number_of_pages'] as num?)?.toInt();
    final cover = bookData['cover'] as Map<String, dynamic>?;
    final thumbnailUrl =
        cover?['medium'] as String? ?? cover?['large'] as String?;

    return CatalogBook(
      title: title,
      author: author,
      source: 'OPEN_LIBRARY',
      isbn13: isbn,
      pageCount: pageCount,
      publishedYear: publishedYear,
      thumbnailUrl: thumbnailUrl,
    );
  }
}
