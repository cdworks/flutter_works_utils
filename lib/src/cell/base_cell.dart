
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../extension/works_cupertino_dynamicColor_ext.dart';

class BaseCell extends StatefulWidget
{
  final Color selectedColor;
  final Color highlightColor;
  final Color normalColor;
  final bool  selected;
  final Widget child;
  final GestureTapCallback tapCallback;
  final GestureLongPressCallback longPressCallback;
  final ValueChanged<bool> onHighlightChanged;

  const BaseCell({@required this.child,
    this.tapCallback,
    this.longPressCallback,this.normalColor = Colors.white, this.onHighlightChanged,
    this.selectedColor =  Colors.white,
    this.highlightColor = const Color(0xFFEAEAEA),this.selected = false}
      ): assert(child != null);

  @override
  State<StatefulWidget> createState() => _BaseCell();


}

class _BaseCell extends State<BaseCell>
{

  bool isHiLight = false;

//  Color getBgColor()
//  {
//    if(widget.selected) {
//      return widget.selectedColor;
//    }
//
//    return isHiLight ? widget.highlightColor:widget.normalColor;
//
//  }
//


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return GestureDetector(
      onTapDown: (TapDownDetails details)
      {
        if(!widget.selected)
          {
            setState(() {
              isHiLight = true;
              if(widget.onHighlightChanged != null)
              {
                widget.onHighlightChanged(true);
              }
            });
          }

      },
      onTapCancel: ()
      {

        if(!widget.selected) {
          if(widget.onHighlightChanged != null)
          {
            widget.onHighlightChanged(false);
          }
          if(mounted) {
            setState(() {
              isHiLight = false;
            });
          }
        }
        else {
          if (mounted) {
            setState(() {
              isHiLight = false;
            });
          }
        }
      },
      onTapUp: (TapUpDetails details)
      {

        if(!widget.selected) {
          if(widget.onHighlightChanged != null)
          {
            widget.onHighlightChanged(false);
          }
          
          Future.delayed(Duration(milliseconds: 50),(){
            if (mounted) {
              setState(() {
                isHiLight = false;
              });
            }
          });

        }
        else
        {
          if(mounted) {
            setState(() {
              isHiLight = false;
            });
          }
        }
      },
      onTap: widget.tapCallback,
      onLongPress: widget.longPressCallback,
      behavior: HitTestBehavior.opaque,
      child: Container(
          color: widget.selected ? widget.selectedColor.toInvertDynamicColor().resolveFrom(context) : isHiLight ?
          widget.highlightColor.toInvertDynamicColor().resolveFrom(context) : widget.normalColor.toInvertDynamicColor().resolveFrom(context), 
          child: widget.child),
    );
  }
}