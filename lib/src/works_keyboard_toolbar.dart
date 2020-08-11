import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'extension/works_cupertino_dynamicColor_ext.dart';

class ToolBarModel {
  int index;
  FocusNode focusNode;
  ToolBarModel({this.index,this.focusNode});
}
class ToolBar extends StatefulWidget {
  final Map <String,ToolBarModel> focusNodeMap;
  final VoidCallback doneCallback;
  final double height;
  final Color color;
  final Color tintColor;

  ToolBar({this.focusNodeMap,this.doneCallback,this.height=40,this.color = const Color(0xffeeeeee),this.tintColor = Colors.blue});

  @override
  State<StatefulWidget> createState() {
    return ToolBarState();
  }
}
class ToolBarState extends State<ToolBar>{
//  Map <String,ToolBarModel> focusNodeMap;
//  VoidCallback doneCallback;
//  double height=40;
//  Color color = Color(0xffeeeeee);
//  Color tintColor = Colors.blue;

  StreamSubscription<bool> _keyStream;


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(_keyStream != null)
      {
        _keyStream.cancel();
      }
  }

  @override
    initState()
  {
    super.initState();
    _keyStream = KeyboardVisibility.onChange.listen((bool visible) {
      if(!visible) {
        widget.doneCallback();
      }
    });
  }

  ToolBarState();
  @override
  Widget build(BuildContext context) {
    ToolBarModel barModel = currentEditingFocusNode();
    if(barModel == null){
      // 没有任何输入框处于编辑状态，则返回的是0高度的容器
      return Column(children: <Widget>[
        Flexible(child: Container()),
        Container(height: 0)
      ],
      );
    }else{
      return Column(children: <Widget>[
        Flexible(child: Container()),
        createToolBar(barModel)
      ],
      );
    }
  }
  Widget createToolBar(ToolBarModel barModel){

    Widget doneBtn = CupertinoButton(
        minSize: 20,
        padding: EdgeInsets.zero,
        child: Text('确定',style: TextStyle(color: widget.tintColor),),
        onPressed: widget.doneCallback
    );

    if(widget.focusNodeMap.length < 2)
      {
        return Container(
          height: widget.height,color: widget.color,
          padding: EdgeInsets.only(right: 10),
          child: Row(
            children: <Widget>[
              Flexible(child: Container(),),
              doneBtn
            ],
          ),
        );
      }

    // 有输入框在编辑状态
    int currentIndex = barModel.index;
    bool isFirst = currentIndex==0;
    bool isLast = currentIndex==(widget.focusNodeMap.length-1);
    // 前一个
    Widget preIcon = Icon(Icons.arrow_forward_ios,
      color: isFirst?Colors.grey:widget.tintColor,size: 20.0,);
    Widget preBtn = CupertinoButton(
//      minSize: 20,
      padding: EdgeInsets.zero,
      child:Transform(
          transform: Matrix4.identity()..rotateZ(math.pi),// 旋转的角度
          origin: Offset(10,10),
          child: preIcon
      ),
      onPressed: (){
        focusNodeAtIndex(currentIndex-1);
      },
    );
    // 下一个
    Widget nextBtn = CupertinoButton(
//      minSize: 20,
      padding: EdgeInsets.zero,
      child:Icon(Icons.arrow_forward_ios,
        color:isLast?Colors.grey:widget.tintColor,
        size: 20,),
      onPressed:(){
        focusNodeAtIndex(currentIndex+1);
      },
    );

    // 关闭
    // Widget doneBtn = CupertinoButton(
    //   child: Container(height: 40,width: 200,child: Text('关闭')),
    //   onPressed: doneCallback
    // );


    return Container(
      height: widget.height,color: widget.color,
      padding: EdgeInsets.only(right: 10),
      child: Row(
        children: <Widget>[
          preBtn,
          SizedBox(width: 20,),
          nextBtn,
          Flexible(child: Container(),),
          doneBtn
        ],
      ),
    );
  }
  // 获取当前获得焦点的对象
  ToolBarModel currentEditingFocusNode(){
    for(ToolBarModel barModel in widget.focusNodeMap.values){
      if(barModel.focusNode.hasFocus){
        return barModel;
      }
    }
    return null;
  }
  /// 让指定的某个node获得焦点
  void focusNodeAtIndex(int selectIndex){
    if(selectIndex<0||selectIndex>=widget.focusNodeMap.length){
      return;
    }
    for(ToolBarModel barModel in widget.focusNodeMap.values){
      if(selectIndex == barModel.index){
        barModel.focusNode.requestFocus();
        setState(() {

        });
        return;
      }
    }
  }
}

/// 用于持有FocusNode的类
class BlankToolBarModel {
  // 点击空白部分用于响应的FocusNode
  FocusNode blankModel=FocusNode();
  // 保存页面中所有InputText绑定的FocusNode
  Map<String,ToolBarModel> focusNodeMap={};

  FocusNode _currentEditingNode;
  // 用于外侧的回调
  VoidCallback outSideCallback;
  BlankToolBarModel({this.outSideCallback});

  /// 通过一个key获取node，一般是通过TextEditingController对象的hashCode
  /// TextEditingController nickNameController = TextEditingController();
  /// String key = nickNameController.hashCode.toString();
  /// FocusNode focusNode = blankToolBarModel.getFocusNode(key);
  FocusNode getFocusNode(String key){
    ToolBarModel barModel = focusNodeMap[key];
    if(barModel == null){
      barModel = ToolBarModel(index: focusNodeMap.length,focusNode: FocusNode());
      barModel.focusNode.addListener(focusNodeListener);
      focusNodeMap[key] = barModel;
    }
    return barModel.focusNode;
  }
  /// 通过controller获取focusNode
  FocusNode getFocusNodeByController(TextEditingController controller){
    String key = controller.hashCode.toString();
    return getFocusNode(key);
  }
  /// 找到正处于编辑状态的FocusNode
  FocusNode findEditingNode(){
    for(ToolBarModel barModel in focusNodeMap.values){
      if(barModel.focusNode.hasFocus){
        return barModel.focusNode;
      }
    }
    return null;
  }
  // 监听FocusNode变化
  Future<Null> focusNodeListener() async {
    FocusNode editingNode = findEditingNode();
    if(_currentEditingNode != editingNode){
      _currentEditingNode = editingNode;
//      print('>>>>>>>>+++++++++++');
      if(outSideCallback != null){
        outSideCallback();
      }
    }else{
//      print('>>>>>>>>----------');
    }

  }
  /// 移除所有监听
  void removeFocusListeners(){
    for(ToolBarModel barModel in focusNodeMap.values){
      barModel.focusNode.removeListener(focusNodeListener);
    }
  }
  /// 关闭键盘
  void closeKeyboard(BuildContext context){
    FocusScope.of(context).requestFocus(blankModel);
  }
}
/// 增加
/// 1、自动处理点击空白页面关闭键盘，
/// 2、键盘上方增加一个toolbar
class BlankToolBarTool{
  static Widget blankToolBarWidget(
      // 上下文
      BuildContext context,
      {
        // 数据model
        BlankToolBarModel model,
        // 要展示的子内容
        Widget body,
        // 是否展示toolBar
        bool showToolBar = true,
        // 默认的toolBar的高度
        double toolBarHeight = 40,
        // toolBar的背景色
        Color toolBarColor = const Color(0xffeeeeee),
        // toolBar的可点击按钮的颜色
        Color toolBarTintColor = Colors.blue
      }
      ){
    if(!showToolBar){
      return GestureDetector(
        onTap: (){
          model.closeKeyboard(context);
        },
        child: body,
      );
    }
    return Stack(
      children: <Widget>[
        Positioned(top: 0,left: 00,bottom: 0,right: 0,child:
        GestureDetector(
          onTap: (){
            model.closeKeyboard(context);
          },
          child: body,
        ),
        ),
        Positioned(top: 0,left: 0,bottom: 0,right: 0,child:
        ToolBar(height: toolBarHeight,
          color: toolBarColor.toInvertDynamicColor().resolveFrom(context),
          tintColor: toolBarTintColor,
          focusNodeMap: model.focusNodeMap,
          doneCallback: (){
            // 点击空白处的处理
            model.closeKeyboard(context);
          },)
        ),
      ],
    );
  }
}