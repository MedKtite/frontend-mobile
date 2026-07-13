import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../models/book.dart';
import '../../models/highlight.dart';
import '../../models/note.dart';
import '../../providers/annotations_provider.dart';
import '../../providers/library_provider.dart';
import '../../widgets/book_cover.dart';

/// A personal reading-year summary built from the library and annotations
/// already available on the device.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(libraryBooksProvider);
    final highlightsAsync = ref.watch(allHighlightsProvider);
    final notesAsync = ref.watch(allNotesProvider);
    final colors = context.appColors;

    if (booksAsync.hasError || highlightsAsync.hasError || notesAsync.hasError) {
      return Scaffold(
        body: Center(
          child: Text(
            "Couldn't load your reading insights.",
            style: AppTypography.subtitle(colors.text2),
          ),
        ),
      );
    }

    final books = booksAsync.valueOrNull;
    final highlights = highlightsAsync.valueOrNull;
    final notes = notesAsync.valueOrNull;
    if (books == null || highlights == null || notes == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final insights = _Insights.from(books, highlights, notes, DateTime.now());
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.md,
            AppSpacing.pageHorizontal,
            112,
          ),
          children: [
            Text(
              '${insights.year} · YOUR READING YEAR',
              style: AppTypography.overline(colors.text3),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Insights', style: AppTypography.display(colors.text)),
            const SizedBox(height: AppSpacing.xl),
            _YearCard(insights: insights),
            const SizedBox(height: AppSpacing.md),
            _StatRow(insights: insights),
            const SizedBox(height: AppSpacing.xxl),
            _SectionLabel(label: 'TAG BREAKDOWN'),
            const SizedBox(height: AppSpacing.md),
            _TagBreakdown(tags: insights.tagCounts),
            const SizedBox(height: AppSpacing.xxl),
            _SectionLabel(label: 'HOW YOU READ'),
            const SizedBox(height: AppSpacing.md),
            _ReadingMix(mix: insights.readingMix),
            const SizedBox(height: AppSpacing.xxl),
            _SectionLabel(label: 'MOST ANNOTATED'),
            const SizedBox(height: AppSpacing.md),
            _MostAnnotated(books: insights.mostAnnotated),
            if (insights.quietSuggestion != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              _QuietSuggestion(book: insights.quietSuggestion!),
            ],
          ],
        ),
      ),
    );
  }
}

class _YearCard extends StatelessWidget {
  const _YearCard({required this.insights});

  final _Insights insights;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.brXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${insights.finishedBooks}',
                      style: AppTypography.statNumber(colors.text),
                    ),
                    TextSpan(
                      text: ' books',
                      style: AppTypography.subtitle(colors.text2),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_compactNumber(insights.finishedPages)} pages',
                    style: AppTypography.caption(colors.text2),
                  ),
                  Text(
                    '${insights.booksPerMonth.toStringAsFixed(1)} / month',
                    style: AppTypography.caption(colors.text2),
                  ),
                ],
              ),
            ],
          ),
          Text(
            'finished so far this year',
            style: AppTypography.label(colors.text3),
          ),
          const SizedBox(height: AppSpacing.xl),
          _MonthlyChart(values: insights.finishedByMonth),
        ],
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final maxValue = values.fold(1, (max, value) => value > max ? value : max);
    const labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return SizedBox(
      height: AppSpacing.xxxl + AppSpacing.xxl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < values.length; index++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs / 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: (values[index] / maxValue) * AppSpacing.xxxl,
                          decoration: BoxDecoration(
                            color: values[index] == 0
                                ? colors.surface2
                                : colors.text.withValues(alpha: 0.82),
                            borderRadius: AppRadii.brXs,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(labels[index], style: AppTypography.overline(colors.text3)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.insights});

  final _Insights insights;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _StatCard(
              value: '${insights.activeDays}',
              label: 'active days',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              value: insights.annotationsPerBook.toStringAsFixed(1),
              label: 'avg. annotations',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              value: _compactNumber(insights.highlights),
              label: 'passages saved',
            ),
          ),
        ],
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: AppSpacing.xxxl * 2 + AppSpacing.sm,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: colors.surface, borderRadius: AppRadii.brLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTypography.title2(colors.text)),
          const Spacer(),
          Text(label, style: AppTypography.caption(colors.text3)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) =>
      Text(label, style: AppTypography.overline(context.appColors.text3));
}

class _TagBreakdown extends StatelessWidget {
  const _TagBreakdown({required this.tags});

  final List<_TagTotal> tags;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (tags.isEmpty) {
      return Text('Your tagged passages will appear here.',
          style: AppTypography.subtitle(colors.text2));
    }
    final max = tags.first.count;
    return Column(
      children: [
        for (final tag in tags) ...[
          Row(
            children: [
              Container(
                width: AppSpacing.sm,
                height: AppSpacing.sm,
                decoration: BoxDecoration(color: tag.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: AppSpacing.xxxl * 2,
                child: Text(_capitalize(tag.name),
                    style: AppTypography.label(colors.text2)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadii.brFull,
                  child: LinearProgressIndicator(
                    value: tag.count / max,
                    minHeight: AppSpacing.sm,
                    color: tag.color,
                    backgroundColor: colors.surface2,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: AppSpacing.lg,
                child: Text('${tag.count}',
                    textAlign: TextAlign.end,
                    style: AppTypography.label(colors.text)),
              ),
            ],
          ),
          if (tag != tags.last) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _ReadingMix extends StatelessWidget {
  const _ReadingMix({required this.mix});

  final _ReadingMixData mix;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final total = mix.print + mix.audio + mix.both;
    if (total == 0) {
      return Text('Add books to see your reading mix.',
          style: AppTypography.subtitle(colors.text2));
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: colors.surface, borderRadius: AppRadii.brLg),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: AppRadii.brFull,
            child: SizedBox(
              height: AppSpacing.md,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MixSegment(count: mix.print, total: total, color: colors.text),
                  const SizedBox(width: AppSpacing.xs),
                  _MixSegment(count: mix.audio, total: total, color: colors.accent),
                  const SizedBox(width: AppSpacing.xs),
                  _MixSegment(count: mix.both, total: total, color: colors.text3),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _MixLegend(label: 'Print', count: mix.print, color: colors.text),
              const SizedBox(width: AppSpacing.lg),
              _MixLegend(label: 'Audio', count: mix.audio, color: colors.accent),
              const SizedBox(width: AppSpacing.lg),
              _MixLegend(label: 'Both', count: mix.both, color: colors.text3),
            ],
          ),
        ],
      ),
    );
  }
}

class _MixSegment extends StatelessWidget {
  const _MixSegment({required this.count, required this.total, required this.color});

  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) => count == 0
      ? const SizedBox.shrink()
      : Expanded(flex: count, child: ColoredBox(color: color));
}

class _MixLegend extends StatelessWidget {
  const _MixLegend({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSpacing.sm,
          height: AppSpacing.sm,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('$label $count', style: AppTypography.caption(colors.text2)),
      ],
    );
  }
}

class _MostAnnotated extends StatelessWidget {
  const _MostAnnotated({required this.books});

  final List<_AnnotatedBook> books;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (books.isEmpty) {
      return Text('Highlight passages to build this list.',
          style: AppTypography.subtitle(colors.text2));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(color: colors.surface, borderRadius: AppRadii.brLg),
      child: Column(
        children: [
          for (final entry in books) ...[
            _AnnotatedBookRow(entry: entry),
            if (entry != books.last) Divider(height: 1, color: colors.border),
          ],
        ],
      ),
    );
  }
}

class _AnnotatedBookRow extends StatelessWidget {
  const _AnnotatedBookRow({required this.entry});

  final _AnnotatedBook entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          BookCover(
            title: entry.book.title,
            author: entry.book.author ?? '',
            bg: coverColorFromHex(entry.book.coverDominantColor),
            fg: coverFgFor(entry.book.coverDominantColor),
            coverUrl: proxiedCoverUrl(entry.book.coverUrl),
            width: AppSpacing.xxxl,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(colors.text)
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                Text(entry.book.author ?? 'Unknown author',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption(colors.text3)),
              ],
            ),
          ),
          Container(
            width: AppSpacing.xxl,
            height: AppSpacing.xs,
            decoration: BoxDecoration(color: colors.text, borderRadius: AppRadii.brFull),
          ),
          const SizedBox(width: AppSpacing.md),
          Text('${entry.count}', style: AppTypography.label(colors.text)),
        ],
      ),
    );
  }
}

class _QuietSuggestion extends StatelessWidget {
  const _QuietSuggestion({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final progress = book.progressPct?.round() ?? 0;
    final lastOpened = DateTime.tryParse(book.lastOpenedAt ?? '');
    final since = lastOpened == null
        ? ''
        : ' since ${DateFormat('MMMM').format(lastOpened.toLocal())}';
    final pagesRemaining = book.pageCount == null
        ? null
        : ((book.pageCount! * (100 - progress)) / 100)
            .ceil()
            .clamp(1, book.pageCount!)
            .toInt();
    final ending = pagesRemaining == null
        ? 'a few pages from the end.'
        : '$pagesRemaining ${pagesRemaining == 1 ? 'page' : 'pages'} from the end.';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface2,
        border: Border.all(color: colors.border),
        borderRadius: AppRadii.brLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('A QUIET SUGGESTION', style: AppTypography.overline(colors.accent)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${book.title} has been waiting at $progress%$since — $ending',
            style: AppTypography.subtitle(colors.text),
          ),
        ],
      ),
    );
  }
}

class _Insights {
  const _Insights({
    required this.year,
    required this.finishedBooks,
    required this.finishedPages,
    required this.booksPerMonth,
    required this.finishedByMonth,
    required this.activeDays,
    required this.annotationsPerBook,
    required this.highlights,
    required this.tagCounts,
    required this.readingMix,
    required this.mostAnnotated,
    required this.quietSuggestion,
  });

  final int year;
  final int finishedBooks;
  final int finishedPages;
  final double booksPerMonth;
  final List<int> finishedByMonth;
  final int activeDays;
  final double annotationsPerBook;
  final int highlights;
  final List<_TagTotal> tagCounts;
  final _ReadingMixData readingMix;
  final List<_AnnotatedBook> mostAnnotated;
  final Book? quietSuggestion;

  factory _Insights.from(
    List<Book> books,
    List<Highlight> highlights,
    List<Note> notes,
    DateTime now,
  ) {
    final finishedThisYear = books.where((book) {
      final date = DateTime.tryParse(book.finishedAt ?? '');
      return date?.year == now.year;
    }).toList();
    final finishedByMonth = List<int>.filled(12, 0);
    for (final book in finishedThisYear) {
      final month = DateTime.tryParse(book.finishedAt!)!.month;
      finishedByMonth[month - 1]++;
    }
    final tagMap = <String, int>{};
    final bookCount = <String, int>{};
    final activeDates = <String>{};
    for (final highlight in highlights) {
      final tag = highlight.colorTag;
      if (tag != null && tag.isNotEmpty) {
        tagMap.update(tag, (count) => count + 1, ifAbsent: () => 1);
      }
      bookCount.update(highlight.bookId, (count) => count + 1, ifAbsent: () => 1);
      final created = DateTime.tryParse(highlight.createdAt ?? '');
      if (created != null) activeDates.add(DateFormat('yyyy-MM-dd').format(created));
    }
    final booksById = {for (final book in books) book.id: book};
    final mostAnnotated = bookCount.entries
        .where((entry) => booksById.containsKey(entry.key))
        .map((entry) => _AnnotatedBook(booksById[entry.key]!, entry.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final audio = books.where((book) => _isAudio(book.format)).length;
    final print = books.where((book) => _isPrint(book.format)).length;
    final both = books.length - audio - print;
    final monthCount = now.month;

    return _Insights(
      year: now.year,
      finishedBooks: finishedThisYear.length,
      finishedPages: finishedThisYear.fold(0, (total, book) => total + (book.pageCount ?? 0)),
      booksPerMonth: finishedThisYear.length / monthCount,
      finishedByMonth: finishedByMonth,
      activeDays: activeDates.length,
      annotationsPerBook: books.isEmpty ? 0 : (highlights.length + notes.length) / books.length,
      highlights: highlights.length,
      tagCounts: tagMap.entries
          .map((entry) => _TagTotal(entry.key, entry.value))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count)),
      readingMix: _ReadingMixData(print: print, audio: audio, both: both),
      mostAnnotated: mostAnnotated.take(3).toList(),
      quietSuggestion: books.where((book) {
        final progress = book.progressPct ?? 0;
        return book.status == 'reading' && progress >= 50 && progress < 100;
      }).firstOrNull,
    );
  }
}

class _TagTotal {
  const _TagTotal(this.name, this.count);

  final String name;
  final int count;
  Color get color => AppColors.forTag(name);
}

class _ReadingMixData {
  const _ReadingMixData({required this.print, required this.audio, required this.both});

  final int print;
  final int audio;
  final int both;
}

class _AnnotatedBook {
  const _AnnotatedBook(this.book, this.count);

  final Book book;
  final int count;
}

bool _isAudio(String? format) => format == 'm4b' || format == 'mp3';

bool _isPrint(String? format) =>
    format == 'epub' || format == 'pdf' || format == 'physical';

String _compactNumber(int value) => NumberFormat.compact().format(value);

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
