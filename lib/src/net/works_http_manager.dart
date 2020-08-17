
import 'dart:async';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../custom/works_error.dart';

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
  
  static String getBaseUrl()
  {
    _HttpSessionManager manager = _HttpSessionManager.getInstance();
    return manager.getBaseUrl();
  }

  ///添加header字段
  static void addRequestHeadersField(Map<String, dynamic> fields)
  {
    _HttpSessionManager manager = _HttpSessionManager.getInstance();
    manager.httpDio.options.headers.addAll(fields);
  }

  static dynamic getHeaderField(String key)
  {
    return _HttpSessionManager.getInstance().httpDio.options.headers[key];
  }

  //删除header字段
  static void removeRequestHeadersField(String key)
  {
    _HttpSessionManager manager = _HttpSessionManager.getInstance();

    manager.httpDio.options.headers.remove(key);
  }


  /// 公共函数
  /// /**
  /// *  请求公共的无特定类型的请求
  /// *
  /// *  @param URLString 请求的url地址
  /// *  @param parameters 请求的相关参数
  /// *  @param block      请求回调
  /// *
  /// *  @return task
  /// */

  static Future<_WorksResponseData<T>> _getObjectWithURL<T>({ String urlString, Map<String, dynamic>  param,
    HttpSendType sendType,CancelToken cancelToken}) async
  {
    var response;
    if(sendType == HttpSendType.Post) {
      response = await _HttpSessionManager.getInstance().httpDio.post<
          _WorksResponseData<T>>(
          urlString,
          data: FormData.fromMap(param),
        cancelToken: cancelToken
      );
    }
    else
      {
        response = await _HttpSessionManager.getInstance().httpDio.get<
            _WorksResponseData<T>>(urlString, queryParameters: param,cancelToken: cancelToken);
      }
      return response.data;
  }

  /// 公共函数
  /// /**
  /// *  请求公共的无特定类型的请求(with body)
  /// *
  /// *  @param URLString 请求的url地址
  /// *  @param parameters 请求的相关参数
  /// *  @param block      请求回调
  /// *
  /// *  @return task
  /// */

  static Future<_WorksResponseData<T>> _getObjectWithURLBody<T>({ String urlString, Map<String, dynamic>  queryParameters,body,
    HttpSendType sendType,CancelToken cancelToken}) async
  {
    var response;
    if(sendType == HttpSendType.Post) {
      response = await _HttpSessionManager.getInstance().httpDio.post<
          _WorksResponseData<T>>(urlString, data: body,queryParameters: queryParameters,cancelToken: cancelToken);
    }
    else
    {
      response = await _HttpSessionManager.getInstance().getWithBody<
          _WorksResponseData<T>>(urlString, data: body, queryParameters: queryParameters,cancelToken: cancelToken);
    }
    return response.data;
  }

  static Future<HttpResponseData> requestDataWithURL(
  {
    body,
    ObjConvertCallback convert, //转换实体类方法  限于列表或者字典类型,不传，则默认转换
    String urlString, //url地址
    Map<String, dynamic> param, //参数
    ResponseDataType dataType = ResponseDataType
        .InfoData, //数据类型，默认是字典类型
    HttpSendType sendType = HttpSendType.Post, //请求类型
    CancelToken cancelToken
  }) async
  {
    var response = body == null ? await _getObjectWithURL<Map<String,dynamic>>(
        urlString: urlString, param: param, sendType: sendType,cancelToken: cancelToken) : await _getObjectWithURLBody<Map<String,dynamic>>(urlString: urlString,body: body,queryParameters: param,sendType: sendType,cancelToken: cancelToken);
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
            WorksError.LocalizedDescriptionKey: "请求数据异常:无返回code"
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
                    var model = convert(item);
                    if(model != null) {
                      array.add(model);
                    }
                  }
                }
              }

              retData.data = array;
              break;
            case ResponseDataType.PageListData:
              var responseObj = userData as Map<String,dynamic>;
              final List list = responseObj['content'];
              var array = list;
              if(convert != null)
              {
                array = List();
                if(list.isNotEmpty)
                {
                  for(var item in list)
                  {
                    var model = convert(item);
                    if(model != null) {
                      array.add(model);
                    }
                  }
                }
              }

              retData.data = PageListData(total: responseObj['counts'],list: array);
              break;
            case ResponseDataType.InfoData:
              var responseObj = userData;
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
        WorksError.LocalizedDescriptionKey: "请求数据异常:${e.toString()}"
      });
    }

    if(retData !=null && retData.error != null)
      {
        if(kDebugMode) {
          if (_HttpSessionManager
              .getInstance()
              .httpDio
              .options
              .baseUrl != null) {
            print('works http request URL:${_HttpSessionManager
                .getInstance()
                .httpDio
                .options
                .baseUrl}$urlString error:${retData.error}');
          }
          else {
            print('works http request URL:$urlString error:${retData.error}');
          }
        }

      }

    return retData;
  }

  static Future<HttpResponseData<T>> uploadFile<T>(String url,dynamic fileInfo,{ProgressCallback progress,Map<String, dynamic> param,CancelToken cancelToken}) async
  {
    HttpResponseData<T> retData = HttpResponseData();

    if(fileInfo == null || fileInfo.isEmpty)
    {
      return null;
    }

    Map<String, dynamic> requestParam = param != null ? Map<String, dynamic>.from(param) : Map<String, dynamic>();

    if(fileInfo is String) {
      requestParam['file'] = await MultipartFile.fromFile(fileInfo, filename: "file0.jpg", contentType: MediaType.parse('image/jpeg'));
    }
    else if(fileInfo is List<int>)
      {
        requestParam['file'] =  MultipartFile.fromBytes(fileInfo, filename: "file0.jpg", contentType: MediaType.parse('image/jpeg'));
      }
    else
      {
        print('upload file info error!!');
        return null;
      }

    var postResponse = await _HttpSessionManager.getInstance().httpDio.post<
        _WorksResponseData<Map<String, dynamic>>>(
        url, data: FormData.fromMap(requestParam), onSendProgress: progress,cancelToken: cancelToken);

    try {
      final response = postResponse.data;
      if (response.statusCode == 0) {
        var responseData = response.data;
        int code;
        if (responseData.containsKey('statusCode')) {
          var statusCode = responseData['statusCode'].toString();
          code = int.tryParse(statusCode);
        }
        else if (responseData.containsKey('code')) {
          var statusCode = responseData['code'].toString();
          code = int.tryParse(statusCode);
        }
        if (code == null) {
          retData.error = WorksError(-2000, userInfo: {
            WorksError.LocalizedDescriptionKey: "请求数据异常"
          });
        }
        else if (code != 0) {
          retData.error = WorksError(code, userInfo: {
            WorksError.LocalizedDescriptionKey: responseData['msg'] ?? "请求数据失败"
          });
        }
        else {
          if (responseData.containsKey('data')) {
            retData.data = responseData['data'];
          }
          else {
            retData.error = WorksError(-2000, userInfo: {
              WorksError.LocalizedDescriptionKey: "请求数据异常"
            });
          }
        }
      }
      else {
        retData.error = WorksError(response.statusCode, userInfo: {
          WorksError.LocalizedDescriptionKey: response.errorMessage
        });
      }
    }
    catch (e) {
      retData.error = WorksError(-3000, userInfo: {
        WorksError.LocalizedDescriptionKey: "请求数据异常"
      });
    }

    if (retData != null && retData.error != null) {
      print('upload file error:${retData.error}');
    }
    return retData;
  }

//  static Future<HttpResponseData<T>> uploadFileWithData<T>(String url,List<int> data,{ProgressCallback progress,Map<String, dynamic> param,CancelToken cancelToken}) async
//  {
//    HttpResponseData<T> retData = HttpResponseData();
//
//    if(data == null || data.isEmpty)
//    {
//      return null;
//    }
//
//    Map<String, dynamic> requestParam = param != null ? Map<String, dynamic>.from(param) : Map<String, dynamic>();
//
//    requestParam['file'] = await MultipartFile.fromBytes(data,filename: "file0.jpg",contentType: MediaType.parse('image/jpeg'));
//
//    var postResponse = await _HttpSessionManager.getInstance().httpDio.post<
//        _WorksResponseData<Map<String, dynamic>>>(
//        url, data: FormData.fromMap(requestParam), onSendProgress: progress,cancelToken: cancelToken);
//
//    try {
//      final response = postResponse.data;
//      if (response.statusCode == 0) {
//        var responseData = response.data;
//        int code;
//        if (responseData.containsKey('statusCode')) {
//          var statusCode = responseData['statusCode'].toString();
//          code = int.tryParse(statusCode);
//        }
//        else if (responseData.containsKey('code')) {
//          var statusCode = responseData['code'].toString();
//          code = int.tryParse(statusCode);
//        }
//        if (code == null) {
//          retData.error = WorksError(-2000, userInfo: {
//            WorksError.LocalizedDescriptionKey: "请求数据异常"
//          });
//        }
//        else if (code != 0) {
//          retData.error = WorksError(code, userInfo: {
//            WorksError.LocalizedDescriptionKey: responseData['msg'] ?? "请求数据失败"
//          });
//        }
//        else {
//          if (responseData.containsKey('data')) {
//            retData.data = responseData['data'];
//          }
//          else {
//            retData.error = WorksError(-2000, userInfo: {
//              WorksError.LocalizedDescriptionKey: "请求数据异常"
//            });
//          }
//        }
//      }
//      else {
//        retData.error = WorksError(response.statusCode, userInfo: {
//          WorksError.LocalizedDescriptionKey: response.errorMessage
//        });
//      }
//    }
//    catch (e) {
//      retData.error = WorksError(-3000, userInfo: {
//        WorksError.LocalizedDescriptionKey: "请求数据异常"
//      });
//    }
//
//    if (retData != null && retData.error != null) {
//      print('upload file error:${retData.error}');
//    }
//    return retData;
//  }

  static Future<HttpResponseData<List<String>>> uploadMoreFiles(String url,List<String> files,{ProgressCallback progress,CancelToken cancelToken}) async
  {
    HttpResponseData<List<String>> retData = HttpResponseData();

    if(files == null || files.isEmpty)
      {
        return null;
      }

    List<MultipartFile> multipartFiles = [];

    for(int i = 0;i<files.length;i++)
      {
        multipartFiles.add(await MultipartFile.fromFile(files[i],
            filename: "file$i.jpg",contentType: MediaType.parse('image/jpeg')));
      }
    var postResponse = await _HttpSessionManager.getInstance().httpDio.post<
        _WorksResponseData<Map<String, dynamic>>>(
        url, data: FormData.fromMap({
      'width': 300,
      'height': 300,
      'thumb': 1,
      'savedb': 1,
      "files": multipartFiles
    }), onSendProgress: progress,cancelToken: cancelToken);

    try {
      final response = postResponse.data;
      if (response.statusCode == 0) {
        var responseData = response.data;
        int code;
        if (responseData.containsKey('statusCode')) {
          var statusCode = responseData['statusCode'].toString();
          code = int.tryParse(statusCode);
        }
        else if (responseData.containsKey('code')) {
          var statusCode = responseData['code'].toString();
          code = int.tryParse(statusCode);
        }
        if (code == null) {
          retData.error = WorksError(-2000, userInfo: {
            WorksError.LocalizedDescriptionKey: "请求数据异常"
          });
        }
        else if (code != 0) {
          retData.error = WorksError(code, userInfo: {
            WorksError.LocalizedDescriptionKey: responseData['msg'] ?? "请求数据失败"
          });
        }
        else {
          if (responseData.containsKey('data')) {
            List userData = responseData['data'];
            retData.data = [];
            userData.forEach((element) => retData.data.add(element['fileUrl']));
          }
          else {
            retData.error = WorksError(-2000, userInfo: {
              WorksError.LocalizedDescriptionKey: "请求数据异常"
            });
          }
        }
      }
      else {
        retData.error = WorksError(response.statusCode, userInfo: {
          WorksError.LocalizedDescriptionKey: response.errorMessage
        });
      }
    }
    catch (e) {
      retData.error = WorksError(-3000, userInfo: {
        WorksError.LocalizedDescriptionKey: "请求数据异常"
      });
    }

    if (retData != null && retData.error != null) {
      print('upload file error:${retData.error}');
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

    _WorksResponseData({this.data,this.request,this.statusCode,this.errorMessage,this.type});

   final T data;
   final RequestOptions request;
   /// Http status code.
   final int statusCode;
   final DioErrorType type;
   final String errorMessage;
}



class _HttpSessionManager
{
  factory _HttpSessionManager() => getInstance();

  Dio _dio;

  Dio get httpDio => _dio;

  void setBaseUrl(String baseUrl)
  {
    _dio.options.baseUrl = baseUrl;
  }
  
  String getBaseUrl()
  {
    return _dio.options.baseUrl;
  }

  void setConnectTimeout(int timeOut)
  {
    _dio.options.connectTimeout = timeOut;
  }

  Options checkOptions(method, options) {
    options ??= Options();
    options.method = method;
    return options;
  }

  _HttpSessionManager._internal()
  {

    _dio = Dio();
    final options = _dio.options;
    final interceptors = _dio.interceptors;
    options.connectTimeout = 15000;




//   if(bool.fromEnvironment("dart.vm.product")) {
//      _instance.interceptors.add(LogInterceptor());
//    }

//    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
//      client.badCertificateCallback =
//          (X509Certificate cert, String host, int port) {
//        return true;
//      };
//    };
    interceptors.add(CookieManager(CookieJar()));
    interceptors.add(InterceptorsWrapper(
        onResponse: (Response response) async
        {
          if(response.data is Map<String,dynamic>)
            {
              return _dio.resolve(_WorksResponseData(
                  request: response.request, data: response.data as Map<String,dynamic>, statusCode: 0));
            }
          else
            {
              return _dio.resolve(_WorksResponseData(
                  request: response.request, errorMessage: '请求数据异常!',data: null, statusCode: -2000));
            }

        },
        onError: (DioError error) async
        {
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
          return _dio.resolve(_WorksResponseData(data: null,type: error.type,request: request,errorMessage: errorMessage,statusCode: statusCode));
        }
    ));


  }

  Future<Response<T>> getWithBody<T>(
      String path, {
        data,
        Map<String, dynamic> queryParameters,
        Options options,
        CancelToken cancelToken,
        ProgressCallback onReceiveProgress,
      }) {
    return _dio.request<T>(
      path,
      queryParameters: queryParameters,
      options: checkOptions('GET', options),
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
  }

  static _HttpSessionManager _instance;

  static _HttpSessionManager getInstance() {
    if (_instance == null) {
      _instance = _HttpSessionManager._internal();
//      if (bool.fromEnvironment("dart.vm.product")) {
//        _instance.interceptors.add(LogInterceptor());
//      }
    }
    return _instance;
  }
}