
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import '../coustom/works_error.dart';
//import 'works_url_define.dart';

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

class PageListData
{
  const PageListData({this.list,this.total});
  final List list;
  final int total;

}

typedef ObjConvertCallback = dynamic Function(dynamic data);

class HttpManager
{


  static void configureManager(String baseUrl,[int timeout = 15000])
  {
     _HttpSessionManager manager = _HttpSessionManager.getInstance();
     manager.setBaseUrl(baseUrl);
     manager.setConnectTimeout(timeout);

  }

  /// 公共函数
  /// /**
  /// *  请求公共的body无特定类型的请求
  /// *
  /// *  @param URLString 请求的url地址
  /// *  @param parameters 请求的相关参数
  /// *  @param block      请求回调
  /// *
  /// *  @return task
  /// */

  static Future<_WorksResponseData<T>> _getObjectWithURL<T>({ String urlString, Map<String, dynamic>  param,
    HttpSendType sendType}) async
  {
    var response;
    if(sendType == HttpSendType.Post) {
      response = await _HttpSessionManager.getInstance().post<
          _WorksResponseData<T>>(urlString, data: FormData.fromMap(param));
    }
    else
      {
        response = await _HttpSessionManager.getInstance().get<
            _WorksResponseData<T>>(urlString, queryParameters: param);
      }
      return response.data;
  }

  static Future<HttpResponseData> requestDataWithURL(
  {
    ObjConvertCallback convert, //转换实体类方法  限于列表或者字典类型,不传，则默认转换
    String urlString, //url地址
    Map<String, dynamic> param,  //参数
        ResponseDataType dataType = ResponseDataType
            .InfoData, //数据类型，默认是字典类型
    HttpSendType sendType = HttpSendType.Post //请求类型
  }) async
  {
    var response = await _getObjectWithURL<Map<String,dynamic>>(
        urlString: urlString, param: param, sendType: sendType);
    HttpResponseData retData = HttpResponseData();
    try{
      if (response.statusCode == 0) {
        var responseData = response.data;
        int code;
        if(responseData.containsKey('statusCode'))
          {
            var statusCode = responseData['statusCode'].toString();
            code = int.tryParse(statusCode);
          }
        else if(responseData.containsKey('code'))
          {
            var statusCode = responseData['code'].toString();
            code = int.tryParse(statusCode);
          }
        if(code == null)
        {
          retData.error = WorksError(-2000, userInfo: {
            WorksError.LocalizedDescriptionKey: "请求数据异常"
          });
        }
        else if(code != 0)
        {
          retData.error = WorksError(code, userInfo: {
            WorksError.LocalizedDescriptionKey: responseData['msg'] ?? "请求数据失败"
          });
        }
        else {
          var userData =  responseData['data'];
          switch (dataType) {
            case ResponseDataType.AnyObjectData:
              retData.data = userData;
              break;
            case ResponseDataType.StringData:
              retData.data = userData ?? "";
              break;
            case ResponseDataType.ListData:
              var list = userData as List<dynamic>;
              var array = list;
              if(convert != null) {
                array = List();
                if (list.isNotEmpty) {
                  for (var item in list) {
                    array.add(convert(item));
                  }
                }
              }

              retData.data = array;
              break;
            case ResponseDataType.PageListData:
              var responseObj = userData as Map<String,dynamic>;
              var list = responseObj['content'] as List<Map<String,dynamic>>;
              var array = list;
              if(convert != null)
              {
                array = List();
                if(list.isNotEmpty)
                {
                  for(var item in list)
                  {
                    array.add(convert(item));
                  }
                }
              }

              retData.data = PageListData(total: responseObj['counts'],list: array);
              break;
            case ResponseDataType.InfoData:
              var responseObj = userData as Map<String,dynamic>;
              retData.data = convert != null ? convert(responseObj) : responseObj;
              break;
          }
        }
      }
      else {
        retData.error = WorksError(response.statusCode, userInfo: {
          WorksError.LocalizedDescriptionKey: response.errorMessage
        });
      }
    }
    catch(e)
    {
      retData.error = WorksError(-3000, userInfo: {
        WorksError.LocalizedDescriptionKey: "请求数据异常"
      });
    }


    return retData;
  }

}

class HttpResponseData<T>
{
   HttpResponseData({this.data,this.error});
   T data;
   WorksError error;
}

class _WorksResponseData<T>
{

  const _WorksResponseData({this.data,this.request,this.statusCode,this.errorMessage,this.type});

   final T data;
   final RequestOptions request;
   /// Http status code.
   final int statusCode;
   final DioErrorType type;
   final String errorMessage;
}



class _HttpSessionManager extends DioForNative
{
  factory _HttpSessionManager() => getInstance();

  void setBaseUrl(String baseUrl)
  {
    options.baseUrl = baseUrl;
  }

  void setConnectTimeout(int timeOut)
  {
    options.connectTimeout = timeOut;
  }

  _HttpSessionManager._internal():super()
  {
    options.connectTimeout = 15000;
    if (bool.fromEnvironment("dart.vm.product")) {
      interceptors.add(LogInterceptor());
    }

    interceptors.add(InterceptorsWrapper(
        onResponse: (Response response) async
        {
          return resolve(_WorksResponseData(
              request: response.request, data: response.data as Map<String,dynamic>, statusCode: 0));
        },
        onError: (DioError error) async
        {
          Map<String,dynamic> data;
          RequestOptions request;
          int statusCode;
          String errorMessage;
          switch(error.type)
          {

            case DioErrorType.CONNECT_TIMEOUT:
            case DioErrorType.SEND_TIMEOUT:
            case DioErrorType.RECEIVE_TIMEOUT:
              statusCode = -100;
              errorMessage = '请求超时';
              break;
            case DioErrorType.RESPONSE:
              if(error.response != null)
                {
                   statusCode = error.response.statusCode;
                   request = error.request;
                   data = error.response.data as Map<String,dynamic>;
                   errorMessage = error.response.statusMessage;
                }
              else
                {
                  statusCode = -1000;
                  if(error.error != null)
                    {
                      errorMessage = error.toString();
                    }
                  else
                    {
                      errorMessage = "未知错误";
                    }
                }
              break;
            case DioErrorType.CANCEL:
              statusCode = - 10001;
              errorMessage = "请求已取消";
              break;
            case DioErrorType.DEFAULT:
              statusCode = -10002;
              if(error.error != null)
              {
                errorMessage = error.message;
              }
              else
              {
                errorMessage = "未知错误";
              }
              break;
          }
//          data.data = error.response.data;
          return resolve(_WorksResponseData(data: data,type: error.type,request: request,errorMessage: errorMessage,statusCode: statusCode));
        }
    ));


  }

  static _HttpSessionManager _instance;

  static _HttpSessionManager getInstance() {
    if (_instance == null) {
      _instance = _HttpSessionManager._internal();
    }
    return _instance;
  }
}