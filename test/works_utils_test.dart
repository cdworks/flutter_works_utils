import 'package:flutter_test/flutter_test.dart';

import 'package:works_utils/works_utils.dart';


void main(){
  test('adds one to input values', () async {


    ///时间 格式转换
    print('result: ${WorksUtility.formatDate(DateTime.now(), "yyyy-mm-dd")}');

    /// 数据请求 设置baseurl及timeout
    HttpManager.configureManager('http://ynkysy.zimujiaoyu.com/');

    //设置格式什么的
    var response = await HttpManager.requestDataWithURL(
        urlString: "aedu/ebrand/getEbrandInfo.json",

        //convert【方法用于json转实体类
        // 如果是字典类型，直接转，如果是数组类型，那么参数data是数组中的一个json字符串】，若不传，则为字典和原始数组
        //如果是字典类型 response.data返回转换后的实体类，数组类型，返回实体类的数组集合，如果仍有疑问，请致电123456


        //factory UserInfoModel.fromJson(Map<String, dynamic> json) => _$UserInfoModelFromJson(json);
        //UserInfoModel _$UserInfoModelFromJson(Map<String, dynamic> json) {
        //  return UserInfoModel(
        //    userId: json['userId'] as String,
        //    schoolId: json['schoolId'] as String,
        //    schoolName: json['schoolName'] as String,
        //    accessToken: json['accessToken'] as String,
        //    userName: json['userName'] as String,
        //    loginName: json['loginName'] as String,
        //    telephone: json['telephone'] as String,
        //    userType: _$enumDecodeNullable(_$UserTypeEnumMap, json['userType']),
        //    password: json['password'] as String,
        //    integral: json['integral'] as int,
        //    expireDate: json['expireDate'] as String,
        //    headerImage: json['headerImage'] as String,
        //    teacher: json['teacher'] as Map<String, dynamic>,
        //    teacherGradeClass: json['teacherGradeClass'] as Map<String, dynamic>,
        //  );
        //}
//        convert: (data){    //json转实体类
//          return UserInfoModel.fromJson(data);
//        },
        param: {"gradeClassId": '0bd0f6ae8d3b4b23b6ba1e04c63d9a8a'});

    if (response.error == null) {
      print('data:${response.data}');
    }
    else
    {
      print('error:${response.error}');
    }



  });
}
