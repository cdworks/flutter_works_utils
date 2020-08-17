# works_utils

常用功能封装的dart包.

# 目前包含的功能

- 具有ios tableview 点击item变灰效果的BaseCell
- dio网络请求封装
- 一些工具类合集，目前包括日期格式转换，类似银行卡的数字分开显示
- 头像裁剪
- 一些改写的系统组件，包括cupertino风格的导航栏 textfield ActivityIndicator
- 一些系统类的扩展，目前仅有color类的扩展（extension）
- 文件缓存的工具类
- 使用键盘的组件增加完成取消，以及自动跳到下一个有输入焦点
- 添加图片控件封装
- 网络请求页面基类，包括无网提示，有网自动请求。分页请求列表基类。不分页列表基类。
- 视频播放器封装

##usage

# 引入

```yaml
  dependencies:
    flutter:
      sdk: flutter
    works_utils:
    #本地路径
      path: /**/flutter_works_utils
#或者git地址
#	  git:
#       url: git://github.com/cdworks/flutter_works_utils.git
```

# 示例

```dart

//BaseCell用法
const BaseCell(
	{@required this.child,
    this.tapCallback, //点击回调
    this.longPressCallback,  //长按回调
    this.normalColor = Colors.white,  //正常背景
    this.onHighlightChanged,  //高亮回调，点击未松开
    this.selectedColor =  Colors.white, //选中背景色
    this.highlightColor = const Color(0xFFEAEAEA), //高亮背景
    this.selected = false} //是否选中
      ): assert(child != null);
BaseCell(child: child, tapCallback: tapCallback);

//网络请求 注意，网络请求必须满足如下返回格式：{statusCode(或者code):0,data:reqData,msg:'is a error info'}

//设置 baseurl和超时时间 static void configureManager(String baseUrl,[int timeout = 15000])
HttpManager.configureManager(AppConfig.baseUrl); //一般是在main函数中

//添加header字段 比如token static void addRequestHeadersField(Map<String, dynamic> fields)
HttpManager.addRequestHeadersField({'Authorization':userInfoModel.token});

//请求数据

enum ResponseDataType
{
   AnyObjectData,  //不转换，原始数据
   StringData,     //字符串
   ListData,      //列表数据
   PageListData,  //分页列表数据，包括总数
   InfoData,      //字典数据
}

enum HttpSendType
{
  Get,
  Post,
  Delete,
  Update
}

static Future<HttpResponseData> requestDataWithURL(
  {
    body, //body请求时的参数
    ObjConvertCallback convert, //转换实体类方法  限于列表或者字典类型,不传，则默认转换为字典
    String urlString, //url地址
    Map<String, dynamic> param, //参数
    ResponseDataType dataType = ResponseDataType
        .InfoData, //数据类型，默认是字典类型
    HttpSendType sendType = HttpSendType.Post, //请求类型
    CancelToken cancelToken
  })；

var response = await HttpManager.requestDataWithURL(
        convert: (info)
        {
          var houseInfo = info as Map;
          if(houseInfo.containsKey('roomVoList'))
          {
            List<InvitorRoomModel> roomSelectVoList = [];

            int selCount = 0;

            (houseInfo['roomVoList'] as List).forEach((roomInfo) {
              String id = roomInfo['id'];
              var model = InvitorRoomModel(id??'',roomInfo['roomName']);
              if(widget.selectRooms != null && id != null)
              {
                for(var room in widget.selectRooms)
                {
                  if(room.roomId == id)
                  {
                    selCount++;
                    model.status = true;
                    break;
                  }
                }
              }

              roomSelectVoList.add(model);
            });
            return InvitorBuildingModel(houseInfo['buildingId'],houseInfo['buildingName'],roomSelectVoList,status: selCount == 0 ? 0:selCount == roomSelectVoList.length ? 1 : 2);
          }

          return null;

        },
        dataType: ResponseDataType.ListData,
        urlString: 'oa/visit/findAppRoomSelete',
        sendType: HttpSendType.Get
    );


//上传图片 static Future<HttpResponseData<T>> uploadFile<T>(String url,dynamic fileInfo,{ProgressCallback progress,Map<String, dynamic> param,CancelToken cancelToken});
//fileInfo可以为字节流或者文件名
//上传多张图片 static Future<HttpResponseData<List<String>>> uploadMoreFiles(String url,List<String> files,{ProgressCallback progress,CancelToken cancelToken})


//日期格式
WorksDateFormat.formatDate(date, 'yyyy-MM-dd HH:mm'); //支持格式详见代码

//键盘相关
BlankToolBarModel blankToolBarModel = BlankToolBarModel();//初始化
TextEditingController contentTextController = TextEditingController();
blankToolBarModel.closeKeyboard(context); //关闭键盘


Widget build(BuildContext context) {
    // TODO: implement build
    return
      BlankToolBarTool.blankToolBarWidget(context,
        model: blankToolBarModel,
        body:WorksCupertinoTextField(focusNode: blankToolBarModel.getFocusNodeByController(contentTextController)); //关联
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    blankToolBarModel.removeFocusListeners(); //释放
  }


 //添加图片控件  const PhotoPickWidget(this.photos, this.photoSize,{this.columnCount = 4, this.space = 8, this.maxCount = 8,this.textColor = Colors.white}); 

List<dynamic> photos = [];//控件包含的图片
PhotoPickWidget(
    this.photos,
    MediaQuery.of(context).size.width - 32,
    maxCount: 6,
    textColor: (AppConfig.navigationBarTitleColor as CupertinoDynamicColor).resolveFrom(context),
 )


 //分页请求等控件 



 ///带分页的listView 特别注意，CupertinoPageScaffold一定要加上 ProgressHUD，可加头尾

 //WidgetBuilder tableHeaderBuilder; //listView 的头部widget 跟随滚动
 //WidgetBuilder tableFooterBuilder;  //listView 的尾部widget 跟随滚动

 // WidgetBuilder headerBuilder;  //头部widget 不滚动
 // WidgetBuilder footerBuilder;  //尾部widget 不滚动

class _MainWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => __MainWidget();
}

class __MainWidget extends WorksBasePageListWidgetState<_MainWidget> {

  @override
  // TODO: implement requestUrl
  String get requestUrl => 'oa/visit/findMyPage';

  @override
  // TODO: implement convert
  get convert => (info)
  {
    return InvitorModel(
      info['createTime'],
      info['guestName'] ?? '',
    );
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DartNotificationCenter.subscribe(channel: 'inviteAdded', observer: this, onNotification: (_)
    {
      requestDataWithPageIndex(1);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    DartNotificationCenter.unsubscribe(observer: this);
    super.dispose();
  }

  @override
  Widget createCell(BuildContext context, int index) {

    InvitorModel model = data[index];

    return Container(
      child:Text(model.guestName);
    );
  }
}


//不带分页的列表可参考上面的示例，略...


//播放器 const WorksVideoPlayerScaffold({this.videoUrl, this.videoPath,this.isNeedLoad = false,this.isAudio = false,this.musicBgPath});

//videoUrl和videoPath 二选一
//isNeedLoad 表示是否需要下载下来播放，用于ios一些不支持在线播放的路径，目前仅当环信的在线视频，在ios端需要下载下来再播放





```
