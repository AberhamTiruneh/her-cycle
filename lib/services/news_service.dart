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

  // Three reputable health RSS feeds — no API key required
  static const List<Map<String, String>> _feeds = [
    {
      'url': 'https://rss.medicalnewstoday.com/featurednews.xml',
      'source': 'Medical News Today',
    },
    {
      'url': 'https://feeds.webmd.com/rss/rss.aspx?RSSSource=RSS_PUBLIC',
      'source': 'WebMD',
    },
    {
      'url': 'https://www.who.int/rss-feeds/news-english.xml',
      'source': 'WHO',
    },
  ];

  /// Returns up to [count] articles, using a daily cache.
  Future<List<NewsArticle>> fetchTopArticles({int count = 3}) async {
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

    // Fetch fresh articles
    final articles = <NewsArticle>[];
    for (final feed in _feeds) {
      if (articles.length >= count) break;
      try {
        final article = await _fetchFirstArticle(
          feed['url']!,
          feed['source']!,
        );
        if (article != null) articles.add(article);
      } catch (_) {
        // Skip failed feed silently
      }
    }

    if (articles.isNotEmpty) {
      // Cache result
      await prefs.setString(
          _cacheKey, jsonEncode(articles.map((a) => a.toJson()).toList()));
      await prefs.setString(_cacheDateKey, today);
    }

    return articles;
  }

  Future<NewsArticle?> _fetchFirstArticle(
      String feedUrl, String sourceName) async {
    final response = await http
        .get(Uri.parse(feedUrl))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;

    final document = XmlDocument.parse(response.body);
    final items = document.findAllElements('item');
    if (items.isEmpty) return null;

    final item = items.first;

    String _text(String tag) =>
        item.findElements(tag).firstOrNull?.innerText.trim() ?? '';

    final title = _text('title');
    if (title.isEmpty) return null;

    final link = _text('link');
    final rawDesc = _text('description').isNotEmpty
        ? _text('description')
        : _text('content:encoded');
    final cleanDesc =
        rawDesc.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    // Try media:content url attribute for image
    String? imageUrl;
    final mediaContent = item.findElements('media:content').firstOrNull;
    imageUrl = mediaContent?.getAttribute('url');
    if (imageUrl == null || imageUrl.isEmpty) {
      final enclosure = item.findElements('enclosure').firstOrNull;
      imageUrl = enclosure?.getAttribute('url');
    }

    DateTime? publishedAt;
    final pubDateStr = _text('pubDate');
    if (pubDateStr.isNotEmpty) {
      try {
        publishedAt = _parseRfc822(pubDateStr);
      } catch (_) {}
    }

    return NewsArticle(
      title: title,
      description: cleanDesc.isNotEmpty
          ? (cleanDesc.length > 200
              ? '${cleanDesc.substring(0, 200)}…'
              : cleanDesc)
          : 'Tap to read more.',
      url: link.isNotEmpty ? link : feedUrl,
      source: sourceName,
      publishedAt: publishedAt,
      imageUrl: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : null,
    );
  }

  // Minimal RFC-822 parser for common RSS date formats
  DateTime? _parseRfc822(String s) {
    // Example: "Mon, 01 Jan 2024 12:00:00 +0000"
    final months = {
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
    final minute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
    final second = timeParts.length > 2 ? (int.tryParse(timeParts[2]) ?? 0) : 0;
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
