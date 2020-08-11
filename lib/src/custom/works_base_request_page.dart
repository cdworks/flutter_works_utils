

import 'dart:async';


import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:toast/toast.dart';
import '../net/works_http_manager.dart';
import '../extension/works_cupertino_dynamicColor_ext.dart';


abstract class WorksBaseRequestPageState <T extends StatefulWidget> extends State<T>
{

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool showNoNetWidget = false;
  bool showNoDataWidget = false;


  @protected
  Color get  noNetBgColor => const Color(0xFFFFFFFF);

  @protected
  Color get  noDataBgColor => const Color(0xFFFFFFFF);

  @protected
  String get noNetIcon => null;  //不设置默认

  @protected
  String get noDataIcon => null;  //不设置默认

  @protected
  EdgeInsetsGeometry get tipsPagePadding => EdgeInsets.zero;  //无网络或者无数据提示页面的边距  默认所有边距为0


  @protected
  String get noDataInfo => '暂无数据!';

  @protected
  Widget  noDataWidget(BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(noDataIcon ?? 'utilImages/no_data.png',package: noDataIcon == null ? 'works_utils':null,width: 64,height: 64,),
        Text( noDataInfo,textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFFAAAAAA),fontSize: 15),),
      ]
  );


  @protected
  Widget noNetActionWidget(BuildContext context,VoidCallback requestCallback) => Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Image.asset(noNetIcon ?? 'utilImages/no_net.png',package: noNetIcon == null ? 'works_utils':null,width: 64,height: 64,),
      Text( '网络连接错误，请检查网络!',textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFFAAAAAA),fontSize: 15),),
      Container(
        margin: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
//                            color: Colors.white,
          border: Border.all(
              width: 1, color: const Color(0xFF4FD27D)),
          borderRadius:
          BorderRadius.all(Radius.circular(5)),
        ),
        child: CupertinoButton(
          minSize: 35,
          padding: EdgeInsets.only(left: 8,right: 8,top: 0,bottom: 2),
          onPressed: ()
          {
            if(mounted)
            {
              reRequestData();
            }
          },
          child: Text( '点击重试',textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFF4FD27D),fontSize: 15),),
        ),
      )
      ,
      Padding(padding: EdgeInsets.only(top: 45),),
    ],);

  @protected
  void reRequestData()
  {
    Connectivity().checkConnectivity().then((status) {
      if(status == ConnectivityResult.none)
      {
        Toast.show('网络开小差了!', context,gravity: Toast.CENTER,backgroundRadius: 8,duration: Toast.LENGTH_LONG);
      }
      else
      {
        setState(() {
          showNoNetWidget = false;
        });
        requestMainData();
      }
    });
  }

  @protected
  Widget createMainView(BuildContext context);

  @protected
  Future<void> requestMainData();

  void _setAutoReloadData()
  {
    Connectivity().checkConnectivity().then((status)
    {
      if(status == ConnectivityResult.none)
      {
        if(mounted)
        {
          setState(() {
            showNoNetWidget = true;
          });
          _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult status1) {
            // Got a new connectivity status!
            if (status1 == ConnectivityResult.mobile || status1 == ConnectivityResult.wifi) {
              if(mounted)
              {
                setState(() {
                  showNoNetWidget = false;
                });
              }
              requestMainData();
            }
          });
        }

      }
      else{
        requestMainData();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setAutoReloadData();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
    Stack(
      children: [
        createMainView(context),
        if(showNoDataWidget)
          Container(
            margin: tipsPagePadding,
            color: (noDataBgColor ?? const Color(0xFFFFFFFF)).toInvertDynamicColor().resolveFrom(context),
            child: Center(
                child:noDataWidget(context)
            )),
        if(showNoNetWidget)
          Container(
            margin: tipsPagePadding,
            color: (noNetBgColor ?? const Color(0xFFFFFFFF)).toInvertDynamicColor().resolveFrom(context),
            child: Center(
                child:noNetActionWidget(context,reRequestData)
            ),)
      ],
    );

//      !showNoNetWidget ? !showNoDataWidget ?
//      createMainView(context) : Container(
//        margin: tipsPagePadding,
//          color: noDataBgColor ?? const Color(0xFFFFFFFF),
//          child: Center(
//              child:noDataWidget(context)
//          )) :
//      Container(
//        margin: tipsPagePadding,
//        color: noNetBgColor ?? const Color(0xFFFFFFFF),
//        child: Center(
//            child:noNetActionWidget(context,reRequestData)
//        ),);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}


///不带分页的listView 特别注意，CupertinoPageScaffold一定要加上 ProgressHUD

abstract class WorksBaseListWidgetState <T extends StatefulWidget> extends WorksBaseRequestPageState<T>
{

  String requestUrl;
  Map<String, dynamic> requestParam;
  List data;

  IndexedWidgetBuilder dividerBuilder;  //list divider 为null则不要分割线
  WidgetBuilder tableHeaderBuilder; //listView 的头部widget 跟随滚动
  WidgetBuilder tableFooterBuilder;  //listView 的尾部widget 跟随滚动

  WidgetBuilder headerBuilder;  //头部widget 不滚动
  WidgetBuilder footerBuilder;  //尾部widget 不滚动
  final ScrollController controller = ScrollController();

  @protected
  bool get dataContainerTotalField => false;  //根据http请求数据是否包含total字段,也就是data就是数组，常规的是

  @protected
  Widget createCell(BuildContext context,int index);  //list item

  @protected
  int  get itemCount => (data == null ? 0 : data.length);  //list item count 不包括头部和尾部，默认为data.length

  @protected
  Offset dividerOffset(BuildContext context,int index) => Offset(16,16);  //dx start  dy end

  @protected
  Color dividerColor(BuildContext context,int index) => const Color(0xFFF0F2F5);  //divider color

  @protected
  ObjConvertCallback get convert;   //请求的数据转换方法（一般是字典转对象）

  @protected
  HttpSendType get sendType => HttpSendType.Post;


  @override
  Widget createMainView(BuildContext context) {
    // TODO: implement createMainView

    int totalCount = itemCount;

    if(tableHeaderBuilder != null)
    {
      totalCount++;
    }
    if(tableFooterBuilder != null)
    {
      totalCount++;
    }

    final listView = dividerBuilder == null ?  ListView.builder(
      controller: controller,
      itemBuilder: (ctx,index)
    {
      int realIndex = index;
      if(tableHeaderBuilder != null)
      {
        realIndex = index - 1;
      }
      if(realIndex < 0)
      {
        return tableHeaderBuilder(ctx);
      }
      if(realIndex >= itemCount)
      {
        return tableFooterBuilder(ctx);
      }
      return createCell(ctx, realIndex);

    },itemCount: totalCount,) : ListView.separated(
      controller: controller,
        itemBuilder: (ctx,index)
    {
      int realIndex = index;
      if(tableHeaderBuilder != null)
      {
        realIndex = index - 1;
      }
      if(realIndex < 0)
      {
        return tableHeaderBuilder(ctx);
      }
      if(realIndex >= itemCount)
      {
        return tableFooterBuilder(ctx);
      }
      return createCell(ctx, realIndex);

    }, separatorBuilder: dividerBuilder, itemCount: totalCount);

    return (headerBuilder == null && footerBuilder == null) ?
    EasyRefresh(
        onRefresh: () async{
          await requestMainDataWithRefresh(isRefresh: true);
        }, child:listView) :
    Column(
      children: [
        if(headerBuilder != null)
          headerBuilder(context),
        Expanded(child: EasyRefresh(
            onRefresh: () async{
              await requestMainData();
            }, child:listView),),
        if(footerBuilder != null)
          footerBuilder(context),
      ],
    );
  }

  Future<void> requestMainDataWithRefresh({bool isRefresh = false}) async
  {
    if(requestUrl == null || requestUrl.isEmpty)
      return;

    setState(() {
      showNoDataWidget = false;
      showNoNetWidget = false;
    });

    final progress = ProgressHUD.of(context);
    if(!isRefresh)
    {
      if(progress.mounted)
        progress.dismiss();
      progress.showWithText('请稍后');
    }
    var response = await HttpManager.requestDataWithURL(
        urlString: requestUrl,
        dataType: dataContainerTotalField ? ResponseDataType.PageListData  : ResponseDataType.ListData,
        param: requestParam ?? Map<String, dynamic>(),
        convert: convert,
        sendType: sendType
    );

    if(!isRefresh && progress.mounted)
    {
      progress.dismiss();
    }

    if(!mounted)
      return;

    if (response.error == null) {

      if(dataContainerTotalField)
      {
        data = (response?.data as PageListData).list;
      }
      else {
        data = response.data;
      }
      setState(() {
        if(data == null || data.isEmpty)
        {
          showNoDataWidget = true;
        }
        else
        {
          showNoDataWidget = false;
        }
      });

    }
    else if(!isRefresh)
    {
      if(response.error.code == -100)
      {
        setState(() {
          showNoNetWidget = true;
        });
      }
      else
      {
        Toast.show(response.error.localizedDescription, context,gravity: Toast.CENTER,backgroundRadius: 8,duration: Toast.LENGTH_LONG);
      }
    }
    else
    {
      Toast.show('刷新失败,请检查网络!', context,gravity: Toast.CENTER,backgroundRadius: 8,duration: Toast.LENGTH_LONG);
    }
  }

  @override
  Future<void> requestMainData() async {
    // TODO: implement requestMainData

    await requestMainDataWithRefresh();
  }
}


///带分页的listView 特别注意，CupertinoPageScaffold一定要加上 ProgressHUD

abstract class WorksBasePageListWidgetState <T extends StatefulWidget> extends WorksBaseRequestPageState<T>
{
  String requestUrl;
  Map<String, dynamic> requestParam;
  List data;
  bool _hasMore = false;

  IndexedWidgetBuilder dividerBuilder;  //list divider 为null则不要分割线
  WidgetBuilder tableHeaderBuilder; //listView 的头部widget 跟随滚动
  WidgetBuilder tableFooterBuilder;  //listView 的尾部widget 跟随滚动

  WidgetBuilder headerBuilder;  //头部widget 不滚动
  WidgetBuilder footerBuilder;  //尾部widget 不滚动

  final ScrollController controller = ScrollController();



  @protected
  Widget createCell(BuildContext context,int index);  //list item

  @protected
  int  get itemCount => (data == null ? 0 : data.length);  //list item count 不包括头部和尾部，默认为data.length

  @protected
  Offset dividerOffset(BuildContext context,int index) => Offset(16,16);  //dx start  dy end

  @protected
  Color dividerColor(BuildContext context,int index) => const Color(0xFFF0F2F5);  //divider color

  @protected
  ObjConvertCallback get convert;   //请求的数据转换方法（一般是字典转对象）

  @protected
  HttpSendType get sendType => HttpSendType.Post;


//  @protected
//  Widget createDivider(BuildContext context,int index) => Divider(
//    thickness: 1,
//    height: 1,
//    indent: dividerOffset(context, index).dx,
//    endIndent: dividerOffset(context, index).dy,
//    color: dividerColor(context,index),
//  );  //list divider 为null则不要分割线

  @override
  void initState() {
    // TODO: implement initState
    data = [];
    _hasMore = false;

    dividerBuilder =   (BuildContext context, int index) =>  Divider(
      thickness: 1,
      height: 1,
      indent: dividerOffset(context, index).dx,
      endIndent: dividerOffset(context, index).dy,
      color: dividerColor(context,index).toInvertDynamicColor().resolveFrom(context),
    );

    super.initState();

  }

  @protected
  int get pageNumber => 20;  //每页的数量


  @override
  Future<void> requestMainData() async{
    // TODO: implement requestMainData



    if(requestUrl == null || requestUrl.isEmpty)
      return;




    setState(() {
      showNoDataWidget = false;
      showNoNetWidget = false;
      data = [];
    });

    final progress = ProgressHUD.of(context);
    if(progress.mounted)
      progress.dismiss();
    progress.showWithText('请稍后');


    Map<String, dynamic> parameter = requestParam == null ? Map<String, dynamic>(): requestParam;
    parameter['page'] = 1;
    parameter['limit'] = pageNumber;

    var response = await HttpManager.requestDataWithURL(
        urlString: requestUrl,
        dataType:  ResponseDataType.PageListData ,
        param: parameter,
        convert: convert,
        sendType: sendType
    );

    if(progress.mounted)
        progress.dismiss();

    if(!mounted)
      return;

    if (response.error == null) {

      data.clear();

      var list = (response?.data as PageListData)?.list;

      int total = (response?.data as PageListData)?.total;



      setState(() {

        if(list != null && list.isNotEmpty)
        {
          data.addAll(list);
        }

        if(data.isEmpty)
        {
          showNoDataWidget = true;
        }
        else
        {
          showNoDataWidget = false;
        }

        _hasMore = total == null ? false : data.length < total;

      });

    }
    else if(response.error.code == -100)
    {
      if (mounted) {
        setState(() {
          showNoNetWidget = true;
        });
      }
    }
    else
    {
      Toast.show(response.error.localizedDescription, context,gravity: Toast.CENTER,backgroundRadius: 8,duration: Toast.LENGTH_LONG);
    }
  }

  @override
  Widget createMainView(BuildContext context) {
    // TODO: implement createMainView
    int totalCount = itemCount;

    if(tableHeaderBuilder != null)
    {
      totalCount++;
    }
    if(tableFooterBuilder != null)
    {
      totalCount++;
    }

    final listView = dividerBuilder == null ?  ListView.builder(
      controller: controller,
      itemBuilder: (ctx,index)
    {
      int realIndex = index;
      if(tableHeaderBuilder != null)
      {
        realIndex = index - 1;
      }
      if(realIndex < 0)
      {
        return tableHeaderBuilder(ctx);
      }
      if(realIndex >= itemCount)
      {
        return tableFooterBuilder(ctx);
      }
      return createCell(ctx, realIndex);

    },itemCount: totalCount,) : ListView.separated(
      controller: controller,
        itemBuilder: (ctx,index)
    {
      int realIndex = index;
      if(tableHeaderBuilder != null)
      {
        realIndex = index - 1;
      }
      if(realIndex < 0)
      {
        return tableHeaderBuilder(ctx);
      }
      if(realIndex >= itemCount)
      {
        return tableFooterBuilder(ctx);
      }
      return createCell(ctx, realIndex);

    }, separatorBuilder: dividerBuilder, itemCount: totalCount);

    return (headerBuilder == null && footerBuilder == null) ?
    EasyRefresh(
        onLoad: _hasMore ? () async
        {
          int index = (data.length/pageNumber).ceil() + 1;
          await requestDataWithPageIndex(index);
        } : null,
        onRefresh: () async{
          await requestDataWithPageIndex(1);
        }, child:listView) :
    Column(
      children: [
        if(headerBuilder != null)
          headerBuilder(context),
        Expanded(child: EasyRefresh(
            onLoad: _hasMore ? () async
            {
              int index = (data.length/pageNumber).ceil() + 1;
              await requestDataWithPageIndex(index);
            } : null,
            onRefresh: () async{
              await requestDataWithPageIndex(1);
            }, child:listView),),
        if(footerBuilder != null)
          footerBuilder(context),
      ],
    );
  }

  Future<void> requestDataWithPageIndex(int pageIndex) async{

    if(requestUrl == null || requestUrl.isEmpty)
      return;

    Map<String, dynamic> parameter = requestParam == null ? Map<String, dynamic>(): requestParam;
    parameter['page'] = pageIndex;
    parameter['limit'] = pageNumber;

    // TODO: implement requestMainData
    var response =  await HttpManager.requestDataWithURL(
        urlString: requestUrl,
        dataType:  ResponseDataType.PageListData ,
        param: parameter,
        convert: convert,
        sendType: sendType
    );

    if(!mounted)
      return;
    if (response.error == null) {
      var list = (response?.data as PageListData)?.list;

      int total = (response?.data as PageListData)?.total;
      if(pageIndex == 1)
      {
        this.data.clear();
      }
      setState(() {

        if(list != null && list.isNotEmpty)
        {
          data.addAll(list);
        }

        showNoDataWidget = this.data.isEmpty;
        _hasMore = total == null ? false : data.length < total;
      });
    }
    else if(pageIndex == 1)
    {
      Toast.show('刷新数据失败，请检查网络!', context,gravity: Toast.CENTER,backgroundRadius: 8,duration:Toast.LENGTH_LONG);
    }
  }

}
