import 'package:flutter/material.dart';

/// 应用通用样式配置类
/// 统一管理卡片阴影、按钮样式等通用视觉/交互样式，支持主题适配和样式插值
class AppThemeStyles {
  /// 卡片通用阴影（支持主题适配）
  final List<BoxShadow> cardShadow;

  /// 小尺寸按钮样式（用于紧凑布局的次要按钮）
  final ButtonStyle buttonSmall;

  /// 中尺寸按钮样式（用于常规操作按钮）
  final ButtonStyle buttonMedium;

  /// 大尺寸按钮样式（用于核心操作按钮）
  final ButtonStyle buttonLarge;

  /// 文本按钮样式（无背景、无点击反馈，用于次要操作）
  final ButtonStyle buttonText;

  const AppThemeStyles({
    this.cardShadow = const [
      BoxShadow(color: Color(0x1F000000), offset: Offset(0, 8), blurRadius: 23),
    ],
    this.buttonSmall = const ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.zero),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
    this.buttonMedium = const ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.zero),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    this.buttonLarge = const ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.zero),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    this.buttonText = const ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.zero),
      backgroundColor: WidgetStatePropertyAll(Colors.transparent),
      padding: WidgetStatePropertyAll(EdgeInsets.zero),
      splashFactory: NoSplash.splashFactory,
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1),
      ),
    ),
  });
}
