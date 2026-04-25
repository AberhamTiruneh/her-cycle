import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../services/news_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<NewsArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsService.instance.fetchTopArticles(count: 3);
  }

  Future<void> _refresh() async {
    await NewsService.instance.clearCache();
    setState(() {
      _newsFuture = NewsService.instance.fetchTopArticles(count: 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.healthNews,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: AppFonts.titleL,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: FutureBuilder<List<NewsArticle>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading(isDark);
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildError(context, isDark, textPrimary, textSec);
            }

            final articles = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              children: [
                // Date header
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppSizes.spacingM),
                  child: Row(
                    children: [
                      const Icon(Icons.newspaper_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _formattedDate(),
                        style: GoogleFonts.poppins(
                          fontSize: AppFonts.bodyS,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '· ${l10n.topHealthStories}',
                        style: GoogleFonts.poppins(
                          fontSize: AppFonts.bodyS,
                          color: textSec,
                        ),
                      ),
                    ],
                  ),
                ),

                // Article cards
                ...articles.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final article = entry.value;
                  return _ArticleCard(
                    article: article,
                    rank: idx + 1,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    isDark: isDark,
                  );
                }),

                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    final shimmerBase =
        isDark ? AppColors.darkCardBackground : const Color(0xFFE8E8E8);
    final shimmerHighlight =
        isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5);
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      itemCount: 3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
        child: _ShimmerCard(base: shimmerBase, highlight: shimmerHighlight),
      ),
    );
  }

  Widget _buildError(BuildContext context, bool isDark, Color textPrimary,
      Color textSec) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 60, color: AppColors.primary.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text(
                'Could not load news',
                style: GoogleFonts.poppins(
                    fontSize: AppFonts.titleM,
                    fontWeight: FontWeight.w600,
                    color: textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Check your internet connection\nand pull down to retry.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: AppFonts.bodyS, color: textSec),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

// ─── Article Card ─────────────────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  final NewsArticle article;
  final int rank;
  final Color cardBg;
  final Color textPrimary;
  final Color textSec;
  final bool isDark;

  const _ArticleCard({
    required this.article,
    required this.rank,
    required this.cardBg,
    required this.textPrimary,
    required this.textSec,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openUrl(article.url),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank badge + source row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.paddingL,
                  AppSizes.paddingL,
                  AppSizes.paddingL,
                  AppSizes.paddingS),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      article.source,
                      style: GoogleFonts.poppins(
                        fontSize: AppFonts.bodyS,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (article.publishedAt != null)
                    Text(
                      _timeAgo(article.publishedAt!),
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: textSec),
                    ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL),
              child: Text(
                article.title,
                style: GoogleFonts.poppins(
                  fontSize: AppFonts.bodyM,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSizes.spacingXS),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL),
              child: Text(
                article.description,
                style: GoogleFonts.poppins(
                  fontSize: AppFonts.bodyS,
                  color: textSec,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),

            // Read more button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.paddingL,
                  0,
                  AppSizes.paddingL,
                  AppSizes.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Read full article',
                    style: GoogleFonts.poppins(
                      fontSize: AppFonts.bodyS,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

// ─── Shimmer Loading Card ─────────────────────────────────────────────────────

class _ShimmerCard extends StatefulWidget {
  final Color base;
  final Color highlight;
  const _ShimmerCard({required this.base, required this.highlight});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            gradient: LinearGradient(
              begin: Alignment(_anim.value, 0),
              end: Alignment(_anim.value + 1, 0),
              colors: [widget.base, widget.highlight, widget.base],
            ),
          ),
        );
      },
    );
  }
}
