import 'package:flutter/material.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:video_player/video_player.dart';

class SlideShowVideoPlayer extends StatefulWidget {
  const SlideShowVideoPlayer({
    Key? key,
    this.videoUrl,
    this.thumbnailUrl,
    required this.onVideoEnded,
    required this.onControllerInitialized,
  }) : super(key: key);

  final String? videoUrl;
  final String? thumbnailUrl;
  final Function onVideoEnded;
  final Function onControllerInitialized;

  @override
  State<SlideShowVideoPlayer> createState() => _SlideShowVideoPlayerState();
}

class _SlideShowVideoPlayerState extends State<SlideShowVideoPlayer> {
  late VideoPlayerController? _videoPlayerController;
  bool _videoCompleted = false;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    if (_videoPlayerController!.value.isPlaying) _videoPlayerController!.pause();
    _videoPlayerController!.removeListener(this.videoEventListener);
    _videoPlayerController!.dispose();
    super.dispose();
  }

  void videoEventListener() async {
    if (!_videoCompleted && _videoPlayerController!.value.isCompleted) {
      _videoCompleted = _videoPlayerController!.value.isCompleted;
      _videoPlayerController!.pause();
      widget.onVideoEnded();
    }
  }

  Future<void> initializePlayer() async {
    if (widget.videoUrl == null) return;
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    _videoPlayerController!.initialize().then((value) {
      _videoPlayerController!.addListener(this.videoEventListener);
      _videoPlayerController!.play();
      widget.onControllerInitialized(_videoPlayerController);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl == null) {
      return Center(
        child: Text(appStrings.errorHUD_label),
      );
    }
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        child: VideoPlayer(_videoPlayerController!),
      ),
    );
  }
}
