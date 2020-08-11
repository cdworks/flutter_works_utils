
import 'dart:math';

import 'package:flutter/cupertino.dart';

extension WorksCupertinoDynamicColor_ on Color
{
  /// 生成颜色相反的一对light-dark颜色 如 黑-白

  CupertinoDynamicColor toInvertDynamicColor()
  {

     return this is CupertinoDynamicColor ? this : CupertinoDynamicColor.withBrightness(color: this, darkColor: Color(this.value ^ 0x00FFFFFF));
  }


  /// 生成lightColor的相近(减弱)的HSB颜色的一对light-dark颜色
  /// offset 颜色减弱的偏移量 -1～1 默认减弱0.08 正表示减弱，负数表示加强亮度

  CupertinoDynamicColor toHSBColorWithLightColor({double offset = 0.08})
  {

    if(this is CupertinoDynamicColor)
      return this;

    final hsvColor = HSVColor.fromColor(this);
    final hue = hsvColor.hue;
    final saturation = hsvColor.saturation;
    final brightness = hsvColor.value;
    final alpha = hsvColor.alpha;

    Color darkColor;

    if (brightness == 0) {
      if (saturation == 0) {
        if (hue != 0) {
          darkColor = HSVColor.fromAHSV(alpha, min<double>(1,max<double>(0, hue - offset)), saturation, brightness).toColor();
        }
      } else {
        darkColor = HSVColor.fromAHSV(alpha, hue, min<double>(1,max<double>(0, saturation - offset)), brightness).toColor();
      }
    }
    else
      {
        darkColor = HSVColor.fromAHSV(alpha, hue, saturation, min<double>(1,max<double>(0, brightness - offset))).toColor();
      }

    if(darkColor != null)
      {
        return CupertinoDynamicColor.withBrightness(color: this, darkColor: darkColor);
      }

    return CupertinoDynamicColor.withBrightness(color: this, darkColor: this);


  }

}

extension WorksCupertinoDynamicColor__ on CupertinoDynamicColor
{

  ///给所有状态的颜色设置统一的alpha值
   CupertinoDynamicColor colorWithAlpha(alpha)
  {
    if(this.color == null)
      return this;
    final color = this.color.withAlpha(alpha);
    final darkColor = this.darkColor != null ? this.darkColor.withAlpha(alpha) : color;
    final highContrastColor = this.highContrastColor != null ? this.highContrastColor.withAlpha(alpha) : color;
    final darkHighContrastColor = this.darkHighContrastColor != null ? this.darkHighContrastColor.withAlpha(alpha) :
        darkColor;
    final elevatedColor = this.elevatedColor != null ? this.elevatedColor.withAlpha(alpha) :
    color;
    final darkElevatedColor = this.darkElevatedColor != null ? this.darkElevatedColor.withAlpha(alpha) :
      darkColor;
    final highContrastElevatedColor = this.highContrastElevatedColor != null ? this.highContrastElevatedColor.withAlpha(alpha) :
    color;
    final darkHighContrastElevatedColor = this.darkHighContrastElevatedColor != null ? this.darkHighContrastElevatedColor.withAlpha(alpha) :
    darkColor;

    return CupertinoDynamicColor(
      color: color,
      darkColor: darkColor,
      highContrastColor :highContrastColor,
      darkHighContrastColor: darkHighContrastColor,
      elevatedColor: elevatedColor,
      darkElevatedColor: darkElevatedColor,
      highContrastElevatedColor: highContrastElevatedColor,
      darkHighContrastElevatedColor: darkHighContrastElevatedColor
    );

  }
}