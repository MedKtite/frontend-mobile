import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../providers/data_sync_provider.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/setting/feedback_bottom_sheet.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  String _appVersion = '1.0.0';
  String _searchQuery = '';

  final List<_FaqItem> _faqs = [
    _FaqItem(
      category: 'Reading & Uploads',
      question: 'How do I upload books to Marginalia?',
      answer:
          'You can upload your own EPUB and PDF books, as well as audiobooks (M4B and MP3). Tap the "+" button in your Library tab to import from your device files or cloud storage.',
    ),
    _FaqItem(
      category: 'Annotations',
      question: 'How do highlights, tags, and margin notes work?',
      answer:
          'While reading, select any sentence to create a highlight. Tap the highlight to attach margin notes or apply one of the 7 literary tags (such as #resonant, #curious, or #beautiful). All your captured passages are organized in the Margins hub.',
    ),
    _FaqItem(
      category: 'Export & Backup',
      question: 'How do I export my notes into PDF or Excel?',
      answer:
          'Go to Settings → Data, Sync & Storage → Export Notes. You can download a formatted printable PDF report or a clean CSV spreadsheet with all your quotes, notes, and citations.',
    ),
    _FaqItem(
      category: 'Sync & Devices',
      question: 'How does cross-device reading sync work?',
      answer:
          'Whenever you are signed in, your reading position, margin notes, and library automatically sync to the cloud. You can seamlessly switch between your phone and tablet without losing your place.',
    ),
    _FaqItem(
      category: 'Marginalia Pro',
      question: 'What is included with Marginalia Pro?',
      answer:
          'Marginalia Pro includes unlimited library uploads, custom margin tags, reading insights recaps, audio speed controls, and active synchronization across up to 5 devices.',
    ),
    _FaqItem(
      category: 'Storage',
      question: 'How can I free up phone storage without losing my notes?',
      answer:
          'In Settings → Data, Sync & Storage, tap "Clear Offline Cache". This safely removes downloaded local copies of book audio and pages from your phone while keeping all your highlights and notes backed up in the cloud.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final pkg = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${pkg.version} (${pkg.buildNumber})';
      });
    } catch (_) {}
  }

  Future<void> _launchEmailSupport() async {
    final auth = ref.read(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final syncState = ref.read(dataSyncProvider);
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@marginalia.app',
      queryParameters: {
        'subject': 'Marginalia Support Request',
        'body': '\n\n---\nApp Version: $_appVersion\nDevice: ${syncState.currentDeviceName}\nUser: ${user?.email ?? 'Anonymous'}\n',
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          showAppSnack(context, 'Please email us directly at support@marginalia.app');
        }
      }
    } catch (_) {
      if (mounted) {
        showAppSnack(context, 'Please email us at support@marginalia.app');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    ref.watch(authProvider);
    ref.watch(dataSyncProvider);

    final filteredFaqs = _searchQuery.isEmpty
        ? _faqs
        : _faqs
            .where((f) =>
                f.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                f.answer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                f.category.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: 'Help & Feedback',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxxl,
                ),
                children: [
                  // 1. Quick Support Action Cards (Send In-App Feedback & Email Support)
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          title: 'Send Feedback',
                          subtitle: 'Report a bug or idea',
                          icon: Icons.chat_bubble_outline_rounded,
                          onTap: () => showFeedbackBottomSheet(context),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _ActionCard(
                          title: 'Email Support',
                          subtitle: 'support@marginalia.app',
                          icon: Icons.mail_outline_rounded,
                          onTap: _launchEmailSupport,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 2. Search & FAQ Header
                  _SectionHeader(title: 'FREQUENTLY ASKED QUESTIONS'),
                  const SizedBox(height: AppSpacing.xs),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: AppTypography.body(colors.text),
                      decoration: InputDecoration(
                        icon: Icon(Icons.search_rounded, color: colors.text3, size: 20),
                        hintText: 'Search help guides & questions...',
                        hintStyle: AppTypography.body(colors.text3),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // FAQ Accordion List
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: filteredFaqs.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'No matching questions found.',
                                style: AppTypography.body(colors.text3),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              for (var i = 0; i < filteredFaqs.length; i++) ...[
                                if (i > 0)
                                  Divider(
                                    height: 1,
                                    color: colors.border.withValues(alpha: 0.08),
                                    indent: 16,
                                    endIndent: 16,
                                  ),
                                _FaqTile(item: filteredFaqs[i]),
                              ],
                            ],
                          ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 3. System & App Diagnostics Card
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String category;
  final String question;
  final String answer;

  _FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;

  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey(widget.item.question),
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (exp) => setState(() => _isExpanded = exp),
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        title: Text(
          widget.item.question,
          style: AppTypography.serif(
            TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: colors.text,
              letterSpacing: -0.2,
            ),
          ),
        ),
        trailing: Icon(
          _isExpanded ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded,
          color: _isExpanded ? colors.gilt : colors.text3,
          size: 20,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.item.answer,
              style: AppTypography.sans(
                TextStyle(
                  fontSize: 13.5,
                  color: colors.text2,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.gilt.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Icon(icon, color: colors.gilt, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.serif(
                TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.sans(
                TextStyle(fontSize: 12, color: colors.text3),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}



class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          AuthBackButton(onPressed: onBack),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: AppTypography.serif(
                  TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.sans(
          TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: colors.text3,
          ),
        ),
      ),
    );
  }
}
