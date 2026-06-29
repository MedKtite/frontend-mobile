import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../providers/state/home_state.dart';
import '../../widgets/add_to_library_sheet.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/glass_nav_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what — coming soon')));
  }

  void _onTab(BuildContext context, NavTab tab) {
    switch (tab) {
      case NavTab.home:
        break;
      case NavTab.search:
        context.go(Routes.search);
      case NavTab.library:
        context.go(Routes.library);
      case NavTab.profile:
        context.push(Routes.settings);
      default:
        // Insights isn't built yet.
        _comingSoon(
            context, '${tab.name[0].toUpperCase()}${tab.name.substring(1)}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(homeProvider);

    // Identity comes from the authenticated user (fetched from the backend by
    // the auth flow); fall back gracefully when not signed in.
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final name =
        user?.shortName ?? user?.displayName.split(' ').first ?? 'reader';
    final initial =
        user?.avatarInitial ?? (name.isEmpty ? '?' : name[0].toUpperCase());

    return Scaffold(
      backgroundColor: colors.bg,
      extendBody: true,
      bottomNavigationBar: GlassNavBar(
        current: NavTab.home,
        onSelect: (tab) => _onTab(context, tab),
      ),
      body: SafeArea(
        bottom: false,
        child: switch (state) {
          HomeLoading() =>
            Center(child: CircularProgressIndicator(color: colors.accent)),
          HomeEmpty() => _EmptyHome(
              onAdd: () => showAddToLibrarySheet(context),
            ),
          HomeLoaded(
            :final continueReading,
            :final passage,
            :final listening,
          ) =>
            _PopulatedHome(
              greetingName: name,
              avatarInitial: initial,
              continueReading: continueReading,
              passage: passage,
              listening: listening,
              onResume: () {
                final cr = continueReading;
                if (cr != null) context.push(Routes.readingPath(cr.id));
              },
              onPlay: () => _comingSoon(context, 'Audio player'),
            ),
          HomeError(:final message) => _ErrorState(
              message: message,
              onRetry: () => ref.read(homeProvider.notifier).load(),
            ),
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Empty state ──

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.onAdd});

  final VoidCallback onAdd;

  static const _formats = ['EPUB', 'PDF', 'M4B', 'MP3'];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(104, 70),
              painter: _OpenBookPainter(colors.text2),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Your library begins here.',
              textAlign: TextAlign.center,
              style: AppTypography.title1(colors.text),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add a book, ebook, or audiobook\nto get started',
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(colors.text2),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add your first book'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              children: [for (final f in _formats) _FormatChip(label: f)],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadii.brFull,
      ),
      child: Text(
        label,
        style: AppTypography.caption(colors.text3).copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

/// Two-page open-book line drawing for the empty state.
class _OpenBookPainter extends CustomPainter {
  const _OpenBookPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = color;

    const gap = 8.0;
    final pageW = (size.width - gap) / 2;
    for (final left in [0.0, pageW + gap]) {
      canvas.drawRRect(
        RRect.fromLTRBR(
          left, 0, left + pageW, size.height, const Radius.circular(3),
        ),
        paint,
      );
      const inset = 9.0;
      for (var i = 1; i <= 4; i++) {
        final y = size.height * i / 5;
        canvas.drawLine(
          Offset(left + inset, y), Offset(left + pageW - inset, y), paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_OpenBookPainter old) => old.color != color;
}

// ──────────────────────────────────────────────────────────── Error state ──

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: colors.text3),
            const SizedBox(height: AppSpacing.lg),
            Text(
              "Couldn't load your library.",
              textAlign: TextAlign.center,
              style: AppTypography.title3(colors.text),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.caption(colors.text2),
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── Populated state ──

const double _navClearance = 96; // scroll past the glass nav bar

class _PopulatedHome extends StatelessWidget {
  const _PopulatedHome({
    required this.greetingName,
    required this.avatarInitial,
    required this.continueReading,
    required this.passage,
    required this.listening,
    required this.onResume,
    required this.onPlay,
  });

  final String greetingName;
  final String avatarInitial;
  final ContinueReading? continueReading;
  final HomePassage? passage;
  final ListeningItem? listening;
  final VoidCallback onResume;
  final VoidCallback onPlay;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 18) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        _navClearance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(avatarInitial: avatarInitial),
          const SizedBox(height: AppSpacing.xl),
          Text.rich(
            TextSpan(
              style: AppTypography.display(colors.text),
              children: [
                TextSpan(text: '$_greeting\n'),
                TextSpan(
                  text: '$greetingName.',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Settle in. The page is still warm.',
            style: AppTypography.subtitle(colors.text2),
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (continueReading != null) ...[
            _ContinueReadingCard(book: continueReading!, onResume: onResume),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (passage != null) ...[
            _SectionLabel('PASSAGE OF THE DAY'),
            const SizedBox(height: AppSpacing.md),
            _PassageBlock(passage: passage!),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (listening != null) ...[
            _SectionLabel('STILL LISTENING TO'),
            const SizedBox(height: AppSpacing.md),
            _ListeningCard(item: listening!, onPlay: onPlay),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.avatarInitial});

  final String avatarInitial;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final now = DateTime.now();
    final date =
        '${DateFormat('EEE').format(now)} · ${DateFormat('MMM d').format(now)}'
            .toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('MARGINALIA', style: AppTypography.overline(colors.text3)),
        Row(
          children: [
            Text(date, style: AppTypography.label(colors.text2)),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              child: Text(
                avatarInitial,
                style: AppTypography.serif(TextStyle(
                  color: colors.text2,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                )),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTypography.overline(context.appColors.text3));
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
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.brLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.book, required this.onResume});

  final ContinueReading book;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(
            title: book.title,
            author: book.author,
            bg: book.coverBg,
            fg: book.coverFg,
            width: 84,
            bookmarked: true,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('CONTINUE READING',
                    style: AppTypography.overline(colors.text3)),
                const SizedBox(height: AppSpacing.xs),
                Text(book.title, style: AppTypography.title2(colors.text)),
                Text(book.author, style: AppTypography.subtitle(colors.text2)),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: AppRadii.brFull,
                        child: LinearProgressIndicator(
                          value: (book.progress / 100).clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor: colors.border,
                          color: colors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('${book.progress.round()}%',
                        style: AppTypography.label(colors.text2)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: onResume,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Resume'),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(Icons.arrow_forward, size: 16, color: colors.bg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassageBlock extends StatelessWidget {
  const _PassageBlock({required this.passage});

  final HomePassage passage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final base = AppTypography.subtitle(colors.text);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.forTag(passage.colorTag),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                passage.text,
                style: base.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: colors.gilt,
                  decorationThickness: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (passage.source.isNotEmpty)
                Text(passage.source, style: AppTypography.caption(colors.text2)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListeningCard extends StatelessWidget {
  const _ListeningCard({required this.item, required this.onPlay});

  final ListeningItem item;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _Card(
      padding: AppSpacing.md,
      child: Row(
        children: [
          BookCover(
            title: item.title,
            author: item.author,
            bg: item.coverBg,
            fg: item.coverFg,
            width: 48,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title3(colors.text),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(colors.text2),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Material(
            color: colors.text,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPlay,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.play_arrow, size: 24, color: colors.bg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
