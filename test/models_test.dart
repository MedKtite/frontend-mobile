import 'package:flutter_test/flutter_test.dart';

import 'package:marginalia/models/book.dart';
import 'package:marginalia/models/catalog_book.dart';
import 'package:marginalia/models/highlight.dart';
import 'package:marginalia/models/user.dart';

/// Locks the JSON contract against the real backend DTOs. The widget smoke
/// tests use mocked repositories and never exercise `fromJson`, so a field/type
/// mismatch (the most likely real-world breakage) would slip past them — these
/// catch it. Payloads below are the actual shapes pulled from the running API.
void main() {
  test('Book.fromJson — real BookResponse (NON_NULL omits absent fields)', () {
    // Verbatim from GET /me/books on the running backend.
    final book = Book.fromJson(const {
      'id': 'ff3800da-173f-4f8a-91fc-f6779bdce6ca',
      'title': 'Bluets',
      'author': 'Maggie Nelson',
      'format': 'physical',
      'status': 'reading',
      'coverDominantColor': '#34507A',
      'createdAt': '2026-06-17T13:41:22Z',
      'updatedAt': '2026-06-17T13:41:22Z',
    });

    expect(book.title, 'Bluets');
    expect(book.author, 'Maggie Nelson');
    expect(book.coverDominantColor, '#34507A');
    expect(book.status, 'reading');
    expect(book.progressPct, isNull); // omitted when null — must not throw
    expect(book.lastOpenedAt, isNull);
  });

  test('Book.fromJson — numeric progressPct parses to double', () {
    final book = Book.fromJson(const {
      'id': 'b1',
      'title': 'On Photography',
      'format': 'm4b',
      'status': 'listening',
      'progressPct': 72.5,
      'pageCount': 200,
      'durationSec': 3600,
    });

    expect(book.progressPct, 72.5);
    expect(book.pageCount, 200);
    expect(book.durationSec, 3600);
  });

  test('Highlight.fromJson — text highlight', () {
    final h = Highlight.fromJson(const {
      'id': 'h1',
      'bookId': 'b1',
      'passageText': 'fallen in love with a color',
      'textChapterRef': 'p. 1',
      'colorTag': 'curious',
      'createdAt': '2026-06-05T10:00:00Z',
    });

    expect(h.passageText, 'fallen in love with a color');
    expect(h.colorTag, 'curious');
    expect(h.bookId, 'b1');
  });

  test('CatalogBook.fromJson — CatalogVolumeResponse shape', () {
    final c = CatalogBook.fromJson(const {
      'googleId': 'abc123',
      'title': 'The Overstory',
      'author': 'Richard Powers',
      'publisher': 'W. W. Norton',
      'publishedYear': 2018,
      'isbn13': '9780393635522',
      'pageCount': 502,
      'thumbnailUrl': 'https://books.google.com/cover.jpg',
    });

    expect(c.title, 'The Overstory');
    expect(c.author, 'Richard Powers');
    expect(c.isbn13, '9780393635522');
    expect(c.publishedYear, 2018);
    expect(c.pageCount, 502);
  });

  test('User.fromJson — real UserResponse uses authProvider + createdAt', () {
    // Verbatim from POST /auth/register on the running backend.
    final u = User.fromJson(const {
      'authProvider': 'password',
      'createdAt': '2026-06-17T13:40:42Z',
      'displayName': 'Probe Reader',
      'email': 'probe@example.com',
      'emailVerified': false,
      'id': '878f7491-90a0-4284-ba4f-53000c635760',
      'timezone': 'UTC',
    });

    expect(u.authProvider, 'password');
    expect(u.createdAt, '2026-06-17T13:40:42Z');
    expect(u.displayName, 'Probe Reader');
    expect(u.shortName, isNull); // omitted → fallbacks must handle
    expect(u.avatarInitial, isNull);
  });
}
