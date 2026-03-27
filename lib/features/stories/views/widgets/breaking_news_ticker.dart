import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../../services/channel_news_service.dart';

class BreakingNewsTicker extends StatefulWidget {
  const BreakingNewsTicker({super.key});

  @override
  State<BreakingNewsTicker> createState() => _BreakingNewsTickerState();
}

class _BreakingNewsTickerState extends State<BreakingNewsTicker> {
  List<String> breakingStories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBreakingNews();
  }

  Future<void> loadBreakingNews() async {
    try {
      final fetchedStories = await ChannelNewsService.fetchBreakingNews();
      if (mounted) {
        setState(() {
          breakingStories = fetchedStories;
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
        width: 100,
        child: Center(
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
        ),
      );
    }

    if (breakingStories.isEmpty) {
      return Row(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: IconButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                loadBreakingNews();
              },
              icon: const Icon(Icons.refresh, size: 14, color: Colors.white),
              padding: EdgeInsets.zero,
              tooltip: 'Refresh Breaking News',
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              '...NO BREAKING NEWS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: IconButton(
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              loadBreakingNews();
            },
            icon: const Icon(Icons.refresh, size: 14, color: Colors.white),
            padding: EdgeInsets.zero,
            tooltip: 'Refresh Breaking News',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 30,
            child: Marquee(
              text: breakingStories.map((s) => s.replaceAll(RegExp(r'[\n\r]+'), ' ').trim()).join("   🚨   "),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              velocity: 50,
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
    );
  }
}
