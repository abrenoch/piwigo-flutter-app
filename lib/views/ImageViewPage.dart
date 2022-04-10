import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_cast/flutter_video_cast.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:photo_view/photo_view.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/components/snackbars.dart';
import 'package:mime_type/mime_type.dart';

import 'package:piwigo_ng/views/VideoPlayerViewPage.dart';
import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';

class Timer {
  Stream<int> tick({@required int ticks}) {
    return Stream.periodic(Duration(seconds: 1), (timer) => ticks + timer + 1);
  }
}

class ImageViewPage extends StatefulWidget {
  ImageViewPage({Key key, this.images, this.index = 0, this.isAdmin = false, this.category = "0", this.title = "Album", this.page = 0}) : super(key: key);

  final int index;
  final List<dynamic> images;
  final bool isAdmin;
  final String category;
  final String title;
  final int page;

  @override
  _ImageViewPageState createState() => _ImageViewPageState();
}
class _ImageViewPageState extends State<ImageViewPage> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Color> _backgroundAnimation;
  Animation<double> _heightAnimation;
  String _derivative;
  PageController _pageController;
  ScrollPhysics _pageViewPhysic = BouncingScrollPhysics();
  int _page;
  int _imagePage;
  List<dynamic> _images = [];
  bool _showToolBar = true;
  ChromeCastController _controller;
  PlayerState _playerState = PlayerState.idle;
  Timer _timer = Timer();
  StreamSubscription<int> _tickerSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => setState(() {}));
    _heightAnimation = Tween<double>(begin: 1, end: 0)
        .animate(_animationController);
    _backgroundAnimation = ColorTween(begin: Color(0xFF101010), end: Colors.black)
        .animate(_animationController);
    _pageController = PageController(initialPage: widget.index);
    _derivative = API.prefs.getString('full_screen_image_size');
    _page = widget.index;
    _imagePage = (widget.images.length/100).ceil()-1;
    _images.addAll(widget.images);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(widget.index == _images.length-1) {
        await nextPage();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> nextPage() async {
    _imagePage++;
    var response = await fetchImages(widget.category, _imagePage);
    if(response['stat'] == 'fail') {
      ScaffoldMessenger.of(context).showSnackBar(
          errorSnackBar(context, response['result'])
      );
    } else {
      _images.addAll(response['result']['images']);
    }
  }

  void _onEditImage() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditImagesPage(
        catId: int.parse(widget.category),
        images: [_images[_page]],
      ))
    );
  }
  void _onDownloadImage() async {
    if(await confirmDownloadDialog(context,
      content: appStrings(context).downloadImage_confirmation(1),
    )) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(appStrings(context).downloadingImages(1)),
            CircularProgressIndicator(),
          ],
        ),
      ));
      await downloadSingleImage(_images[_page]);
    }
  }
  void _onMoveCopyImage() async {
    int choice = await chooseMoveCopyImage(context);

    switch(choice) {
      case 0: showDialog(context: context,
          builder: (context) {
            return MoveOrCopyDialog(
              title: appStrings(context).moveImage_title,
              subtitle: appStrings(context).moveImage_selectAlbum(1, _images[_page]['name']),
              catId: widget.category,
              catName: widget.title,
              isImage: true,
              onSelected: (item) async {
                if(await confirmMoveDialog(context,
                  content: appStrings(context).moveImage_message(1, _images[_page]['name'], item.name),
                )) {
                  var response = await moveImage(_images[_page]['id'], [int.parse(item.id)]);
                  if(response['stat'] == 'fail') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        errorSnackBar(context, response['result']));
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        imagesMovedSnackBar(context, 1));
                    Navigator.of(context).pop();
                  }
                }
              },
            );
          }
      ).whenComplete(() {
        setState(() {});
      });
      break;
      case 1: showDialog(context: context,
          builder: (context) {
            return MoveOrCopyDialog(
              title: appStrings(context).copyImage_title,
              subtitle: appStrings(context).copyImage_selectAlbum(1, _images[_page]['name']),
              catId: widget.category,
              catName: widget.title,
              isImage: true,
              onSelected: (item) async {
                if(await confirmAssignDialog(context,
                  content: appStrings(context).copyImage_message(1, _images[_page]['name'], item.name),
                )) {
                  var response = await assignImage(_images[_page]['id'], [int.parse(item.id)]);
                  if (response['stat'] == 'fail') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        errorSnackBar(context, response['result']));
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        imagesAssignedSnackBar(context, 1));
                    Navigator.of(context).pop();
                  }
                }
              },
            );
          }
      ).whenComplete(() {
        setState(() {});
      });
      break;
      default: break;
    }
  }
  void _onDeleteImage() async {
    int choice = await confirmRemoveImagesFromAlbumDialog(context,
      content: appStrings(context).deleteImage_message(1),
      count: 1,
    );

    if(choice != -1) {
      switch(choice) {
        case 0:
          var response = await deleteImage(_images[_page]['id']);
          if(response['stat'] == 'fail') {
            ScaffoldMessenger.of(context).showSnackBar(
                errorSnackBar(context, '${response['result']}')
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(appStrings(context).deleteImageHUD_deleting(1)),
            ));
          }
          break;
        case 1:
          var response = await removeImage(_images[_page]['id'], widget.category);
          if(response['stat'] == 'fail') {
            ScaffoldMessenger.of(context).showSnackBar(
                errorSnackBar(context, '${response['result']}')
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(appStrings(context).removeImageHUD_removing(1)),
            ));
          }
          break;
        default: break;
      }

      int page = _page;
      if(page == _images.length-1) {
        if (page == 0) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            _page--;
            _pageController.previousPage(
                duration: Duration(milliseconds: 100),
                curve: Curves.easeIn);
          });
        }
      }
      _images.removeAt(page);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomInset: true,
        backgroundColor: _backgroundAnimation.value,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight * _heightAnimation.value),
          child: Transform.translate(
            offset: Offset(0, -kToolbarHeight*(1-_heightAnimation.value)),
            child: AppBar(
              iconTheme: IconThemeData(
                color: Theme.of(context).iconTheme.color, //change your color here
              ),
              backgroundColor: Colors.black.withOpacity(0.5),
              centerTitle: true,
              title: Text('${_images[_page]['name'] ?? ''}',
                overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.chevron_left),
              ),
              toolbarHeight: kToolbarHeight*_heightAnimation.value,
              actions: MediaQuery.of(context).orientation == Orientation.landscape ? [
                IconButton(
                  onPressed: _onEditImage,
                  icon: Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: _onDownloadImage,
                  icon: Icon(Icons.download),
                ),
                IconButton(
                  onPressed: _onMoveCopyImage,
                  icon: Icon(Icons.reply),
                ),
                IconButton(
                  onPressed: _onDeleteImage,
                  icon: Icon(Icons.delete, color: Theme.of(context).errorColor,),
                ),
                ChromeCastButton(
                  onButtonCreated: _onButtonCreated,
                  onSessionStarted: _onSessionStarted,
                  onSessionEnded: _onSessionEnded,
                  onRequestCompleted: _onRequestCompleted,
                  onRequestFailed: _onRequestFailed,
                ),
              ] : [
                ChromeCastButton(
                  onButtonCreated: _onButtonCreated,
                  onSessionStarted: _onSessionStarted,
                  onSessionEnded: _onSessionEnded,
                  onRequestCompleted: _onRequestCompleted,
                  onRequestFailed: _onRequestFailed,
                )
              ],
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () => setState(() {
            if(_showToolBar) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
            _showToolBar = !_showToolBar;
          }),
          child: PageView.builder(
            physics: _pageViewPhysic,
            itemCount: _images.length,
            controller: _pageController,
            onPageChanged: (newPage) async {
              if(newPage == _images.length-1) {
                await nextPage();
              }
              setState(() {
                _page = newPage;
              });
              if (await _controller?.isConnected() != null) {
                _onSessionStarted();
              }
            },
            itemBuilder: (context, index) {
              var image = _images[index];
              String mimeType = mime(image['element_url']);
              if(mimeType.startsWith('video')) {
                return _displayVideo(image);
              }
              return _displayImage(image);
            },
          ),
        ),
        bottomNavigationBar: Builder(builder: (context) {
          if(MediaQuery.of(context).orientation == Orientation.portrait
              && widget.isAdmin) {
            return Transform.translate(
              offset: Offset(0, (1-_heightAnimation.value) * kBottomNavigationBarHeight),
              child: Container(
                height: kBottomNavigationBarHeight*_heightAnimation.value,
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _onEditImage,
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: _onDownloadImage,
                      icon: Icon(Icons.download),
                    ),
                    IconButton(
                      onPressed: _onMoveCopyImage,
                      icon: Icon(Icons.reply),
                    ),
                    IconButton(
                      onPressed: _onDeleteImage,
                      icon: Icon(Icons.delete, color: Theme.of(context).errorColor,),
                    ),
                  ],
                ),
              ),
            );
          }
          return SizedBox();
        }),
      ),
    );
  }

  Future<void> _castMedia() async {
    var image = _images[_page];
    String mimeType = mime(image['element_url']);
    await _controller.loadMedia(image['element_url'],
        mimeType: mimeType ?? null,
        title: image['name'] ?? null,
        thumb: image["derivatives"]["medium"]["url"] ?? null
    );
    if(mimeType.startsWith('video')) {
      _tickerSubscription = _timer.tick(ticks: 0).listen((time) async {
        // final playing = await _controller?.isPlaying();
        // if (!playing && _playerState == PlayerState.mediaLoaded) {
        //   _controller?.pause();
        // } else {
        //   _controller?.play();
        // }
        setState(() {
        //   // _isCasting = playing;
        });
        // if(!playing) {
        //   _pageController.nextPage(
        //       duration: Duration(milliseconds: 100),
        //       curve: Curves.easeIn);
        // }
      });
    } else {
      _tickerSubscription?.cancel();
    }
  }

  Future<void> _onButtonCreated(ChromeCastController controller) async {
    // _controller = controller;
    setState(() => _controller = controller);
    await _controller.addSessionListener();
  }

  Future<void> _onSessionStarted() async {
    await _castMedia();
  }

  Future<void> _onSessionEnded() async {
    setState(() => _playerState = PlayerState.idle);
  }

  Future<void> _onRequestCompleted() async {
    setState(() {
      _playerState = PlayerState.mediaLoaded;
      // _isCasting = playing;
    });
  }

  Future<void> _onRequestFailed(String error) async {
    _tickerSubscription?.cancel();
    debugPrint("----------------------------------------------------- _onRequestFailed");
    setState(() => _playerState = PlayerState.error);
    print(error);
  }

  Widget _displayVideo(dynamic image) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: image["derivatives"][_derivative]["url"],
            fit: BoxFit.contain,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => VideoPlayerViewPage(image['element_url'],
                ratio:image['width']/image['height'],
              ),
            ));
          },
          child: IconShadowWidget(
            Icon(Icons.play_arrow_rounded, size: 100, color: Color(0x80FFFFFF)),
            shadowColor: Colors.black45,
          ),
        ),
      ],
    );
  }
  Widget _displayImage(dynamic image) {
    return PhotoView(
      imageProvider: NetworkImage(image["derivatives"][_derivative]["url"]),
      minScale: PhotoViewComputedScale.contained,
      backgroundDecoration: BoxDecoration(
        color: Colors.transparent,
      ),
      scaleStateChangedCallback: (scale) {
        if(scale.isScaleStateZooming) {
          setState(() {
            _pageViewPhysic = NeverScrollableScrollPhysics();
          });
        } else {
          setState(() {
            _pageViewPhysic = BouncingScrollPhysics();
          });
        }
      },
    );
  }
}

enum PlayerState { idle, connected, mediaLoaded, error }