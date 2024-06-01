import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TutorialVideoPage extends StatefulWidget {
  final String videoUrl; // Replace with your video URL

  const TutorialVideoPage({required this.videoUrl});

  @override
  _TutorialVideoPageState createState() => _TutorialVideoPageState();
}

class _TutorialVideoPageState extends State<TutorialVideoPage> {
  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
          widget.videoUrl),
      // closedCaptionFile: _loadCaptions(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );



    //VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Display video player
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  children: <Widget>[
                    VideoPlayer(_controller),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ControlPanel(_controller),
                    ),
                  ],
                ),
              );
            } else {
              // Display a loading indicator while waiting for the video to load.
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

class ControlPanel extends StatelessWidget {
  final VideoPlayerController controller;

  const ControlPanel(this.controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black38,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () {
              // Pause the video
              controller.pause();
            },
            icon: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
          IconButton(
            onPressed: () {
              // Seek back 10 seconds
              controller.seekTo(controller.value.position - Duration(seconds: 10));
            },
            icon: const Icon(Icons.fast_rewind_rounded),
          ),
          IconButton(
            onPressed: () {
              // Seek forward 10 seconds
              controller.seekTo(controller.value.position + Duration(seconds: 10));
            },
            icon: const Icon(Icons.forward),
          ),
        ],
      ),
    );
  }
}
