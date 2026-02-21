import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../../services/channel_news_service.dart';

class TopStoriesTicker extends StatefulWidget {
  const TopStoriesTicker({super.key});

  @override
  State<TopStoriesTicker> createState() => _TopStoriesTickerState();
}

class _TopStoriesTickerState extends State<TopStoriesTicker> {
  List<String> stories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStories();
  }

  Future<void> loadStories() async {
    try {
      final fetchedStories = await ChannelNewsService.fetchTopStories();
      if (mounted) {
        setState(() {
          stories = fetchedStories;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 30,
        child: Center(
          child: SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
            ),
          ),
        ),
      );
    }

    if (stories.isEmpty) return const SizedBox();

    return Expanded(
      child: Row(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: IconButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                loadStories();
              },
              icon: const Icon(Icons.refresh, size: 14, color: Colors.black54),
              padding: EdgeInsets.zero,
              tooltip: 'Refresh Stories',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 30,
              alignment: Alignment.centerLeft,
              child: Marquee(
                text: stories.join("   🔴   "),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                velocity: 40,
                blankSpace: 100,
                pauseAfterRound: const Duration(seconds: 1),
                accelerationDuration: const Duration(seconds: 1),
                accelerationCurve: Curves.linear,
                decelerationDuration: const Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
