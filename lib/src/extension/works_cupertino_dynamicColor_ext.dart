
import 'dart:math';

import 'package:flutter/cupertino.dart';

extension WorksCupertinoDynamicColor_ on CupertinoDynamicColor
{
  /// 生成颜色相反的一对light-dark颜色 如 黑-白
  /// lightColor light value

  String test()
  {
    return 'xx';
  }

//  static CupertinoDynamicColor dynamicColorWithLightColor({@required int lightColor})
//  {
//     assert(lightColor != null);
//     return CupertinoDynamicColor.withBrightness(color: Color(lightColor), darkColor: Color(lightColor ^ 0x00FFFFFF));
//  }
//
//  /// 生成lightColor的相近(减弱)的HSB颜色的一对light-dark颜色
//  /// lightColor light value
//  /// offset 颜色减弱的偏移量 0～1 默认减弱0.08
//
//  static CupertinoDynamicColor dynamicHSBColorWithLightColor({@required int lightColor,double offset})
//  {
//    assert(lightColor != null);
//    final hsvColor = HSVColor.fromColor(Color(lightColor));
//    final hue = hsvColor.hue;
//    final saturation = hsvColor.saturation;
//    final brightness = hsvColor.value;
//    final alpha = hsvColor.alpha;
//
//    Color darkColor;
//
//    if (brightness == 0) {
//      if (saturation == 0) {
//        if (hue != 0) {
//          darkColor = HSVColor.fromAHSV(alpha, max(0, hue - offset), saturation, brightness).toColor();
//        }
//      } else {
//        darkColor = HSVColor.fromAHSV(alpha, hue, max(0, saturation - offset), brightness).toColor();
//      }
//    }
//    else
//      {
//        darkColor = HSVColor.fromAHSV(alpha, hue, saturation, max(0, brightness - offset)).toColor();
//      }
//
//    if(darkColor != null)
//      {
//        return CupertinoDynamicColor.withBrightness(color: Color(lightColor), darkColor: darkColor);
//      }
//
//    return CupertinoDynamicColor.withBrightness(color: Color(lightColor), darkColor: Color(lightColor));
//
//
//  }

}