import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:toast/toast.dart';
import 'package:dio/dio.dart';
import '../works_utils.dart';
import 'file_cache_util.dart';

class WorksVideoPlayerScaffold extends CupertinoPageScaffold {
  final String videoUrl;
  final String videoPath;
  final bool isNeedLoad; //是否需要下载后播放
  final bool isAudio;
  final String musicBgPath; //音乐背景图片

  const WorksVideoPlayerScaffold({this.videoUrl, this.videoPath,this
      .isNeedLoad = false,this.isAudio = false,this.musicBgPath})
      : super(child: const Text(''));

  @override
  // TODO: implement child
  Widget get child => SafeArea(
      top: false,
      child: Container(
          color: Colors.black,
          child: _MainWidget(this.musicBgPath,
            videoUrl: videoUrl,
            videoPath: videoPath,
            isNeedLoad: isNeedLoad,
            isAudio: isAudio,
          )));
}

class _MainWidget extends StatefulWidget {
  const _MainWidget(this.musicBgPath, {this.videoUrl, this.videoPath,this
      .isNeedLoad,this
      .isAudio});

  final String videoUrl;
  final String videoPath;
  final bool isNeedLoad;
  final bool isAudio;
  final String musicBgPath;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return __MainWidget();
  }
}

class __MainWidget extends State<_MainWidget>
    with SingleTickerProviderStateMixin {
  bool isPortOri = true;

  Timer _timer;

  bool showFullscreenBtn = false;

  int _currentDurationMilliseconds;   //当前已经播放的时间
  int _totalDurationMilliseconds;  //视频总时间

  bool showPlayIcon = false;  //是否显示播放按钮，当播放完成后显示

  double _timeWidth = 10;
  bool _prePayerPause;  //拖动之前是否暂停状态

  bool isShowBuffer = false;

  bool _isShowControlBar = false;


//  AnimationController _oriController;
//  Animation<double> _animation;

  VideoPlayerController _controller;

  void setVideoFileController(File videoFile)
  {
    _controller = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        if(!mounted)
          return;
        if (!widget.isAudio && _controller.value.aspectRatio > 1) {
          showFullscreenBtn = true;
        }

        final textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: '${WorksDateFormat.convertSecondsToHMS(_controller.value.duration.inSeconds)}',
            style: TextStyle
              (fontSize:
            12,color: Colors
                .white),
          ),
        );
        textPainter.layout();
        startTimer();
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _isShowControlBar = true;
          _timeWidth = textPainter.width + 5;
          _totalDurationMilliseconds = _controller.value.duration.inMilliseconds;
          _currentDurationMilliseconds = 0;
          _controller.play();
        });
      });
  }

  void setControllerListener()
  {
    _controller.addListener(() async {
      if (_controller.value.hasError) {
        Toast.show('播放失败:${_controller.value.errorDescription}', context);
        print('player error:${_controller.value.errorDescription}');
      }
//      if(_controller.value.isBuffering)
//        {
//          print('bufferingxxx');
//        }
      isShowBuffer = _controller.value.isBuffering;
//      print('isShowBuffer:$isShowBuffer');

      Duration duration = await _controller.position;
      if(_controller.value.initialized && duration >= _controller.value
          .duration && !_controller.value.isPlaying)
      {
        showPlayIcon = true;

      }
      else if(_controller.value.isPlaying || !showPlayIcon ||
          _currentDurationMilliseconds != 0)
      {
        showPlayIcon = false;
      }

      if(mounted) {

        setState(() {
          if(showPlayIcon)
          {
            if(_currentDurationMilliseconds != 0) {
              _currentDurationMilliseconds = 0;
              _controller.seekTo(Duration(milliseconds: 0));
              _controller.pause();
            }
          }
          else {
            if(_controller.value.initialized)
            {
              if (duration > _controller.value
                  .duration) {
                _currentDurationMilliseconds = _controller.value
                    .duration.inMilliseconds;
              }
              else {
                _currentDurationMilliseconds = duration.inMilliseconds;
              }
            }
          }
        });

      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      setVideoFileController(File(widget.videoPath));
    } else {

      if(widget.isNeedLoad)
      {
        print('video will load file');
        var fileName = widget.videoUrl.split("/").last;
        if(fileName.isNotEmpty)
        {
          FileCacheUtil.getMediaFileCacheDir().then((dir)
          {
            File videoFile = widget.isAudio ? File('${dir.path}$fileName'
                '.mp3') : File('${dir.path}$fileName'
                '.mp4');
            if(videoFile.existsSync())
            {
              setVideoFileController(videoFile);
              setControllerListener();
            }
            else
            {
              Dio().download(widget.videoUrl, videoFile.path).then((response){
                if(response.statusCode == 200)
                  {
                    setVideoFileController(videoFile);
                    setControllerListener();
                  }
                else
                  {
                    Toast.show('下载${widget.isAudio ? "音频" : "视频"}失败:${response
                        .statusMessage}',
                        context);
                    print('player error:${response.statusMessage}');
                  }
              });
            }

          });
        }
        return;
      }

      _controller = VideoPlayerController.network(widget.videoUrl)
        ..initialize().then((_) {
          if(!mounted)
            return;
          if (!widget.isAudio && _controller.value.aspectRatio > 1) {
            showFullscreenBtn = true;
          }
          final textPainter = TextPainter(
            textDirection: TextDirection.ltr,
            text: TextSpan(
              text: '${WorksDateFormat.convertSecondsToHMS(_controller.value.duration.inSeconds)}',
              style: TextStyle
                (fontSize:
              12,color: Colors
                  .white),
            ),
          );
          textPainter.layout();
          startTimer();
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {
            _isShowControlBar = true;
            _timeWidth = textPainter.width + 3;
            _totalDurationMilliseconds = _controller.value.duration.inMilliseconds;
            _currentDurationMilliseconds = 0;
            _controller.play();
          });
        });
    }

    if(_controller != null)
      {
        setControllerListener();
      }


//    _oriController = AnimationController(
//        duration: const Duration(milliseconds: 200), vsync: this);
//    _animation = Tween(begin: 0.0, end: 1.0).animate(_oriController)
//      ..addListener(() {
//        setState(() {});
//      });
  }

  void startTimer()
  {
    cancelTimer();
    const period = const Duration(seconds: 6);
    _timer = Timer.periodic(period, (timer)
    {
      if(_isShowControlBar)
        {
          setState(() {
            _isShowControlBar = false;
          });
        }
      cancelTimer();
    });
  }


  void cancelTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: ()
          {
            if(_totalDurationMilliseconds != null) {
              if(!_isShowControlBar)
                {
                  startTimer();
                }
              setState(() {
                _isShowControlBar = !_isShowControlBar;
              });
            }
          },
          child:
            Stack(
              children: <Widget>[
            Center(
                child: _controller != null && _controller.value.initialized
                    ?  AspectRatio(
                        aspectRatio: widget.isAudio ? 1 : _controller.value
                  .aspectRatio,
                        child: VideoPlayer(_controller),
//                      ))
                      )
                    : Container(
                        child: CupertinoActivityIndicator(
                          radius: 20,
                        ),
                      )
            ),
                Offstage(offstage: !widget.isAudio ||  _controller == null ||
                    !_controller.value.initialized,child: Center(
                  child: Image.asset(widget.musicBgPath ?? 'utilImages/music_bg.png',package: widget.musicBgPath == null ? 'works_utils':null,),
                ),),
            Visibility(
                visible: showPlayIcon,
                child: Center(
            child: GestureDetector(
              onTap: ()
              {
                setState(() {
                  showPlayIcon = false;
                  if(_controller !=null && _controller.value.initialized &&
                  !_controller.value
                      .isPlaying)
                    {
                      _currentDurationMilliseconds = 0;
                      _controller.seekTo(Duration(milliseconds: 0));
                      _controller.play();
                    }
                });
              },
              child: Icon(Icons.play_circle_outline,color: Colors.white,size:
              70,),
            ),
          )
        ),
              Visibility(
            visible: isShowBuffer,
            child: Center(
              child:
              CupertinoActivityIndicator(
                radius: 20,
              ),
            )
        ),
                SafeArea(
            top: true,
            bottom: true,
            child: Column(
              children: <Widget>[
                Container(
                    height: 44,
                    margin: EdgeInsets.only(top: 16,right: 16,left: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: Color(0x2F000000),
                          minSize: 35,
                          onPressed: () {
                            if (MediaQuery.of(context).orientation !=
                                Orientation.portrait) {
                              AutoOrientation.portraitUpMode();
                            }

                            if (_controller != null &&
                                _controller.value.isPlaying) {
                              _controller.pause();
                            }

                            Navigator.of(context).pop();
                          },
                          child:
                            Icon(Icons.close,color: Colors.white,size: 35,)
                        ),
                        Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: Offstage(
                                offstage: !showFullscreenBtn,
                                child: CupertinoButton(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, bottom: 2),
                                  minSize: 35,
                                  onPressed: () {
                                    Orientation ori =
                                        MediaQuery.of(context).orientation;
                                    if (ori == Orientation.portrait) {
                                      isPortOri = false;
                                      AutoOrientation.landscapeRightMode();
                                    } else {
                                      isPortOri = true;
                                      AutoOrientation.portraitUpMode();
                                    }
                                  },
                                  child: Icon(
                                    isPortOri ? Icons.fullscreen : Icons.fullscreen_exit,
                                    color: Color(0xE3FFFFFF),size: 35,
                                  ),
                                ),
                              ),
                            )),
                      ],
                    )),
                Expanded(flex: 1,child: Container(),),
                Visibility(
                  visible: _totalDurationMilliseconds != null && _isShowControlBar,
                  child: Container(
                    decoration: new BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                            colors: [Colors.black12,Colors.black26 ,Colors
                                .black12]),

                    ),
                    height: 45,margin:
                  EdgeInsets
                    .only(bottom: 35),child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: ()
                        {

                          if(_controller !=null && _controller.value
                              .initialized)
                            {
                              if(_controller.value.isPlaying)
                                {
                                  _controller.pause();
                                }
                              else
                                {
                                  if(_currentDurationMilliseconds >=
                                      _controller.value.duration.inMilliseconds)
                                    {
                                      _controller.seekTo(Duration(milliseconds: 0));
                                      _currentDurationMilliseconds = 0;
                                      showPlayIcon = false;

                                    }
                                  _controller.play();
                                }
                            }
                        },
                        child: Container(
                          width: 40,
                          child: Center(child:Icon(
                            _controller !=null &&_controller.value.initialized
                          && _controller
                                .value.isPlaying ? Icons.pause
                            :Icons
                            .play_arrow,
                            color: Colors.white,
                            size: 32,
                          )),
                        )),
                    Container(
                      width: _timeWidth,
                      child: Text(_currentDurationMilliseconds == null ? ''
                          :'${WorksDateFormat.convertSecondsToHMS
                        (_currentDurationMilliseconds~/1000)}',
                        style:
                        TextStyle
                          (fontSize:
                        12,color: Colors
                            .white),
                      ),
                    )
                    ,
                    Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child:
                          Slider(
                            value: _totalDurationMilliseconds == null ||
                                _totalDurationMilliseconds == 0 ||
                                _currentDurationMilliseconds == null ? 0 :
                                max(0,min(1,
                                    _currentDurationMilliseconds/_totalDurationMilliseconds)),
                            min: 0,
                            max: 1,
                            activeColor: Colors.white,
                            inactiveColor: Colors.grey,
                            onChanged: (value) {
                              if(_controller !=null && _controller.value
                                  .initialized &&
                                  _totalDurationMilliseconds != null &&
                                  _totalDurationMilliseconds != 0)
                              {
                                _controller.seekTo(Duration(milliseconds:
                                (_totalDurationMilliseconds * value).toInt()));

                              }

                              if(_prePayerPause && _controller !=null &&
                              !_controller.value
                                  .isPlaying)
                                {
                                  _controller.play();
                                }
                            },
                            onChangeStart: (value)
                            {
                              if(_controller.value.initialized)
                                {
                                  cancelTimer();
                                  _prePayerPause  = !_controller.value
                                      .isPlaying;

                                }
                            },
                            onChangeEnd: (value)
                            {
                              if(_controller.value.initialized)
                              {
                                startTimer();
                                if(_prePayerPause)
                                  {
                                    _controller.pause();
                                  }

                              }
//                              print('end value:$value');
                            },
                          ),
                        )),
                    Container(
                      width: _timeWidth,
                      child: Text(_totalDurationMilliseconds == null ||
                        _currentDurationMilliseconds == null ? ''
                        :'${WorksDateFormat.convertSecondsToHMS
                      ((_totalDurationMilliseconds -
                        _currentDurationMilliseconds)~/1000)}',
                      style: TextStyle(fontSize: 12,color: Colors
                          .white),
                    ),)
                    ,
                    Padding(padding: EdgeInsets.only(right: 10),)
                  ],
                )
                  ,),
                )


              ],
            ))
        ],
    ));
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
    if(_controller != null)
      {
        _controller.dispose();
      }


//    _oriController.dispose();
  }
}
