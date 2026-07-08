import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/dio_client.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/highlight.dart';
import '../../models/note.dart';
import '../../models/search_hit.dart';
import '../../models/search_response.dart';
import '../../models/tag.dart' as models;
import '../../providers/annotations_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/search_provider.dart';
import '../../services/backend/highlight_service.dart';
import '../../services/backend/note_service.dart';
import '../../widgets/book_cover.dart';

/// The Search hub (Figma 96:230 for the Search tab). Four top-level tabs:
///   Search — full-text search across the library (scope chips per Figma)
///   Tags   — browse every tag and its highlights, no query needed
///   Notes  — all notes, newest first
///   Saved  — bookmarked highlights & notes (the ribbon icon on each card)
enum _Tab {
  search('Search'),
  tags('Tags'),
  notes('Notes'),
  saved('Saved');

  const _Tab(this.label);
  final String label;
}

enum _Scope {
  all('All', null),
  books('Books', 'book'),
  highlights('Highlights', 'highlight'),
  notes('Notes', 'note'),
  tags('Tags', 'tag');

  const _Scope(this.label, this.hitType);
  final String label;
  final String? hitType;

  bool matches(SearchHit h) => hitType == null || h.type == hitType;
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  _Tab _tab = _Tab.search;
  _Scope _scope = _Scope.all;
  final List<String> _recent = [];

  static const _suggestions = [
    'Try a word from a passage',
    'Try a book title',
    'Try a tag like #beautiful',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    // Typing is always a search — pull the user back to the Search tab.
    if (v.isNotEmpty && _tab != _Tab.search) setState(() => _tab = _Tab.search);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  void _commit(String v) {
    _debounce?.cancel();
    final q = v.trim();
    setState(() {
      _tab = _Tab.search;
      _query = q;
      if (q.isNotEmpty) {
        _recent.remove(q);
        _recent.insert(0, q);
        if (_recent.length > 5) _recent.removeLast();
      }
    });
  }

  void _runRecent(String q) {
    _controller.text = q;
    _commit(q);
  }

  void _clear() {
    _controller.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    // Nav bar lives in AppShell (persistent across tabs) — not here.
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.md,
                AppSpacing.pageHorizontal,
                AppSpacing.md,
              ),
              child: AppTextField(
                controller: _controller,
                hint: 'Search titles, highlights, notes…',
                search: true,
                prefixIcon: Icons.search,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                onSubmitted: _commit,
                onClear: _clear,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal),
              child: SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final t in _Tab.values) ...[
                      _Chip(
                        label: t.label,
                        count: null,
                        active: t == _tab,
                        onTap: () => setState(() => _tab = t),
                      ),
                      if (t != _Tab.values.last)
                        const SizedBox(width: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              // IndexedStack keeps each tab's scroll position and selection
              // alive across switches.
              child: IndexedStack(
                index: _tab.index,
                children: [
                  _searchTab(),
                  const _TagsTab(),
                  const _NotesTab(),
                  const _SavedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search tab (Figma 96:230) ───────────────────────────────────────────

  Widget _searchTab() => _query.isEmpty ? _empty() : _resultsView();

  Widget _empty() {
    final colors = context.appColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        96,
      ),
      children: [
        _ScopeChips(selected: _scope, response: null, onSelect: _selectScope),
        if (_recent.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('RECENT', style: AppTypography.overline(colors.text3)),
          const SizedBox(height: AppSpacing.sm),
          for (final q in _recent)
            _RecentRow(query: q, onTap: () => _runRecent(q)),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text('SUGGESTIONS', style: AppTypography.overline(colors.text3)),
        const SizedBox(height: AppSpacing.sm),
        for (final s in _suggestions) _SuggestionCard(text: s),
      ],
    );
  }

  Widget _resultsView() {
    final colors = context.appColors;
    final async = ref.watch(searchResultsProvider(_query));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: Text(
            e is ApiError ? e.message : 'Search failed',
            textAlign: TextAlign.center,
            style: AppTypography.subtitle(colors.text2),
          ),
        ),
      ),
      data: (resp) {
        final visible = resp.results.where(_scope.matches).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            0,
            AppSpacing.pageHorizontal,
            96,
          ),
          children: [
            _ScopeChips(
              selected: _scope,
              response: resp,
              onSelect: _selectScope,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '${visible.length} ${visible.length == 1 ? 'RESULT' : 'RESULTS'}',
              style: AppTypography.overline(colors.text3),
            ),
            const SizedBox(height: AppSpacing.md),
            if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                child: Center(
                  child: Text('No matches.',
                      style: AppTypography.subtitle(colors.text2)),
                ),
              )
            else
              for (final h in visible)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _HitCard(hit: h),
                ),
          ],
        );
      },
    );
  }

  void _selectScope(_Scope s) => setState(() => _scope = s);
}

// ─────────────────────────────────────────────── shared annotation helpers ──

/// Book id → title map from the library (empty while it loads).
Map<String, String> _bookTitles(WidgetRef ref) => {
      for (final b in ref.watch(libraryBooksProvider).valueOrNull ?? const [])
        b.id: b.title,
    };

/// Opens the book a highlight/note belongs to, or explains why it can't.
void _openBook(BuildContext context, WidgetRef ref, String bookId) {
  final book = (ref.read(libraryBooksProvider).valueOrNull ?? const [])
      .where((b) => b.id == bookId)
      .firstOrNull;
  if (book == null) {
    showAppSnack(context, 'That book is no longer in your library.',
        type: SnackType.warning);
    return;
  }
  context.push(Routes.readingPath(bookId), extra: book);
}

/// Server tags carry their own hex; fall back to the token for system names.
Color _tagColor(models.Tag t) {
  final hex = t.colorHex;
  if (hex != null && hex.length >= 6) {
    final v = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    if (v != null) return Color(0xFF000000 | v);
  }
  return AppColors.forTag(t.name);
}

/// One empty-state block shared by the browse tabs.
class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.icon, required this.title, required this.hint});

  final IconData icon;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── Tags tab ──

class _TagsTab extends ConsumerStatefulWidget {
  const _TagsTab();

  @override
  ConsumerState<_TagsTab> createState() => _TagsTabState();
}

class _TagsTabState extends ConsumerState<_TagsTab> {
  String? _selectedTagId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tags = ref.watch(tagsProvider).valueOrNull;
    final counts = ref.watch(tagCountsProvider).valueOrNull ?? const {};
    final titles = _bookTitles(ref);

    if (tags == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        96,
      ),
      children: [
        Text('YOUR TAGS', style: AppTypography.overline(colors.text3)),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final t in tags)
              _TagChip(
                name: t.name,
                color: _tagColor(t),
                count: counts[t.id] ?? 0,
                active: t.id == _selectedTagId,
                onTap: () => setState(() =>
                    _selectedTagId = t.id == _selectedTagId ? null : t.id),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_selectedTagId == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Text(
              'Pick a tag to revisit its passages.',
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(colors.text2),
            ),
          )
        else
          ..._tagResults(_selectedTagId!, titles, colors),
      ],
    );
  }

  List<Widget> _tagResults(
      String tagId, Map<String, String> titles, AppColorsExtension colors) {
    final async = ref.watch(tagHighlightsProvider(tagId));
    final highlights = async.valueOrNull;
    if (highlights == null) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (highlights.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: Text(
            'No passages carry this tag yet.',
            textAlign: TextAlign.center,
            style: AppTypography.subtitle(colors.text2),
          ),
        ),
      ];
    }
    return [
      Text(
        '${highlights.length} ${highlights.length == 1 ? 'PASSAGE' : 'PASSAGES'}',
        style: AppTypography.overline(colors.text3),
      ),
      const SizedBox(height: AppSpacing.md),
      for (final h in highlights)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _AnnotationHighlightCard(
            highlight: h,
            bookTitle: titles[h.bookId] ?? '',
          ),
        ),
    ];
  }
}

/// Tag pill: colored dot · name · count. Active = filled with the tag color's
/// soft form (accentSoft keeps it token-bound; the dot carries the hue).
class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.name,
    required this.color,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String name;
  final Color color;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: active ? colors.accentSoft : Colors.transparent,
          borderRadius: AppRadii.brFull,
          border: Border.all(color: active ? colors.accent : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              count > 0 ? '$name $count' : name,
              style: AppTypography.label(active ? colors.text : colors.text2)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────── Notes tab ──

class _NotesTab extends ConsumerWidget {
  const _NotesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final notes = ref.watch(allNotesProvider).valueOrNull;
    final titles = _bookTitles(ref);

    if (notes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notes.isEmpty) {
      return const _EmptyTab(
        icon: Icons.sticky_note_2_outlined,
        title: 'No notes yet.',
        hint: 'Long-press a passage while reading\nand choose Note.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        96,
      ),
      children: [
        Text(
          '${notes.length} ${notes.length == 1 ? 'NOTE' : 'NOTES'}',
          style: AppTypography.overline(colors.text3),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final n in notes)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _AnnotationNoteCard(
              note: n,
              bookTitle: titles[n.bookId] ?? '',
            ),
          ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────── Saved tab ──

class _SavedTab extends ConsumerWidget {
  const _SavedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final highlights = ref.watch(savedHighlightsProvider).valueOrNull;
    final notes = ref.watch(savedNotesProvider).valueOrNull;
    final titles = _bookTitles(ref);

    if (highlights == null || notes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Merge both kinds, newest activity first.
    final entries = <(String, Widget)>[
      for (final h in highlights)
        (
          h.createdAt ?? '',
          _AnnotationHighlightCard(
              highlight: h, bookTitle: titles[h.bookId] ?? ''),
        ),
      for (final n in notes)
        (
          n.updatedAt ?? n.createdAt ?? '',
          _AnnotationNoteCard(note: n, bookTitle: titles[n.bookId] ?? ''),
        ),
    ]..sort((a, b) => b.$1.compareTo(a.$1));

    if (entries.isEmpty) {
      return const _EmptyTab(
        icon: Icons.bookmark_outline,
        title: 'Nothing saved yet.',
        hint: 'Tap the bookmark on any highlight or note\nto keep it here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        96,
      ),
      children: [
        Text(
          '${entries.length} SAVED',
          style: AppTypography.overline(colors.text3),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: e.$2,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────── annotation cards (live data) ──

/// A real highlight (from /me/highlights) — accent bar in its tag color,
/// passage in serif italic, bookmark toggle for the Saved collection.
class _AnnotationHighlightCard extends ConsumerWidget {
  const _AnnotationHighlightCard({
    required this.highlight,
    required this.bookTitle,
  });

  final Highlight highlight;
  final String bookTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final tagTone = AppColors.forTag(highlight.colorTag ?? '');

    return GestureDetector(
      onTap: () => _openBook(context, ref, highlight.bookId),
      child: _Card(
        padding: 0,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: tagTone),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookTitle.isEmpty
                            ? 'HIGHLIGHT'
                            : 'HIGHLIGHT · ${bookTitle.toUpperCase()}',
                        style: AppTypography.overline(colors.text3),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '“${highlight.passageText ?? ''}”',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.serif(TextStyle(
                          color: colors.text,
                          fontSize: 14,
                          height: 1.35,
                          fontStyle: FontStyle.italic,
                        )),
                      ),
                      if (highlight.colorTag != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text('#${highlight.colorTag}',
                            style: AppTypography.caption(colors.text3)),
                      ],
                    ],
                  ),
                ),
              ),
              _SaveToggle(
                saved: highlight.isSaved,
                onChanged: (v) async {
                  try {
                    await ref
                        .read(highlightServiceProvider)
                        .setSaved(highlight.id, v);
                    refreshAnnotations(ref);
                  } on ApiError catch (e) {
                    if (context.mounted) {
                      showAppSnack(context, e.message, type: SnackType.error);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A real note (from /me/notes) — note glyph, body, bookmark toggle.
class _AnnotationNoteCard extends ConsumerWidget {
  const _AnnotationNoteCard({required this.note, required this.bookTitle});

  final Note note;
  final String bookTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: () => _openBook(context, ref, note.bookId),
      child: _Card(
        padding: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.sticky_note_2_outlined,
                  size: 18, color: colors.text2),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookTitle.isEmpty
                          ? 'NOTE'
                          : 'NOTE · ${bookTitle.toUpperCase()}',
                      style: AppTypography.overline(colors.text3),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      note.bodyMd,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(colors.text),
                    ),
                  ],
                ),
              ),
              _SaveToggle(
                saved: note.isSaved,
                onChanged: (v) async {
                  try {
                    await ref.read(noteServiceProvider).setSaved(note.id, v);
                    refreshAnnotations(ref);
                  } on ApiError catch (e) {
                    if (context.mounted) {
                      showAppSnack(context, e.message, type: SnackType.error);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Saved bookmark ribbon — filled when saved, outline otherwise.
class _SaveToggle extends StatelessWidget {
  const _SaveToggle({required this.saved, required this.onChanged});

  final bool saved;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IconButton(
      onPressed: () => onChanged(!saved),
      icon: Icon(
        saved ? Icons.bookmark : Icons.bookmark_outline,
        size: 20,
        color: saved ? colors.accent : colors.text3,
      ),
    );
  }
}

// ───────────────────────────────────────────── search-tab chrome & hits ──

class _ScopeChips extends StatelessWidget {
  const _ScopeChips({
    required this.selected,
    required this.response,
    required this.onSelect,
  });

  final _Scope selected;
  final SearchResponse? response;
  final ValueChanged<_Scope> onSelect;

  int? _count(_Scope s) {
    final r = response;
    if (r == null) return null;
    return switch (s) {
      _Scope.all => r.totalHits,
      _Scope.books => r.counts.books,
      _Scope.highlights => r.counts.highlights,
      _Scope.notes => r.counts.notes,
      _Scope.tags => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final s in _Scope.values) ...[
            _Chip(
              label: s.label,
              count: _count(s),
              active: s == selected,
              onTap: () => onSelect(s),
            ),
            if (s != _Scope.values.last) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
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
          color: active ? colors.text : Colors.transparent,
          borderRadius: AppRadii.brFull,
          border: Border.all(color: active ? colors.text : colors.border),
        ),
        child: Text(
          count == null ? label : '$label $count',
          style: AppTypography.label(active ? colors.bg : colors.text2)
              .copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.query, required this.onTap});
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(Icons.history, size: 18, color: colors.text3),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(query, style: AppTypography.subtitle(colors.text))),
            Icon(Icons.chevron_right, size: 18, color: colors.text3),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: colors.border),
      ),
      child: Text(text, style: AppTypography.subtitle(colors.text2)),
    );
  }
}

// ───────────────────────────────────────────────────────── result cards ──

class _HitCard extends StatelessWidget {
  const _HitCard({required this.hit});
  final SearchHit hit;

  @override
  Widget build(BuildContext context) {
    return switch (hit.type) {
      'highlight' => _HighlightHit(hit: hit),
      'note' => _NoteHit(hit: hit),
      _ => _BookHit(hit: hit),
    };
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = AppSpacing.lg});
  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      clipBehavior: Clip.antiAlias,
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
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
  }
}

class _BookHit extends StatelessWidget {
  const _BookHit({required this.hit});
  final SearchHit hit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final meta = [
      if (hit.status != null)
        '${hit.status![0].toUpperCase()}${hit.status!.substring(1)}',
      if (hit.format != null) hit.format!.toUpperCase(),
    ].join(' · ');

    return _Card(
      child: Row(
        children: [
          BookCover(
            title: hit.title ?? '',
            author: hit.bookAuthor ?? '',
            bg: coverColorFromHex(hit.coverDominantColor),
            fg: coverFgFor(hit.coverDominantColor),
            coverUrl: proxiedCoverUrl(hit.coverUrl),
            width: 48,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('BOOK', style: AppTypography.overline(colors.text3)),
                const SizedBox(height: AppSpacing.xs),
                Text(hit.title ?? '', style: AppTypography.title3(colors.text)),
                if (hit.bookAuthor != null)
                  Text(hit.bookAuthor!,
                      style: AppTypography.subtitle(colors.text2)),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(meta, style: AppTypography.caption(colors.text3)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightHit extends StatelessWidget {
  const _HighlightHit({required this.hit});
  final SearchHit hit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final base = AppTypography.subtitle(colors.text);
    return _Card(
      padding: 0,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: colors.accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HIGHLIGHT · ${(hit.bookTitle ?? '').toUpperCase()}',
                      style: AppTypography.overline(colors.text3),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text.rich(TextSpan(
                        children: _markSpans(
                            hit.snippet ?? '', base, base.copyWith(fontWeight: FontWeight.w700)))),
                    if (hit.chapterRef != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(hit.chapterRef!,
                          style: AppTypography.caption(colors.text3)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteHit extends StatelessWidget {
  const _NoteHit({required this.hit});
  final SearchHit hit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final base = AppTypography.body(colors.text);
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.sticky_note_2_outlined, size: 18, color: colors.text2),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOTE · ${(hit.bookTitle ?? '').toUpperCase()}',
                  style: AppTypography.overline(colors.text3),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text.rich(TextSpan(
                    children: _markSpans(
                        hit.snippet ?? '', base, base.copyWith(fontWeight: FontWeight.w700)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Splits a `ts_headline` snippet on `<mark>…</mark>`, bolding the matched spans.
List<InlineSpan> _markSpans(String snippet, TextStyle base, TextStyle mark) {
  final spans = <InlineSpan>[];
  final regex = RegExp(r'<mark>(.*?)</mark>', dotAll: true);
  var last = 0;
  for (final m in regex.allMatches(snippet)) {
    if (m.start > last) {
      spans.add(TextSpan(text: snippet.substring(last, m.start), style: base));
    }
    spans.add(TextSpan(text: m.group(1), style: mark));
    last = m.end;
  }
  if (last < snippet.length) {
    spans.add(TextSpan(text: snippet.substring(last), style: base));
  }
  return spans;
}
