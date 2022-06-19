import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:mime_type/mime_type.dart';

void _openWith(String url) async {
  AndroidIntent intent = AndroidIntent(
    action: 'action_view',
    data: url,
    type: mime(url),
  );
  await intent.launch();
}

class VideoPlayerViewPage extends StatefulWidget {
  const VideoPlayerViewPage(this.url, {Key key, this.ratio = 1}) : super(key: key);

  final url;
  final ratio;

  @override
  _VideoPlayerViewPageState createState() => _VideoPlayerViewPageState();
}

class _VideoPlayerViewPageState extends State<VideoPlayerViewPage> {
  BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();

    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, widget.url
    );
    _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          fit: BoxFit.contain,
          aspectRatio: widget.ratio,
          fullScreenAspectRatio: widget.ratio,
          autoPlay: true,
          autoDispose: true,
        ),
        betterPlayerDataSource: betterPlayerDataSource);

  }

  @override
  Widget build(BuildContext context) {
    _betterPlayerController.setBetterPlayerControlsConfiguration(
        BetterPlayerControlsConfiguration(
          enableSkips: false,
          enableFullscreen: false,
          enableAudioTracks: false,
          enableMute: false,
          unMuteIcon: Icons.volume_off,
          overflowMenuCustomItems: [
            BetterPlayerOverflowMenuItem(
                Icons.open_in_new,
                appStrings(context).defaultOpenWithTitle,
                () {
                  _betterPlayerController.pause();
                  _openWith( Uri.encodeFull(widget.url) );
                }
            )
          ]
        )
    );

    return Scaffold(
      primary: true,
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.chevron_left),
          ),
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent
      ),
      body: Container(
        child: Center(
          child: BetterPlayer(
            controller: _betterPlayerController,
          ),
        ),
      ),
    );
  }
}
