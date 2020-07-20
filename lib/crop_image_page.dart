
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:image_crop/image_crop.dart';
import 'package:simple_image_crop/simple_image_crop.dart';
import 'package:works_utils/works_cupertino_navigation_bar.dart';
import 'package:works_utils/works_utils.dart';

class CropImagePageScaffold extends CupertinoPageScaffold {

  final File imageFile;
  final Color titleColor;

  final WorksChangeNotifier useChangeNotifier = WorksChangeNotifier();

  ObstructingPreferredSizeWidget get navigationBar =>
      WorksCupertinoNavigationBar(
        border: null,
        middle:  Text(
          '图片裁剪',
          style: TextStyle(color: titleColor)),
        trailing: CupertinoButton(
          child: Text('使用',style: TextStyle(color: titleColor),),
          padding: EdgeInsets.zero,
          minSize: 30,
          onPressed: () {
            useChangeNotifier.notifyListeners();
          },
        ),
      );

   CropImagePageScaffold(this.imageFile,{this.titleColor = Colors.white})
      : assert(imageFile != null), super(child: const Text(''));

  @override
  // TODO: implement child
  Widget get child =>  SafeArea(top: true, child: MainWidget(this.imageFile,this.useChangeNotifier));
}

class MainWidget extends StatefulWidget {
  const MainWidget(this.imageFile,this.useChangeNotifier);
  final WorksChangeNotifier useChangeNotifier;
  final File imageFile;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainWidget();
  }
}

class _MainWidget extends State<MainWidget> {

  final cropKey = GlobalKey<ImgCropState>();


  Future<void> toCrop()
  async {
//    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;
    if (area == null) {
      // cannot crop, widget is not setup
      Navigator.of(context).pop();
      return;
    }

    final crop = cropKey.currentState;
    final options = await ImageCrop.getImageOptions(file: widget.imageFile);
//    print('size:${options.width},${options.height}  scale:${crop.scale}');
////    crop.scale *
    final croppedFile =
    await crop.cropCompleted(widget.imageFile, pictureQuality: max(options.width * crop.scale.toDouble(), options.height * crop.scale.toDouble()).round());

    if(croppedFile != null)
    {
      Navigator.of(context).pop(croppedFile);
    }
    else
      {
        Navigator.of(context).pop();
      }

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Container(
        color: Colors.black,child:ImgCrop(
      key: cropKey,
      chipRadius: 120,  // crop area radius
      chipShape: 'rect', // crop type "circle" or "rect"
      image: FileImage(widget.imageFile), // you selected image file
    ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.useChangeNotifier.addListener(toCrop);
  }

  @override
  void didUpdateWidget(MainWidget oldWidget) {
    // TODO: implement didUpdateWidget

    if(oldWidget.useChangeNotifier != widget.useChangeNotifier)
    {
      oldWidget.useChangeNotifier.removeListener(toCrop);
      widget.useChangeNotifier.addListener(toCrop);
    }

    super.didUpdateWidget(oldWidget);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.useChangeNotifier.removeListener(toCrop);
  }

}
