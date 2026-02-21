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
      String url = "https://www.channelstv.com/feed/";
      if (kIsWeb) {
        url = "https://corsproxy.io/?${Uri.encodeComponent(url)}";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);

        // Filter items that contain "BREAKING" in the title
        return feed.items
            .where((item) => 
                (item.title ?? "").toUpperCase().contains("BREAKING"))
            .map((item) => item.title ?? "")
            .where((title) => title.isNotEmpty)
            .toList();
      } else {
        throw Exception("Failed to load breaking news: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching breaking news: $e");
      return [];
    }
  }
}
