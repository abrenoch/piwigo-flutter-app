import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoPlayerViewPage extends StatefulWidget {
  const VideoPlayerViewPage(this.url, {Key key, this.ratio = 1}) : super(key: key);

  final url;
  final ratio;

  @override
  _VideoPlayerViewPageState createState() => _VideoPlayerViewPageState();
}

class _VideoPlayerViewPageState extends State<VideoPlayerViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Container(
        child: Center(
          child: BetterPlayer.network(
            widget.url,
            betterPlayerConfiguration: BetterPlayerConfiguration(
              fit: BoxFit.contain,
              aspectRatio: widget.ratio,
              fullScreenAspectRatio: widget.ratio,
              allowedScreenSleep: false,
              autoPlay: true,
              autoDispose: true,
              eventListener: (BetterPlayerEvent event) {
                if (event.betterPlayerEventType == BetterPlayerEventType.play) {
                  hideSystemUI();
                }
              },
              controlsConfiguration: BetterPlayerControlsConfiguration(
                enableSkips: false,
                enableFullscreen: false,
                enableAudioTracks: false,
                enableMute: false,
                unMuteIcon: Icons.volume_off,
              ),
            ),
          ),
        ),
      ),
    );
  }

  hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  initState() {
    super.initState();
    hideSystemUI();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }
}
