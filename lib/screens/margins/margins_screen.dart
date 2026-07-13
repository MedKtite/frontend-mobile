import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/dio_client.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/book.dart';
import '../../models/highlight.dart';
import '../../models/note.dart';
import '../../models/tag.dart' as models;
import '../../providers/annotations_provider.dart';
import '../../providers/library_provider.dart';
import '../../services/backend/highlight_service.dart';
import '../../services/backend/note_service.dart';
import '../../widgets/book_cover.dart';

/// Margins — the annotation hub (replaces the old Search tab; built from the
/// reference shot, no Figma frame yet). Everything the reader has written in
/// the margins, one feed:
///   header    "Margins" + passage/note counts
///   search    client-side filter over passages, notes, tags, book titles
///   tag chips All + one per tag (colored dot · name · count) — single select
///   type tabs All · Highlights · Notes · Saved + result count
///   feed      passage cards (tag dot · date · serif passage · nested notes ·
///             book footer with "In book →"), note cards for standalone notes
enum _Type {
  all('All'),
  highlights('Highlights'),
  notes('Notes'),
  saved('Saved');

  const _Type(this.label);
  final String label;
}

class MarginsScreen extends ConsumerStatefulWidget {
  const MarginsScreen({super.key});

  @override
  ConsumerState<MarginsScreen> createState() => _MarginsScreenState();
}

class _MarginsScreenState extends ConsumerState<MarginsScreen> {
  static const _pageSize = 10;

  final _searchController = TextEditingController();
  String _query = '';
  String? _tagId; // null = All
  _Type _type = _Type.all;
  int _page = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final highlightsAsync = _tagId == null
        ? ref.watch(allHighlightsProvider)
        : ref.watch(tagHighlightsProvider(_tagId!));
    final notesAsync = ref.watch(allNotesProvider);
    final tags = ref.watch(tagsProvider).valueOrNull ?? const [];
    final counts = ref.watch(tagCountsProvider).valueOrNull ?? const {};
    final books = ref.watch(libraryBooksProvider).valueOrNull ?? const <Book>[];
    final bookById = {for (final b in books) b.id: b};

    final highlights = highlightsAsync.valueOrNull;
    final notes = notesAsync.valueOrNull;

    final failed = highlightsAsync.hasError || notesAsync.hasError;
    final loading = !failed && (highlights == null || notes == null);

    // Totals for the header come from the unfiltered feed.
    final allHighlights = ref.watch(allHighlightsProvider).valueOrNull;

    final entries = (highlights == null || notes == null)
        ? const <_Entry>[]
        : _buildEntries(highlights, notes, bookById);
    final pageCount = (entries.length / _pageSize).ceil();
    final page = pageCount == 0 ? 0 : _page.clamp(0, pageCount - 1);
    final pageStart = page * _pageSize;
    final pageEntries = entries.skip(pageStart).take(_pageSize);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.md,
            AppSpacing.pageHorizontal,
            96, // clear the floating glass nav
          ),
          children: [
            Text('Margins', style: AppTypography.display(colors.text)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${_count(allHighlights?.length, 'passage')} · '
              '${_count(notes?.length, 'note')}',
              style: AppTypography.label(colors.text2),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _searchController,
              hint: 'Search tags, notes, passages…',
              search: true,
              prefixIcon: Icons.search,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() {
                _query = v.trim();
                _page = 0;
              }),
              onClear: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                  _page = 0;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _TagChip(
                    name: 'All',
                    dot: null,
                    count: null,
                    active: _tagId == null,
                    onTap: () => setState(() {
                      _tagId = null;
                      _page = 0;
                    }),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  for (final t in tags) ...[
                    _TagChip(
                      name: _capitalize(t.name),
                      dot: _tagColor(t),
                      count: counts[t.id] ?? 0,
                      active: t.id == _tagId,
                      onTap: () => setState(() {
                        _tagId = _tagId == t.id ? null : t.id;
                        _page = 0;
                      }),
                    ),
                    if (t != tags.last) const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                for (final t in _Type.values) ...[
                  _TypeTab(
                    label: t.label,
                    active: t == _type,
                    onTap: () => setState(() {
                      _type = t;
                      _page = 0;
                    }),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                ],
                const Spacer(),
                Text(
                  '${entries.length} ${entries.length == 1 ? 'result' : 'results'}',
                  style: AppTypography.caption(colors.text3),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (failed)
              _Message(
                icon: Icons.cloud_off_outlined,
                title: "Couldn't load your margins.",
                hint: 'Check your connection and try again.',
                action: OutlinedButton(
                  onPressed: () => refreshAnnotations(ref),
                  child: const Text('Try again'),
                ),
              )
            else if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (entries.isEmpty)
              _Message(
                icon: _type == _Type.saved
                    ? Icons.bookmark_outline
                    : Icons.format_quote_outlined,
                title: _type == _Type.saved
                    ? 'Nothing saved yet.'
                    : 'Nothing here yet.',
                hint: _type == _Type.saved
                    ? 'Tap the bookmark on any passage or note\nto keep it here.'
                    : 'Highlight a passage while reading\nand it lands in your margins.',
              )
            else
              for (final e in pageEntries)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: e.highlight != null
                      ? e.highlight!.audioStartSec != null
                          ? _AudioMomentCard(
                              highlight: e.highlight!,
                              notes: e.notes,
                              book: bookById[e.highlight!.bookId],
                            )
                          : _PassageCard(
                              highlight: e.highlight!,
                              notes: e.notes,
                              book: bookById[e.highlight!.bookId],
                            )
                      : _NoteCard(
                          note: e.notes.first,
                          book: bookById[e.notes.first.bookId],
                        ),
                ),
            if (pageCount > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _Pagination(
                  page: page,
                  pageCount: pageCount,
                  onPrevious: page == 0
                      ? null
                      : () => setState(() => _page = page - 1),
                  onNext: page == pageCount - 1
                      ? null
                      : () => setState(() => _page = page + 1),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _count(int? n, String noun) =>
      n == null ? '— ${noun}s' : '$n ${n == 1 ? noun : '${noun}s'}';

  /// Highlights (with their attached notes nested) + standalone notes,
  /// filtered by the type tab and the search query, newest first.
  List<_Entry> _buildEntries(
    List<Highlight> highlights,
    List<Note> notes,
    Map<String, Book> bookById,
  ) {
    final byHighlight = <String, List<Note>>{};
    final standalone = <Note>[];
    for (final n in notes) {
      if (n.highlightId != null) {
        byHighlight.putIfAbsent(n.highlightId!, () => []).add(n);
      } else {
        standalone.add(n);
      }
    }

    var entries = <_Entry>[
      if (_type != _Type.notes)
        for (final h in highlights)
          if (_type != _Type.saved || h.isSaved)
            _Entry(
              highlight: h,
              notes: byHighlight[h.id] ?? const [],
              sortKey: h.createdAt ?? '',
            ),
      if (_type == _Type.notes)
        // The Notes tab shows every note — attached and standalone alike —
        // but only for the selected tag's highlights when one is picked.
        for (final n in notes)
          if (_tagId == null || _matchesTag(n, highlights))
            _Entry(notes: [n], sortKey: n.createdAt ?? ''),
      if (_type == _Type.all && _tagId == null)
        for (final n in standalone)
          _Entry(notes: [n], sortKey: n.createdAt ?? ''),
      if (_type == _Type.saved)
        for (final n in notes)
          if (n.isSaved && (_tagId == null || _matchesTag(n, highlights)))
            _Entry(notes: [n], sortKey: n.createdAt ?? ''),
    ];

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      entries = entries.where((e) {
        final h = e.highlight;
        final book = bookById[h?.bookId ?? e.notes.first.bookId];
        return (h?.passageText ?? '').toLowerCase().contains(q) ||
            (h?.colorTag ?? '').toLowerCase().contains(q) ||
            e.notes.any((n) => n.bodyMd.toLowerCase().contains(q)) ||
            (book?.title ?? '').toLowerCase().contains(q);
      }).toList();
    }

    entries.sort((a, b) => b.sortKey.compareTo(a.sortKey));
    return entries;
  }

  /// A note matches the tag filter when it hangs off one of the (already
  /// tag-filtered) highlights.
  bool _matchesTag(Note n, List<Highlight> tagged) =>
      n.highlightId != null && tagged.any((h) => h.id == n.highlightId);
}

class _Entry {
  const _Entry({this.highlight, this.notes = const [], required this.sortKey});
  final Highlight? highlight;
  final List<Note> notes;
  final String sortKey;
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          color: colors.text,
          disabledColor: colors.text3,
          tooltip: 'Previous page',
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Page ${page + 1} of $pageCount',
          style: AppTypography.label(colors.text2),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          color: colors.text,
          disabledColor: colors.text3,
          tooltip: 'Next page',
        ),
      ],
    );
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Server tags carry their own hex; fall back to the token for system names.
Color _tagColor(models.Tag t) {
  final hex = t.colorHex;
  if (hex != null && hex.length >= 6) {
    final v = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    if (v != null) return Color(0xFF000000 | v);
  }
  return AppColors.forTag(t.name);
}

String _shortDate(String? iso) {
  final d = DateTime.tryParse(iso ?? '');
  return d == null ? '' : DateFormat('MMM dd').format(d.toLocal());
}

String _audioTime(double? seconds) {
  final duration = Duration(seconds: (seconds ?? 0).round());
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$secs' : '$minutes:$secs';
}

/// Chapter refs that are epub.js CFIs are machine cursors, not labels.
String? _readableRef(String? ref) {
  final r = ref?.trim() ?? '';
  if (r.isEmpty || r.startsWith('epubcfi') || r.startsWith('{')) return null;
  return r.length > 12 ? null : r;
}

// ─────────────────────────────────────────────────────────────── chips ──

/// Tag filter pill: optional colored dot · name · count. Active = ink-filled
/// (the reference shot's "All" chip).
class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.name,
    required this.dot,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String name;
  final Color? dot;
  final int? count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: active ? colors.text : colors.surface,
          borderRadius: AppRadii.brFull,
          border: Border.all(color: active ? colors.text : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              count == null ? name : '$name $count',
              style: AppTypography.label(active ? colors.bg : colors.text2)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Type filter: plain text, active gets an ink underline.
class _TypeTab extends StatelessWidget {
  const _TypeTab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? colors.text : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.label(active ? colors.text : colors.text3)
              .copyWith(fontWeight: active ? FontWeight.w600 : FontWeight.w500),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────── cards ──

/// An audio bookmark is visually distinct from a quoted text passage: it uses
/// a listening icon, timestamp, and soft accent surface, and opens the player.
class _AudioMomentCard extends ConsumerWidget {
  const _AudioMomentCard({
    required this.highlight,
    required this.notes,
    required this.book,
  });

  final Highlight highlight;
  final List<Note> notes;
  final Book? book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final tag = highlight.colorTag ?? 'revisit';
    final start = _audioTime(highlight.audioStartSec);
    final endSeconds = highlight.audioEndSec;
    final time = endSeconds != null && endSeconds > (highlight.audioStartSec ?? 0)
        ? '$start – ${_audioTime(endSeconds)}'
        : start;
    void open() => _openBook(
          context,
          ref,
          highlight.bookId,
          listening: true,
        );

    return GestureDetector(
      onTap: open,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.accentSoft,
          borderRadius: AppRadii.brLg,
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.headphones_rounded,
                    size: AppSpacing.xl,
                    color: colors.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AUDIO MOMENT',
                        style: AppTypography.overline(colors.accent)),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Container(
                          width: AppSpacing.sm,
                          height: AppSpacing.sm,
                          decoration: BoxDecoration(
                            color: AppColors.forTag(tag),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(_capitalize(tag),
                            style: AppTypography.caption(colors.text2)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(_shortDate(highlight.createdAt),
                    style: AppTypography.caption(colors.text3)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(time, style: AppTypography.title1(colors.text)),
            const SizedBox(height: AppSpacing.xs),
            Text('Listening bookmark',
                style: AppTypography.subtitle(colors.text2)),
            for (final note in notes) ...[
              const SizedBox(height: AppSpacing.md),
              _NoteBox(note: note),
            ],
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: colors.border),
            const SizedBox(height: AppSpacing.md),
            _BookFooter(
              book: book,
              locationRef: null,
              saved: highlight.isSaved,
              onOpenBook: open,
              onToggleSave: (saved) =>
                  _toggleHighlightSave(context, ref, saved),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleHighlightSave(
    BuildContext context,
    WidgetRef ref,
    bool saved,
  ) async {
    try {
      await ref
          .read(highlightServiceProvider)
          .setSaved(highlight.id, saved);
      refreshAnnotations(ref);
    } on ApiError catch (error) {
      if (context.mounted) {
        showAppSnack(context, error.message, type: SnackType.error);
      }
    }
  }
}

/// A passage card: tag dot + name · date, the passage in serif italic,
/// nested note boxes, then the book footer.
class _PassageCard extends ConsumerWidget {
  const _PassageCard({
    required this.highlight,
    required this.notes,
    required this.book,
  });

  final Highlight highlight;
  final List<Note> notes;
  final Book? book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final tag = highlight.colorTag ?? '';
    final tagTone = AppColors.forTag(tag);

    return _Card(
      onTap: () => _openBook(context, ref, highlight.bookId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: tagTone, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(tag.toUpperCase(),
                  style: AppTypography.overline(colors.text3)),
              const Spacer(),
              Text(_shortDate(highlight.createdAt),
                  style: AppTypography.caption(colors.text3)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            highlight.passageText ?? '',
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.serif(TextStyle(
              color: colors.text,
              fontSize: 16,
              height: 1.45,
              fontStyle: FontStyle.italic,
            )),
          ),
          for (final n in notes) ...[
            const SizedBox(height: AppSpacing.md),
            _NoteBox(note: n),
          ],
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: AppSpacing.md),
          _BookFooter(
            book: book,
            locationRef: _readableRef(highlight.textChapterRef),
            saved: highlight.isSaved,
            onOpenBook: () => _openBook(context, ref, highlight.bookId),
            onToggleSave: (v) => _toggleHighlightSave(context, ref, v),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleHighlightSave(
      BuildContext context, WidgetRef ref, bool v) async {
    try {
      await ref.read(highlightServiceProvider).setSaved(highlight.id, v);
      refreshAnnotations(ref);
    } on ApiError catch (e) {
      if (context.mounted) {
        showAppSnack(context, e.message, type: SnackType.error);
      }
    }
  }
}

/// A standalone note card (or a note under the Notes/Saved filters).
class _NoteCard extends ConsumerWidget {
  const _NoteCard({required this.note, required this.book});

  final Note note;
  final Book? book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    return _Card(
      onTap: () => _openBook(context, ref, note.bookId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sticky_note_2_outlined, size: 14, color: colors.text2),
              const SizedBox(width: AppSpacing.sm),
              Text('NOTE', style: AppTypography.overline(colors.text3)),
              const Spacer(),
              Text(_shortDate(note.createdAt),
                  style: AppTypography.caption(colors.text3)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            note.bodyMd,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(colors.text),
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: AppSpacing.md),
          _BookFooter(
            book: book,
            locationRef: null,
            saved: note.isSaved,
            onOpenBook: () => _openBook(context, ref, note.bookId),
            onToggleSave: (v) => _toggleNoteSave(context, ref, v),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleNoteSave(
      BuildContext context, WidgetRef ref, bool v) async {
    try {
      await ref.read(noteServiceProvider).setSaved(note.id, v);
      refreshAnnotations(ref);
    } on ApiError catch (e) {
      if (context.mounted) {
        showAppSnack(context, e.message, type: SnackType.error);
      }
    }
  }
}

/// The gilt-edged note box nested inside a passage card.
class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Grey left edge inside the clip — a one-sided Border can't share a
    // BoxDecoration with a borderRadius (Flutter asserts).
    return ClipRRect(
      borderRadius: AppRadii.brSm,
      child: ColoredBox(
        color: colors.surface,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: colors.text3),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.sticky_note_2_outlined,
                          size: 14, color: colors.text2),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(note.bodyMd,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption(colors.text)
                                .copyWith(fontSize: 13, height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// cover thumb · title · location — bookmark ribbon · "In book →".
class _BookFooter extends StatelessWidget {
  const _BookFooter({
    required this.book,
    required this.locationRef,
    required this.saved,
    required this.onOpenBook,
    required this.onToggleSave,
  });

  final Book? book;
  final String? locationRef;
  final bool saved;
  final VoidCallback onOpenBook;
  final ValueChanged<bool> onToggleSave;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        if (book != null) ...[
          BookCover(
            title: book!.title,
            author: book!.author ?? '',
            bg: coverColorFromHex(book!.coverDominantColor),
            fg: coverFgFor(book!.coverDominantColor),
            coverUrl: proxiedCoverUrl(book!.coverUrl),
            width: 20,
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        // ONE flex child owning all slack — a Flexible title next to a
        // Spacer splits the leftover 50/50, so short titles left the
        // "In book" cluster floating off the right edge.
        Expanded(
          child: book == null
              ? Text('Removed from library',
                  style: AppTypography.caption(colors.text3))
              : Row(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onOpenBook,
                        child: Text(
                          book!.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label(colors.text).copyWith(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                    if (locationRef != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(locationRef!,
                          style: AppTypography.caption(colors.text3)),
                    ],
                  ],
                ),
        ),
        const SizedBox(width: AppSpacing.md),
        GestureDetector(
          onTap: () => onToggleSave(!saved),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Icon(
              saved ? Icons.bookmark : Icons.bookmark_outline,
              size: 18,
              color: saved ? colors.accent : colors.text3,
            ),
          ),
        ),
        if (book != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text('In book', style: AppTypography.caption(colors.text2)),
          Icon(Icons.chevron_right, size: 14, color: colors.text3),
        ],
      ],
    );
  }
}

void _openBook(
  BuildContext context,
  WidgetRef ref,
  String bookId, {
  bool listening = false,
}) {
  final book = (ref.read(libraryBooksProvider).valueOrNull ?? const <Book>[])
      .where((b) => b.id == bookId)
      .firstOrNull;
  if (book == null) {
    showAppSnack(context, 'That book is no longer in your library.',
        type: SnackType.warning);
    return;
  }
  context.push(
    listening ? Routes.listeningPath(bookId) : Routes.readingPath(bookId),
    extra: book,
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadii.brLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.hint,
    this.action,
  });

  final IconData icon;
  final String title;
  final String hint;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(icon, size: 36, color: colors.text3),
          const SizedBox(height: AppSpacing.lg),
          Text(title,
              textAlign: TextAlign.center,
              style: AppTypography.title3(colors.text)),
          const SizedBox(height: AppSpacing.sm),
          Text(hint,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(colors.text2)),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}
