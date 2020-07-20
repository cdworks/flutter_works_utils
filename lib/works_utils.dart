library works_utils;

import 'dart:math';

import 'package:flutter/foundation.dart';


class WorksChangeNotifier with ChangeNotifier
{
  @override
  void notifyListeners() {
    // TODO: implement notifyListeners
    super.notifyListeners();
  }
}

/// A Calculator.
class WorksUtils {
  /// Returns [value] plus 1.
  static var weekStrings = ['星期一','星期二','星期三','星期四','星期五','星期六','星期日'];
  static var shortWeekStrings = ['周一','周二','周三','周四','周五','周六','周日'];
  static var vertyShortWeekStrings = ['一','二','三','四','五','六','日'];
  static String formatDate(DateTime date, String dateFormatter) {
    if(date == null)
      return '';
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
      else if (dateString.startsWith('ee') || (dateString.startsWith('EE'))) {
        buffer.write(vertyShortWeekStrings[date.weekday-1]);
        len = 2;
      }
      

      else {
        buffer.write(dateString.substring(0, 1));
      }

      dateString = dateString.substring(len);
    }

    return buffer.toString();
  }

  static String formatterTimestamp(int timestamp)
  {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var now = DateTime.now();
    StringBuffer buffer = StringBuffer();
    if(date.year == now.year)
    {
      return formatDate(date,'M月d日 HH:mm');
    }
    return formatDate(date,'yyyy/M/d HH:mm');

  }

  static String convertCardNum(String cardNum)
  {
    if(cardNum == null || cardNum.length < 5)
      return cardNum;

    String formatString = '';

    int len = cardNum.length ~/ 4;
    if(cardNum.length % 4 == 0)
      {
        len--;
      }
    for(int i = 0;i<len;i++)
      {
        formatString += cardNum.substring(i*4,min(cardNum.length,(i+1)*4)) + ' ';
      }

    if(len*4 < cardNum.length)
    {
      formatString += cardNum.substring(len*4,cardNum.length);
    }

    return formatString;
  }

}


