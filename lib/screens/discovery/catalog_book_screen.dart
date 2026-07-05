import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/dio_client.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/utils/store_links.dart';
import '../../models/book_create_request.dart';
import '../../models/catalog_book.dart';
import '../../providers/book_description_provider.dart';
import '../../providers/library_provider.dart';
import '../../services/backend/book_service.dart';
import '../../services/backend/catalog_service.dart';
import '../../widgets/add_to_library_sheet.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/shelf_picker.dart';

/// Full catalog-book page: cover, metadata, rating, description — and the
/// action row that fits what we can offer. Public-domain (FULL) titles get
/// "Add to library" (readable in-app); everything else gets the store links
/// ("Get this book" is a feature, not an apology), a demand-logging request
/// button, and the upload-your-own hint.
class CatalogBookScreen extends ConsumerStatefulWidget {
  const CatalogBookScreen({super.key, required this.book});

  final CatalogBook book;

  @override
  ConsumerState<CatalogBookScreen> createState() => _CatalogBookScreenState();
}

class _CatalogBookScreenState extends ConsumerState<CatalogBookScreen> {
  bool _adding = false;
  bool _added = false;
  bool _requesting = false;
  bool _requested = false;

  CatalogBook get book => widget.book;

  Future<void> _openStore(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      showAppSnack(context, 'Could not open the store.',
          type: SnackType.error);
    }
  }

  /// FULL titles only — same flow as the library grid's + badge.
  Future<void> _addToLibrary() async {
    final shelf = await showShelfPicker(context);
    if (shelf == null || !mounted) return;
    setState(() => _adding = true);
    String? error;
    try {
      await ref.read(bookServiceProvider).create(
            BookCreateRequest(
              title: book.title,
              format: 'physical',
              status: shelf,
              author: book.author,
              googleId: book.googleId,
              isbn13: book.isbn13,
              pageCount: book.pageCount,
              publishedYear: book.publishedYear,
              publisher: book.publisher,
              coverUrl: book.thumbnailUrl,
            ),
          );
    } on ApiError catch (e) {
      error = e.message;
    }
    if (!mounted) return;
    setState(() {
      _adding = false;
      _added = error == null;
    });
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (error == null) {
      ref.invalidate(libraryBooksProvider);
      messenger.showSnackBar(
          appSnackBar('Added “${book.title}” to $shelf', SnackType.success));
    } else {
      messenger.showSnackBar(appSnackBar(error, SnackType.error));
    }
  }

  Future<void> _request() async {
    setState(() => _requesting = true);
    String? error;
    try {
      await ref.read(catalogServiceProvider).requestBook(book);
    } on ApiError catch (e) {
      error = e.message;
    }
    if (!mounted) return;
    setState(() {
      _requesting = false;
      _requested = error == null;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(appSnackBar(
          error ?? 'Request logged — requests guide which books we bring in next.',
          error == null ? SnackType.success : SnackType.error));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // Enrich on demand: description (all Gutenberg titles lack one), rating,
    // readers KPI (Gutendex downloads / Google ratings n), and pages/year
    // (Gutenberg has neither — a matching Google edition supplies them).
    final hasReads = book.downloadCount != null || book.ratingsCount != null;
    final needExtras = (book.description ?? '').isEmpty ||
        book.averageRating == null ||
        !hasReads ||
        book.pageCount == null ||
        book.publishedYear == null;
    final extras = needExtras
        ? ref
            .watch(bookExtrasProvider((
              gutenbergId: book.gutenbergId,
              googleId: book.googleId,
              title: book.title,
              author: book.author,
            )))
            .valueOrNull
        : null;
    final description = _clean(book.description ?? extras?.description);
    final rating = book.averageRating ?? extras?.rating;
    final reads = book.downloadCount ??
        extras?.downloads ??
        book.ratingsCount ??
        extras?.ratingsCount;
    final pages = book.pageCount ?? extras?.pageCount;
    final year = book.publishedYear ?? extras?.year;

    return Scaffold(
      // No top SafeArea: the tinted header owns the status-bar area (edge-to-
      // edge, reference layout) and pads its content past the system inset.
      // The header lives INSIDE the scroll view — it scrolls away with the
      // page rather than staying pinned.
      body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.accentSoft,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppRadii.xl)),
              ),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                MediaQuery.paddingOf(context).top + AppSpacing.sm,
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleIconButton(
                        icon: Icons.chevron_left,
                        onTap: () => context.pop(),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: (_adding || _added) ? null : _addToLibrary,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: Icon(
                            _added
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            size: 26,
                            color: _added ? colors.accent : colors.text2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Title + author on the left, cover on the right.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title1(colors.text),
                            ),
                            if (book.author != null &&
                                book.author!.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                book.author!,
                                style: AppTypography.subtitle(colors.text2),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      BookCover(
                        title: book.title,
                        author: book.author ?? '',
                        bg: colors.surface2,
                        fg: colors.text2,
                        coverUrl: proxiedCoverUrl(book.thumbnailUrl),
                        width: 110,
                      ),
                    ],
                  ),
                ],
              ),
            ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.xl,
                      AppSpacing.pageHorizontal,
                      AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _statsRow(colors,
                            rating: rating,
                            reads: reads,
                            pages: pages,
                            year: year),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xl),
                          Text('Description',
                              style: AppTypography.title3(colors.text)),
                          const SizedBox(height: AppSpacing.md),
                          Text(description,
                              style: AppTypography.bodySerif(colors.text2)),
                        ],
                        // Metadata-only titles keep the get/request/upload
                        // stack in the body; readable ones get the pinned CTA.
                        if (!book.isReadable) ...[
                          const SizedBox(height: AppSpacing.xl),
                          _storeActions(colors),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Pinned primary CTA (reference layout) — readable books only.
            // Bottom SafeArea here because the page no longer has a global one
            // (the header owns the status-bar area edge-to-edge).
            if (book.isReadable)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.sm,
                    AppSpacing.pageHorizontal,
                    AppSpacing.md,
                  ),
                  child: _readableActions(colors),
                ),
              ),
          ],
      ),
    );
  }

  /// Rating · readers · pages · year, as labeled stats (reference layout's
  /// KPI row). All values pre-merged from the catalog result + fetched extras.
  Widget _statsRow(AppColorsExtension colors,
      {double? rating, int? reads, int? pages, int? year}) {
    final stats = <Widget>[
      if (rating != null)
        _Stat(
          icon: Icons.star_rounded,
          tone: colors.gilt,
          value: rating.toStringAsFixed(1),
          label: 'Rating',
        ),
      if (reads != null)
        _Stat(
          icon: Icons.auto_stories_rounded,
          tone: colors.accent,
          value: _compact(reads),
          label: 'Readers',
        ),
      if (pages != null)
        _Stat(
          icon: Icons.menu_book_rounded,
          tone: colors.text3,
          value: '$pages',
          label: 'Pages',
        ),
      if (year != null)
        _Stat(
          icon: Icons.calendar_month_rounded,
          tone: colors.text3,
          value: '$year',
          label: 'Year',
        ),
    ];
    if (stats.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.xxl,
      runSpacing: AppSpacing.md,
      children: stats,
    );
  }

  /// 68421 → "68.4k" — KPI-style compact count.
  static String _compact(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  /// Google descriptions arrive with light HTML — strip tags, keep the text.
  String _clean(String? raw) => (raw ?? '')
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // ── FULL: readable in-app ─────────────────────────────────────────────

  Widget _readableActions(AppColorsExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: (_adding || _added) ? null : _addToLibrary,
          style: FilledButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: colors.bg,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.brMd),
          ),
          child: Text(
            _added
                ? 'In your library ✓'
                : _adding
                    ? 'Adding…'
                    : 'Add to library',
            style: AppTypography.label(colors.bg)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Public-domain classic — read and annotate it right here.',
          textAlign: TextAlign.center,
          style: AppTypography.caption(colors.text3),
        ),
      ],
    );
  }

  // ── METADATA_ONLY: buy · sample · request · upload ────────────────────

  Widget _storeActions(AppColorsExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('GET THIS BOOK', style: AppTypography.overline(colors.text3)),
        const SizedBox(height: AppSpacing.sm),
        _StoreTile(
          icon: Icons.shopping_bag_outlined,
          title: 'Buy on Amazon',
          subtitle: 'Paperback, hardcover or Kindle',
          onTap: () => _openStore(amazonUrl(book)),
        ),
        const SizedBox(height: AppSpacing.sm),
        _StoreTile(
          icon: Icons.book_outlined,
          title: 'Buy on Kobo',
          subtitle: 'EPUB — often uploadable to Marginalia',
          onTap: () => _openStore(koboUrl(book)),
        ),
        if (book.previewUrl != null) ...[
          const SizedBox(height: AppSpacing.xs),
          TextButton.icon(
            onPressed: () => _openStore(Uri.parse(book.previewUrl!)),
            icon: Icon(Icons.auto_stories_outlined,
                size: 18, color: colors.accent),
            label: Text('Read a free sample',
                style: AppTypography.label(colors.accent)),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton(
          onPressed: (_requesting || _requested) ? null : _request,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.border),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.brMd),
          ),
          child: Text(
            _requested ? 'Requested ✓' : 'Request this book',
            style: AppTypography.label(colors.text)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Every request guides which books we bring to Marginalia next.',
          textAlign: TextAlign.center,
          style: AppTypography.caption(colors.text3),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Already-own-it path: DRM-free EPUBs (Kobo, eBooks.com, Google Play)
        // can come home; Kindle files can't (DRM).
        InkWell(
          onTap: () => showAddToLibrarySheet(context),
          borderRadius: AppRadii.brMd,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: AppRadii.brMd,
            ),
            child: Row(
              children: [
                Icon(Icons.upload_file_outlined,
                    size: 22, color: colors.accent),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Already own it?',
                          style: AppTypography.label(colors.text)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Upload your EPUB to read and listen here.',
                        style: AppTypography.caption(colors.text2),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: colors.text3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Soft circular icon button (reference header style) — surface2 disc, ink glyph.
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface2,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, size: 22, color: colors.text),
        ),
      ),
    );
  }
}

/// One labeled stat: colored glyph + bold value on top, muted label beneath.
class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.tone,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color tone;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: tone),
            const SizedBox(width: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.label(colors.text)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTypography.caption(colors.text3)),
      ],
    );
  }
}

/// One store row: icon · name + hint · external-link glyph.
class _StoreTile extends StatelessWidget {
  const _StoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.brMd,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: AppRadii.brMd,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colors.accent),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.label(colors.text)
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: AppTypography.caption(colors.text2)),
                ],
              ),
            ),
            Icon(Icons.open_in_new, size: 16, color: colors.text3),
          ],
        ),
      ),
    );
  }
}
