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
import '../../models/search_hit.dart';
import '../../models/search_response.dart';
import '../../providers/search_provider.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/glass_nav_bar.dart';

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
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  void _commit(String v) {
    _debounce?.cancel();
    final q = v.trim();
    setState(() {
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

  void _onTab(NavTab tab) {
    switch (tab) {
      case NavTab.search:
        break;
      case NavTab.home:
        context.go(Routes.home);
      case NavTab.library:
        context.go(Routes.library);
      case NavTab.profile:
        context.push(Routes.settings);
      default:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(
              '${tab.name[0].toUpperCase()}${tab.name.substring(1)} — coming soon')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.bg,
      extendBody: true,
      bottomNavigationBar: GlassNavBar(current: NavTab.search, onSelect: _onTab),
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
                AppSpacing.lg,
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                onSubmitted: _commit,
                style: AppTypography.body(colors.text),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: colors.surface,
                  hintText: 'Search titles, highlights, notes…',
                  hintStyle: AppTypography.body(colors.text3),
                  prefixIcon: Icon(Icons.search, size: 20, color: colors.text3),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.close, size: 18, color: colors.text2),
                          onPressed: _clear,
                        ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.brFull,
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadii.brFull,
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadii.brFull,
                    borderSide: BorderSide(color: colors.accent, width: 1.5),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _query.isEmpty ? _empty() : _resultsView(),
            ),
          ],
        ),
      ),
    );
  }

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
