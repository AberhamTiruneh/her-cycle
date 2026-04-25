import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

// ─── NewsArticle model ────────────────────────────────────────────────────────

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String source;
  final DateTime? publishedAt;
  final String? imageUrl;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    this.publishedAt,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'url': url,
        'source': source,
        'publishedAt': publishedAt?.toIso8601String(),
        'imageUrl': imageUrl,
      };

  factory NewsArticle.fromJson(Map<String, dynamic> j) => NewsArticle(
        title: j['title'] as String,
        description: j['description'] as String,
        url: j['url'] as String,
        source: j['source'] as String,
        publishedAt: j['publishedAt'] != null
            ? DateTime.tryParse(j['publishedAt'] as String)
            : null,
        imageUrl: j['imageUrl'] as String?,
      );
}

// ─── NewsService ──────────────────────────────────────────────────────────────

class NewsService {
  NewsService._();
  static final NewsService instance = NewsService._();

  static const _cacheKey = 'health_news_cache';
  static const _cacheDateKey = 'health_news_cache_date';

  // Three reputable health RSS/Atom feeds — no API key required
  static const List<Map<String, String>> _feeds = [
    {
      'url': 'https://rss.medicalnewstoday.com/featurednews.xml',
      'source': 'Medical News Today',
    },
    {
      'url': 'https://tools.cdc.gov/api/v2/resources/media/316422.rss',
      'source': 'CDC Health',
    },
    {
      'url': 'https://www.who.int/rss-feeds/news-english.xml',
      'source': 'WHO',
    },
    {
      'url': 'https://www.healthline.com/rss/health-news',
      'source': 'Healthline',
    },
  ];

  /// Returns all articles from all feeds, sorted newest-first, using a daily cache.
  Future<List<NewsArticle>> fetchAllArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    // Return cached articles if still from today
    final cachedDate = prefs.getString(_cacheDateKey);
    if (cachedDate == today) {
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        try {
          final list = (jsonDecode(raw) as List)
              .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) return list;
        } catch (_) {}
      }
    }

    // Fetch all articles from every feed in parallel
    final futures = _feeds.map((feed) =>
        _fetchArticles(feed['url']!, feed['source']!).catchError((_) => <NewsArticle>[])
    ).toList();
    final results = await Future.wait(futures);
    final articles = results.expand((list) => list).toList();

    // Sort newest-first; articles without a date go to the bottom
    articles.sort((a, b) {
      if (a.publishedAt == null && b.publishedAt == null) return 0;
      if (a.publishedAt == null) return 1;
      if (b.publishedAt == null) return -1;
      return b.publishedAt!.compareTo(a.publishedAt!);
    });

    if (articles.isNotEmpty) {
      // Cache fresh result with today's date
      await prefs.setString(
          _cacheKey, jsonEncode(articles.map((a) => a.toJson()).toList()));
      await prefs.setString(_cacheDateKey, today);
      return articles;
    }

    // All feeds failed — fall back to previous cache rather than showing nothing
    final raw = prefs.getString(_cacheKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }

    return articles;
  }

  /// Fetches all articles from a single feed.
  /// Supports both RSS (<item>) and Atom (<entry>) formats.
  Future<List<NewsArticle>> _fetchArticles(
      String feedUrl, String sourceName) async {
    final response = await http
        .get(Uri.parse(feedUrl),
            headers: {'User-Agent': 'HerCycle/1.0 (health app)'})
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) return [];

    final document = XmlDocument.parse(response.body);

    // Try RSS <item> first, then Atom <entry>
    var elements = document.findAllElements('item').toList();
    final isAtom = elements.isEmpty;
    if (isAtom) {
      elements = document.findAllElements('entry').toList();
    }
    if (elements.isEmpty) return [];

    final results = <NewsArticle>[];
    for (final el in elements) {
      final article = isAtom
          ? _parseAtomEntry(el, feedUrl, sourceName)
          : _parseRssItem(el, feedUrl, sourceName);
      if (article != null) results.add(article);
    }
    return results;
  }

  NewsArticle? _parseRssItem(
      XmlElement item, String feedUrl, String sourceName) {
    String t(String tag) =>
        item.findElements(tag).firstOrNull?.innerText.trim() ?? '';

    final title = t('title');
    if (title.isEmpty) return null;

    final link = t('link');
    final rawDesc =
        t('description').isNotEmpty ? t('description') : t('content:encoded');
    final desc = _sanitize(rawDesc);

    String? imageUrl = item
        .findElements('media:content')
        .firstOrNull
        ?.getAttribute('url');
    imageUrl ??=
        item.findElements('enclosure').firstOrNull?.getAttribute('url');

    final pubDateStr = t('pubDate');
    final publishedAt =
        pubDateStr.isNotEmpty ? _parseRfc822(pubDateStr) : null;

    return NewsArticle(
      title: title,
      description: desc,
      url: link.isNotEmpty ? link : feedUrl,
      source: sourceName,
      publishedAt: publishedAt,
      imageUrl: imageUrl?.isNotEmpty == true ? imageUrl : null,
    );
  }

  NewsArticle? _parseAtomEntry(
      XmlElement entry, String feedUrl, String sourceName) {
    String t(String tag) =>
        entry.findElements(tag).firstOrNull?.innerText.trim() ?? '';

    final title = t('title');
    if (title.isEmpty) return null;

    // Atom uses <link href="..."/> not text content
    final linkEl = entry.findElements('link').firstOrNull;
    final link =
        linkEl?.getAttribute('href') ?? linkEl?.innerText.trim() ?? feedUrl;

    final rawDesc = t('summary').isNotEmpty ? t('summary') : t('content');
    final desc = _sanitize(rawDesc);

    // Atom uses <published> or <updated>
    final pubStr = t('published').isNotEmpty ? t('published') : t('updated');
    DateTime? publishedAt;
    if (pubStr.isNotEmpty) publishedAt = DateTime.tryParse(pubStr);

    return NewsArticle(
      title: title,
      description: desc,
      url: link,
      source: sourceName,
      publishedAt: publishedAt,
      imageUrl: null,
    );
  }

  String _sanitize(String raw) {
    final clean = raw.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    if (clean.isEmpty) return 'Tap to read more.';
    return clean.length > 200 ? '${clean.substring(0, 200)}…' : clean;
  }

  // Minimal RFC-822 parser for common RSS date formats
  DateTime? _parseRfc822(String s) {
    // Example: "Mon, 01 Jan 2024 12:00:00 +0000"
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
      'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
      'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.length < 5) return null;
    final day = int.tryParse(parts[1]) ?? 1;
    final month = months[parts[2]] ?? 1;
    final year = int.tryParse(parts[3]) ?? 2024;
    final timeParts = parts[4].split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute =
        timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
    final second =
        timeParts.length > 2 ? (int.tryParse(timeParts[2]) ?? 0) : 0;
    return DateTime.utc(year, month, day, hour, minute, second);
  }

  /// Clears the cache so next fetch is always fresh (call on pull-to-refresh).
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheDateKey);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
