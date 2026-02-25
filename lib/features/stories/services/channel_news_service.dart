import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/foundation.dart';

class ChannelNewsService {
  static Future<List<String>> fetchTopStories() async {
    try {
      String url = "https://www.channelstv.com/feed/";
      
      // Use a CORS proxy if running on Web to avoid "Failed to fetch" errors.
      if (kIsWeb) {
        url = "https://corsproxy.io/?${Uri.encodeComponent(url)}";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);

        return feed.items
            .take(10)
            .map((item) => item.title ?? "")
            .where((title) => title.isNotEmpty)
            .toList();
      } else {
        throw Exception("Failed to load news: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching news from Channels TV: $e");
      return [];
    }
  }

  static Future<List<String>> fetchBreakingNews() async {
    try {
      // Fetch the homepage instead of the RSS feed for real-time breaking news labels
      String url = "https://www.channelstv.com/";
      if (kIsWeb) {
        url = "https://corsproxy.io/?${Uri.encodeComponent(url)}";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<String> breakingHeadlines = [];
        
        // Regular expression to find "BREAKING:" headlines in the HTML
        // Example: <strong><span style="color:#e30000;">BREAKING:</span>&nbsp;Headline</strong>
        final pattern = RegExp(
          r'BREAKING:</span>\s*(?:&nbsp;)*\s*([^<]+)</strong>',
          caseSensitive: false,
        );

        final matches = pattern.allMatches(response.body);
        for (final match in matches) {
          final headline = match.group(1)?.trim();
          if (headline != null && headline.isNotEmpty) {
            // Unescape some common HTML entities if present
            final cleanHeadline = headline
                .replaceAll('&nbsp;', ' ')
                .replaceAll('&#8217;', "'")
                .replaceAll('&#8216;', "'")
                .replaceAll('&#8220;', '"')
                .replaceAll('&#8221;', '"');
            
            if (!breakingHeadlines.contains(cleanHeadline)) {
              breakingHeadlines.add(cleanHeadline);
            }
          }
        }

        return breakingHeadlines;
      } else {
        throw Exception("Failed to load breaking news: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching breaking news: $e");
      return [];
    }
  }
}
