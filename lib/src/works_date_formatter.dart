
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

///定义时间单位所包含的秒数

const int D_MINUTE_SECONDS	= 60;
const int D_HOUR_SECONDS		= 3600;
const int D_DAY_SECONDS		= 86400;
const int D_WEEK_SECONDS	=	604800;
const int D_YEAR_SECONDS	=	31556926;

const int D_MINUTE_MS	= 60000;
const int D_HOUR_MS		= 3600000;
const int D_DAY_MS		= 86400000;
const int D_WEEK_MS	=	604800000;
const int D_YEAR_MS	=	31556926000;

class WorksDateFormat
{
  static var weekStrings = ['星期一','星期二','星期三','星期四','星期五','星期六','星期日'];
  static var shortWeekStrings = ['周一','周二','周三','周四','周五','周六','周日'];
  static String formatDate(DateTime date, String dateFormatter) {
    StringBuffer buffer = StringBuffer();
    String dateString = dateFormatter;

    while (dateString.length != 0) {
      int len = 1;
      if (dateString.startsWith('yyyy') || (dateString.startsWith('YYYY'))) {
        buffer.write(date.year.toString().padLeft(4, '0'));
        len = 4;
      }
      else if (dateString.startsWith('yy') || (dateString.startsWith('YY'))) {
        String year = date.year.toString().padLeft(2, '0');
        buffer.write(year.substring(year.length - 2, year.length));
        len = 2;
      }
      else if (dateString.startsWith('MM')) {
        buffer.write(date.month.toString().padLeft(2, '0'));
        len = 2;
      }
      else if (dateString.startsWith('M')) {
        buffer.write(date.month.toString());
      }
      else if (dateString.startsWith('dd') || (dateString.startsWith('DD'))) {
        buffer.write(date.day.toString().padLeft(2, '0'));
        len = 2;
      }
      else if ((dateString.startsWith('d') || dateString.startsWith('D'))) {
        buffer.write(date.day.toString());
      }
      else if (dateString.startsWith('aHH') || (dateString.startsWith('ahh'))) {
        int hour = date.hour;
        if (date.hour > 12) {
          buffer.write('下午 ');
          hour = hour - 12;
        }
        else {
          buffer.write('上午 ');
        }
        buffer.write(hour.toString().padLeft(2, '0'));
        len = 3;
      }
      else if ((dateString.startsWith('ah') || dateString.startsWith('aH'))) {
        int hour = date.hour;
        if (date.hour > 12) {
          buffer.write('下午 ');
          hour = hour - 12;
        }
        else {
          buffer.write('上午 ');
        }
        buffer.write(hour.toString());
        len = 2;
      }
      else if (dateString.startsWith('HH') || (dateString.startsWith('hh'))) {
        buffer.write(date.hour.toString().padLeft(2, '0'));
        len = 2;
      }
      else if ((dateString.startsWith('h') || dateString.startsWith('H'))) {
        buffer.write(date.hour.toString());
      }
      else if (dateString.startsWith('mm')) {
        buffer.write(date.minute.toString().padLeft(2, '0'));
        len = 2;
      }
      else if (dateString.startsWith('m')) {
        buffer.write(date.minute.toString());
      }
      else if (dateString.startsWith('SS') || (dateString.startsWith('ss'))) {
        buffer.write(date.second.toString().padLeft(2, '0'));
        len = 2;
      }
      else if (dateString.startsWith('S') || dateString.startsWith('s')) {
        buffer.write(date.second.toString());
      }
      else if (dateString.startsWith('eeee') || (dateString.startsWith('EEEE'))) {
        buffer.write(weekStrings[date.weekday-1]);
        len = 4;
      }
      else if (dateString.startsWith('eee') || (dateString.startsWith('EEE'))) {
        buffer.write(shortWeekStrings[date.weekday-1]);
        len = 3;
      }

      else {
        buffer.write(dateString.substring(0, 1));
      }

      dateString = dateString.substring(len);
    }

    return buffer.toString();
  }


  ///去掉某天的时分秒 比如 2019/12/21 00:00:00

  static DateTime dateAtStartOfDay()
  {
    return  DateTime(DateTime.now().year,0,0,0);
  }


  ///昨天今天明天相关操作
  ///

  static DateTime dateTomorrow()
  {
    return DateTime.now().add(Duration(days: 1));
  }
  static DateTime dateYesterday()
  {
    return DateTime.now().subtract(Duration(days: 1));
  }
  
  static bool isToday(DateTime date)
  {
    var now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isThisYear(DateTime date)
  {
    var now = DateTime.now();
    return date.year == now.year;
  }

  static bool isTomorrow(DateTime date)
  {
    var tomorrow = dateTomorrow();
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  static bool isYesterday(DateTime date)
  {
    var yesterday = dateYesterday();
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }



//  static bool isThisWeek(DateTime date,BuildContext context)
//  {
//    var now = DateTime.now();
//    MaterialLocalizations localizations = MaterialLocalizations.of(context);
//    DateTime epoch = DateTime.utc(1970);
//    dateTime = new DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
//
//    int offset = EPOCH_WEEK_DAY - weekStart;
//    if (offset < 0) {
//      offset += 7;
//    }
//
//    int delta = EPOCH_JULIAN_DAY - offset;
//
//    return (date.difference(epoch).inDays - delta) ~/ 7;
//    return (date.weekday == date.weekday);
//  }


  ///转换日期

  static String formatterTimestamp(int timestamp)
  {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    if(isToday(date))
      {
        return formatDate(date,'HH:mm');
      }

    if(isYesterday(date))
      {
        return formatDate(date,'昨天 HH:mm');
      }

    if(isThisYear(date))
      {
        return formatDate(date,'M月d日 HH:mm');
      }

    return formatDate(date,'yyyy/M/d HH:mm');

  }

  static String convertSecondsToHMS(int seconds)
  {

    if(seconds <= 0)
      {
        return '0:00';
      }

    String formatString = '';
    int hours = seconds ~/ D_HOUR_SECONDS;
    int minutes = (seconds % D_HOUR_SECONDS) ~/ 60;
    int sec = seconds % 60;
    if(hours > 0)
      {
        formatString = sprintf('%d:%02d:%02d',[hours,minutes,sec]);
      }
    else
      {
        formatString = sprintf('%d:%02d',[minutes,sec]);
      }

    return formatString;
  }


}