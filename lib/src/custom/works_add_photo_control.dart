import 'dart:math';

import 'package:asset_picker/asset_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../works_photo_browser.dart';


class PhotoPickWidget extends StatefulWidget {
  final List<dynamic> photos;
  final int columnCount;
  final double space;
  final int maxCount;
  final double photoSize; //宽度
  final Color textColor;

  const PhotoPickWidget(this.photos, this.photoSize,
      {this.columnCount = 4, this.space = 8, this.maxCount = 8,this.textColor = Colors.white});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PhotoPickWidget();
  }
}

class _PhotoPickWidget extends State<PhotoPickWidget> {
  void toBrowser(int index) {
    List<Map<String,dynamic>> galleryItems = [];

    for(var photoItem in widget.photos)
    {
      galleryItems.add({'key':'','photo':photoItem});
    }

    Navigator.of(context,rootNavigator: true).push(
        new PageRouteBuilder(
            fullscreenDialog: true,
            transitionDuration : Duration(milliseconds: 10),
            pageBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation) {
              // 跳转的路由对象
              return WorksPhotoBrowser(index,galleryItems);
            }, transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
            ) {
          return child;
        }
        )
    );
  }

  Future<void> getAllPhoto() async {
    await showAssetPickNavigationDialog(
        maxNumber: widget.maxCount - widget.photos.length,
        context: context,
        textColor: widget.textColor,
        photoDidSelectCallBack: (assets) {
          if (assets != null) {
            setState(() {
              widget.photos.addAll(assets);
            });
          }
        });
  }

  void toRemovePhoto(int index)
  {
    showCupertinoDialog(
        context: context,
        builder: (ctx)
        {
          var dialog = CupertinoAlertDialog(
              title: Text('要删除这张照片吗？'),
             actions: <Widget>[
               CupertinoDialogAction(
                 onPressed: ()
                 {
                   Navigator.pop(ctx);
                 },
                 child: Text('取消'),
               ),
               CupertinoDialogAction(
                 onPressed: ()
                 {
                   Navigator.pop(ctx);
                   setState(() {
                     widget.photos.removeAt(index);
                   });
                 },
                 child: Text('删除'),
                 textStyle: TextStyle(color: Colors.red),
               ),
             ],
          );
          return dialog;
        }
    );
  }

  void toAddPhoto() {
    showCupertinoModalPopup<int>(
        context: context,
        builder: (ctx) {
          var dialog = CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: Text("取消",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w600),)),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.pop(ctx, 1);
                    getAllPhoto();
                  },
                  child: Text('相册',style: TextStyle(color: Colors.blue))),
              CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.pop(ctx, 2);
                    var imageFile =
                        await ImagePicker.pickImage(source: ImageSource.camera);
                    if (imageFile != null) {
                      setState(() {
                        widget.photos.add(imageFile);
                      });
                    }
                  },
                  child: Text('拍照',style: TextStyle(color: Colors.blue))),
            ],
          );
          return dialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<Widget> photoChildren = [];

    double itemHeight =
        (widget.photoSize - widget.space * (widget.columnCount - 1)) /
            widget.columnCount;

    final double dWidth = MediaQuery.of(context).size.width *
        MediaQuery.of(context).devicePixelRatio;
    final int picSizeWidth = dWidth ~/ 3.6;

    int rows =
        (widget.photos.length + widget.columnCount) ~/ widget.columnCount;

    for (int i = 0; i < rows; i++) {
      List<Widget> rowChildren = [];
      int rowPhotoCount = 0;
      for (int j = i * widget.columnCount;
          j < min(widget.photos.length, (i + 1) * widget.columnCount);
          j++) {
        var photo = widget.photos[j];
        Widget photoWidget;
        if (photo is String) //网络图片
        {
          photoWidget = GestureDetector(
              onTap: () {
                toBrowser(j);
              },
              child: Container(
                  width: itemHeight,
                  height: itemHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border:
                    Border.all(color: Color(0xFFEAEAEA)),
                  ),
                  child:
                      Stack(children: <Widget>[
                        Image.network(
                          photo,
                          color: CupertinoDynamicColor.withBrightness(color: const Color(0xFFFFFFFF), darkColor: Color(0xFFB0B0B0)).resolveFrom(context),
                          colorBlendMode: BlendMode.modulate,
                          width: itemHeight,
                          height: itemHeight,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                            right: 0,
                            child:
                            GestureDetector(
                              onTap: ()
                              {
                                toRemovePhoto(j);
                              },
                              child: Container(
                                  width: 25,
                                  height: 25,
                                  child:Icon(Icons.do_not_disturb_on,size: 20,color: Colors.red,)),
                            ))
                      ],)
                  ));

        } else if (photo is Asset) //本地图片
        {
          photoWidget =
              GestureDetector(
              onTap: () {
                toBrowser(j);
              },
              child:
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border:
                    Border.all(color: Color(0xFFEAEAEA)),
                  ),
                  width: itemHeight,
                  height: itemHeight,
                  child:
                      Stack(children: <Widget>[
                      AssetThumbImage(
                        width: picSizeWidth,
                        height: picSizeWidth,
                        asset: photo,
                      ),
                        Positioned(
                            right: 0,
                            child:
                            GestureDetector(
                              onTap: ()
                              {
                                toRemovePhoto(j);
                              },
                              child: Container(
                                  width: 25,
                                  height: 25,
                                  child:Icon(Icons.do_not_disturb_on,size: 20,color: Colors.red,)),
                            ))
                      ]
                  )
                  )
              );

        } else if (photo is File) //本地图片
        {
          photoWidget = GestureDetector(
              onTap: () {
                toBrowser(j);
              },
              child: Container(
                  width: itemHeight,
                  height: itemHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border:
                    Border.all(color: Color(0xFFEAEAEA)),
                  ),
                  child:
                  Stack(children: <Widget>[
                  Image.file(
                    photo,
                    color: CupertinoDynamicColor.withBrightness(color: const Color(0xFFFFFFFF), darkColor: Color(0xFFB0B0B0)).resolveFrom(context),
                    colorBlendMode: BlendMode.modulate,
                    width: itemHeight,
                    height: itemHeight,
                    fit: BoxFit.cover,
                  ),
                    Positioned(
                        right: 0,
                        child:
                        GestureDetector(
                          onTap: ()
                          {
                            toRemovePhoto(j);
                          },
                          child: Container(
                              width: 25,
                              height: 25,
                              child:Icon(Icons.do_not_disturb_on,size: 20,color: Colors.red,)),
                        ))
                  ]
                  )
              )
          );

        }

        if(photoWidget != null)
        {
          rowPhotoCount++;
          if(j % widget.columnCount == widget.columnCount-1)
            {
              rowChildren.add(Expanded(child: photoWidget));
            }
            else
              {
                rowChildren.add(photoWidget);
              }
        }

        if (j % widget.columnCount != widget.columnCount-1) {
          rowChildren.add(Padding(
            padding: EdgeInsets.only(left: widget.space),
          ));
        }
      }

      if (i == rows - 1 && widget.photos.length < widget.maxCount) {
        Widget addWidget = GestureDetector(
            onTap: () {
              toAddPhoto();
            },
            child: Image.asset(
              'images/common/photo_add_icon.png',
              fit: BoxFit.cover,
              width: itemHeight,
              height: itemHeight,
            ));
        if(rowPhotoCount == widget.columnCount-1)
          {
            rowChildren.add(Expanded(child:addWidget));
          }
        else
          {
            rowChildren.add(addWidget);
          }
      }

      if (rowChildren.isNotEmpty) {
        Row rowWidget = Row(
          children: rowChildren,
        );
        photoChildren.add(Container(
            margin: EdgeInsets.only(top: i == 0 ? 0 : widget.space),
            height: itemHeight,
            child: rowWidget));
      }
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: photoChildren
      ),
    );
  }
}
