

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../extension/works_cupertino_dynamicColor_ext.dart';
import '../../works_utils.dart';

void showWorksPickerView(BuildContext context, {@required ValueChanged<int> onSelectedItemChanged,
      @required List<String> data,@required VoidCallback onCancel ,int initialIndex = 0,
      double fontSize = 17,
      double size = 236,
      double itemHeight = 38,
  Color bgColor = const Color(0xFFF0F2F5)})
{
  Navigator.of(context).push(WorksPopupRoute(child: WorksPickerView(onSelectedItemChanged: (index)
    {
      if(onSelectedItemChanged != null)
      { onSelectedItemChanged(index);}
      Navigator.of(context).maybePop();

    },
    fontSize: fontSize,
    size: size,
    itemHeight: itemHeight,
      data: data, onCancel: ()
    {
      if(onCancel != null)
      { onCancel();}
      Navigator.of(context).maybePop();
    },initialIndex: initialIndex,bgColor: bgColor,)));
}



class WorksPickerView extends StatefulWidget
{

  final ValueChanged<int> onSelectedItemChanged;
  final VoidCallback onCancel;
  final List<String>data;
  final int initialIndex;
  final Color bgColor;

  final double fontSize;
  final double size;
  final double itemHeight;

  const WorksPickerView({@required this.onSelectedItemChanged,@required this
      .data,@required this.onCancel,this.initialIndex = 0,this.bgColor = const Color(0xFFF0F2F5),this.fontSize = 17,this.size = 236,this.itemHeight = 38});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WorksPickerView();
  }
}

class _WorksPickerView extends State<WorksPickerView> with SingleTickerProviderStateMixin
{

  FixedExtentScrollController _controller;
  bool isCancel;
  AnimationController _oriController;
  Animation<Offset> _animation;

  @override
  void initState() {
    // TODO: implement initState
    _controller = FixedExtentScrollController(initialItem: widget
        .initialIndex);

    _oriController = AnimationController(duration: const Duration
      (milliseconds: 200), vsync:
    this);
    _animation =
    Tween(begin: Offset(0.0,235.0), end: Offset.zero).animate(_oriController)
      ..addListener
      ((){
      setState(() {

      });
      if(_oriController.status == AnimationStatus.dismissed)
      {
        if(isCancel) {
          widget.onCancel();
        }
        else
          {
            widget.onSelectedItemChanged(_controller.selectedItem);
          }
      }
    });
    super.initState();
    _oriController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.transparent,
      alignment: Alignment.bottomLeft,
      child:
      Transform.translate(offset: _animation.value, child:
      Container
        (
        height: widget.size,
        child:
            Column(children: <Widget>[
              Container(
                height: 36,
                padding: EdgeInsets.only(left: 15,right: 15),
                color: widget.bgColor.toInvertDynamicColor().resolveFrom(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CupertinoButton(
                      onPressed: (){
                        isCancel = true;
                        _oriController.reverse();
                      },
                      padding: EdgeInsets.zero,
                      minSize: 35,
                      child: Text('取消'),
                    ),
                    CupertinoButton(
                      onPressed:()
                      {
                        isCancel = false;
                        _oriController.reverse();

                      },
                      padding: EdgeInsets.zero,
                      minSize: 35,
                      child: Text('确定'),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child:
                  CupertinoPicker.builder(
                    backgroundColor: Colors.white,
                    itemExtent: widget.itemHeight,
                    itemBuilder: (BuildContext context, int index) {
                      return Center(child:Text(widget.data[index],style: TextStyle(fontSize: widget.fontSize)));
                    },
                    childCount: widget.data.length,
                    scrollController: _controller,
                  ),
                  )
            ],)
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _oriController.dispose();
  }

}

