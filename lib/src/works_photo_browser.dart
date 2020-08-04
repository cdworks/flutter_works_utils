
import 'package:asset_picker/asset_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:io';

import 'package:toast/toast.dart';

class WorksPhotoBrowser extends StatefulWidget
{
  final int initialIndex;
  final List<Map<String,dynamic>> galleryItems;  //key and data  data 包括本地和网络图片

  const WorksPhotoBrowser(this.initialIndex,this.galleryItems);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WorksPhotoBrowser();
  }

}

class _WorksPhotoBrowser extends State<WorksPhotoBrowser> with SingleTickerProviderStateMixin{

  bool animateComplete = false;

  AnimationController _oriController;
  Animation<double> _animation;

//  @override
//  void initState() {
//    // TODO: implement initState
//    super.initState();

//    _oriController = AnimationController(duration: const Duration(milliseconds: 200), vsync:
//    this);
//    _oriController.addStatusListener((status)
//    {
//
//    });
//    _animation =
//    Tween(begin: 0.0, end: 1.0).animate(_oriController)..addListener((){
//      setState(() {
//
//      });
//    });
//  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
//      animateComplete ?

    GestureDetector(
      onTap: (){
        Navigator.of(context).pop();
      },
        child:
      GalleryPhotoViewWrapper(
        galleryItems: widget.galleryItems,
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        initialIndex: widget.initialIndex,
        loadingChild: Container(width: 50,height: 50,color: Colors.red,),
        scrollDirection: Axis.horizontal,))
//          :
//          PositionedTransition
//      Container(width: screenSize.width + (screenSize
//          .height-screenSize.width)*_animation.value, color:
//      Colors.red, child:
//      AspectRatio(
//        aspectRatio: _controller.value.aspectRatio,
//        child:
//        VideoPlayer(_controller),
//      ))
    ;
  }

}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingChild,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex,
    @required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController =  PageController(initialPage: initialIndex,keepPage:
  true,viewportFraction: 0.9999);

  final Widget loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<Map<String,dynamic>> galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }


}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper>
    with SingleTickerProviderStateMixin{
  int currentIndex;
  double picWidth;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();


  }
  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(

          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: _buildItem,
          itemCount: widget.galleryItems.length,
          backgroundDecoration: widget.backgroundDecoration,
          pageController: widget.pageController,
          onPageChanged: onPageChanged,

          scrollDirection: widget.scrollDirection,
          gaplessPlayback:true,
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index)  {
    final Map<String, dynamic> item = widget.galleryItems[index];

    var photoItem = item['photo'];


    Widget photoChild;
    
    if(photoItem is Asset)
    {
      int width = photoItem.originalWidth;
      int height = photoItem.originalHeight;
      if(width > 4000)
      {
        width = 4000;
        height = (width * photoItem.ration).toInt();
      }
      else if(height >4000)
      {
        height = 4000;
        double dHeight = (height / photoItem.ration);
        height = dHeight.toInt();
      }
      var query = MediaQuery.of(context);
      var picWidth = query.size.width * query.devicePixelRatio;
      photoChild = AssetOriginalImage(
        asset: photoItem,
        fit: BoxFit.contain,
        picSizeWidth: picWidth ~/3.6,
        quality: 80,
        width: width == photoItem.originalWidth ? 0: width,
        height: height == photoItem.originalHeight ? 0: height,
      );
    }
    else if(photoItem  is String)
      {
        String thumbPath;
        if(item.containsKey('thumbPath'))
          {
            thumbPath = item['thumbPath'];
          }
        photoChild = Image.network(photoItem,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return
              Stack(
                children: <Widget>[
                  GestureDetector(
                    onDoubleTap: ()
                    {

                    },
                    child: Image.file(File(thumbPath),fit: BoxFit.fitWidth,width:
                    double.infinity,height: double.infinity,),
                  ),

                  Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white60,
                      strokeWidth: 5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors
                          .blue),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  )
                ],
              );

          },);
        final ImageStream stream = (photoChild as Image).image.resolve
          (ImageConfiguration.empty);
        stream.addListener(ImageStreamListener((_,__){},onError: (dynamic exception, StackTrace stackTrace) {
          Toast.show('下载图片失败！', this.context,gravity: Toast.CENTER,backgroundRadius:
          8);
//          Fluttertoast.showToast(msg:'下载图片失败！', gravity: ToastGravity.CENTER,);
        }));
      }
    else if(photoItem is File)
      {
        photoChild = Image.file(photoItem);
      }
    else
    {
      photoChild = Icon(Icons.insert_photo);  //error !!
    }


    return
      PhotoViewGalleryPageOptions.customChild(
        child: Container(
//        width: asset.originalWidth.toDouble(),
//        height: asset.originalHeight.toDouble(),
            child: photoChild
        ),
//        onTapUp: (BuildContext context,
//            TapUpDetails details,
//            PhotoViewControllerValue controllerValue,)
//        {
//            Navigator.of(context).pop();
//        },
        childSize: Size(MediaQuery.of(context).size.width,MediaQuery.of(context)
            .size.height),
        initialScale: PhotoViewComputedScale.contained,
        minScale:
        PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 3.5,
        heroAttributes: PhotoViewHeroAttributes(tag:photoItem),

      );
  }
}
