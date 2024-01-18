import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExpandableVideoPlayer extends StatefulWidget {
  final String videoUrl;

  ExpandableVideoPlayer({required this.videoUrl});

  @override
  _ExpandableVideoPlayerState createState() => _ExpandableVideoPlayerState();
}

class _ExpandableVideoPlayerState extends State<ExpandableVideoPlayer> {
  bool isExpanded = false;
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl)!,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        hideControls: true
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: !isExpanded
          ? YoutubePlayer(
        controller: _controller,
      )
          : AspectRatio(
        aspectRatio: 16 / 9, // You can adjust the aspect ratio as needed.
        child: Container(
          color: Colors.black,
          child: Center(
            child: Icon(
              Icons.play_circle_fill,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
