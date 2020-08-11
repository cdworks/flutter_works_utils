

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../extension/works_cupertino_dynamicColor_ext.dart';


class WorksSearchBar extends StatefulWidget
{
  final ValueChanged<String> textDidChange;
  final VoidCallback cancelButtonClicked;
  final ValueChanged<String> searchButtonClicked;
  final VoidCallback didBeginEditing;
  final VoidCallback didEndEditing;
  final EdgeInsetsGeometry padding;
  final String placeHold;
  final Color cursorColor;
  final TextStyle placeHoldStyle;
  final TextStyle style;
  final bool isShowCancel;
  final TextEditingController controller;
  const WorksSearchBar({this.textDidChange,this.cancelButtonClicked,this
      .searchButtonClicked,this.didBeginEditing,this.didEndEditing,this
      .padding,this.cursorColor,this.placeHold,this.placeHoldStyle,this
      .style,this.isShowCancel = true,this.controller});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WorksSearchBar();
  }

}

class _WorksSearchBar extends State<WorksSearchBar>
{

  TextEditingController _controller;

  final FocusNode focusNode = FocusNode();

  void onSearchTextChanged(String text) {
    if(widget.textDidChange != null) {
      widget.textDidChange(text);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = widget.controller ??
    TextEditingController();
    focusNode.addListener((){

      if(focusNode.hasFocus && widget.didBeginEditing != null)
        {
          widget.didBeginEditing();
        }
      else if(!focusNode.hasFocus && widget.didEndEditing != null)
        {
          widget.didEndEditing();
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: CupertinoTextField(

              prefix: Padding(padding: EdgeInsets.only(left: 6), child: Image.asset('utilImages/search_icon.png',width: 22,
                height: 22,alignment: Alignment.centerRight,package: 'works_utils',)),
              placeholder: widget.placeHold ?? '搜索',
              suffix: CupertinoButton(
                padding:  EdgeInsets.only(right: 5),
                  minSize: 20,
                  child: Icon(Icons.cancel,color: Colors
                  .black26,size: 20,), onPressed: () {
                  if(_controller.text.isNotEmpty)
                    {

                      WidgetsBinding.instance.addPostFrameCallback((_) => _controller.clear());
                      onSearchTextChanged('');

                    }

//
              },),
              suffixMode: OverlayVisibilityMode.editing,
              textInputAction: TextInputAction.search,
              placeholderStyle: widget.placeHoldStyle ??  TextStyle(
                fontSize: 14,
                color: Color.fromARGB(76, 60, 60, 67).toInvertDynamicColor().resolveFrom(context),
              ),
              style: widget.style ??  TextStyle(
                fontSize: 14,
                color: Color(0xFF333333).toInvertDynamicColor().resolveFrom(context),
              ),
              padding: widget.padding ?? EdgeInsets.all(6),
              cursorColor: widget.cursorColor ?? Colors.blue,
              decoration: BoxDecoration(
                color:  Color(0xFFF0F2F5).toInvertDynamicColor().resolveFrom(context),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              controller: _controller,
              onChanged: onSearchTextChanged,
              onEditingComplete: ()
              {
                 focusNode.unfocus();
                 if(widget.searchButtonClicked != null)
                   {
                     widget.searchButtonClicked(_controller.text);
                   }
              },
              focusNode: focusNode,
            ),
          ),


          Offstage(
              offstage: !widget.isShowCancel,
              child:
              Container(
                margin: EdgeInsets.only(left: 10),
                child:
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 20,
                  onPressed: () {
                    focusNode.unfocus();
                    if (_controller.text.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _controller.clear();
                        onSearchTextChanged('');
                      }
                      );
                    }
                    if(widget.cancelButtonClicked != null) {
                      widget.cancelButtonClicked();
                    }
                  },
                  child: Text('取消', style: TextStyle(color: Colors.blue),),
                ),
              )
          )
        ],
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}
