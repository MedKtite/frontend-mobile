/// Outbound store links for catalog books we can't serve in-app (buy-to-read).
/// Pure URL builders — opening them is the caller's job (url_launcher).
///
/// Affiliate note: set [amazonAssociatesTag] once the Amazon Associates
/// account exists (e.g. 'marginalia-21'); empty = plain non-affiliate link.
/// Kobo runs its program through Rakuten — that wrapper can be added around
/// [koboUrl] later without touching call sites.
library;

import '../../models/catalog_book.dart';

/// Marginalia's public affiliate storefront.
final Uri bookshopStorefrontUrl =
    Uri.https('bookshop.org', '/shop/Marginalia');

/// Set to your Amazon Associates tag once the account exists.
const String amazonAssociatesTag = '';

/// Amazon search deep-link. ISBN-13 pins the exact edition; falls back to
/// title + author. (`/dp/` needs an ISBN-10/ASIN, so search is the reliable
/// route — and it carries the affiliate tag just the same.)
Uri amazonUrl(CatalogBook b) {
  final k = b.isbn13 ?? '${b.title} ${b.author ?? ''}'.trim();
  return Uri.https('www.amazon.com', '/s', {
    'k': k,
    'i': 'stripbooks',
    if (amazonAssociatesTag.isNotEmpty) 'tag': amazonAssociatesTag,
  });
}

/// Kobo search deep-link — Kobo sells DRM-free/Adobe-DRM EPUBs, which (unlike
/// Kindle files) users can often upload back into Marginalia.
Uri koboUrl(CatalogBook b) {
  final q = b.isbn13 ?? '${b.title} ${b.author ?? ''}'.trim();
  return Uri.https('www.kobo.com', '/search', {'query': q});
}
