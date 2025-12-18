import 'package:flutter/material.dart';

/// 应用排版主题配置类
/// 统一管理应用内所有文本样式（标题、正文、说明文字等），支持样式插值过渡
/// 所有样式默认仅配置字号和字重，颜色/行高/字体等属性可通过 copyWith 补充
class AppThemeTypography {
  /// 超大号标题样式（页面级主标题）
  /// 字号：32px | 字重：900(极粗)
  /// 使用场景：首页Banner标题、弹窗大标题、核心页面头部标题
  final TextStyle headingLarge;

  /// 大号标题样式（模块级标题）
  /// 字号：24px | 字重：500(中粗)
  /// 使用场景：页面二级标题、卡片标题、功能模块标题
  final TextStyle heading;

  /// 小号标题样式（子模块标题）
  /// 字号：20px | 字重：400(常规)
  /// 使用场景：列表项标题、子模块头部、次要模块标题
  final TextStyle headingSmall;

  /// 超大号正文样式（强调型正文）
  /// 字号：20px | 字重：600(半粗)
  /// 使用场景：重要提示文本、关键数据展示、强强调的正文内容
  final TextStyle bodyExtraLarge;

  /// 大号正文样式（常规强调正文）
  /// 字号：18px | 字重：500(中粗)
  /// 使用场景：详情页内容、表单说明、需要突出的正文
  final TextStyle bodyLarge;

  /// 基础正文样式（默认正文）
  /// 字号：16px | 字重：400(常规)
  /// 使用场景：普通文本、按钮文字、列表默认文本、大多数正文内容
  final TextStyle body;

  /// 小号正文样式（辅助正文）
  /// 字号：14px | 字重：400(常规)
  /// 使用场景：辅助说明文本、次要内容、备注信息
  final TextStyle bodySmall;

  /// 超小号正文样式（极小正文）
  /// 字号：12px | 字重：400(常规)
  /// 使用场景：版权信息、底部备注、极次要的说明文本
  final TextStyle bodyExtraSmall;

  /// 大号说明文字（强调型标签）
  /// 字号：14px | 字重：700(粗)
  /// 使用场景：状态标签、计数文本、强强调的说明文字
  final TextStyle captionLarge;

  /// 常规说明文字（普通标签）
  /// 字号：12px | 字重：600(半粗)
  /// 使用场景：表单提示、时间戳、辅助标签、普通说明文字
  final TextStyle caption;

  /// 小号说明文字（极小标签）
  /// 字号：10px | 字重：600(半粗)
  /// 使用场景：图标旁数字、分页提示、底部极小标签文字
  final TextStyle captionSmall;

  /// 构造函数：应用排版主题配置
  /// 所有参数均为可选，未传入时使用默认样式，便于局部定制
  const AppThemeTypography({
    this.headingLarge = const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w900,
    ),
    this.heading = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),
    this.headingSmall = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
    ),
    this.bodyExtraLarge = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    this.bodyLarge = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    this.body = const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    this.bodySmall = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    this.bodyExtraSmall = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    this.captionLarge = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
    this.caption = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    this.captionSmall = const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
    ),
  });

  /// 样式插值方法（用于主题过渡动画）
  /// [other] - 目标排版主题（需为 AppThemeTypography 类型）
  /// [t] - 过渡系数（0~1，0表示当前样式，1表示目标样式）
  /// 返回值：当前样式与目标样式之间的过渡样式
  AppThemeTypography lerp(covariant dynamic other, double t) {
    // 非 AppThemeTypography 类型时返回当前样式，避免类型错误
    if (other is! AppThemeTypography) return this;

    // 对每个文本样式执行插值，实现平滑过渡
    return AppThemeTypography(
      headingLarge: TextStyle.lerp(headingLarge, other.headingLarge, t)!,
      heading: TextStyle.lerp(heading, other.heading, t)!,
      headingSmall: TextStyle.lerp(headingSmall, other.headingSmall, t)!,
      bodyExtraLarge: TextStyle.lerp(bodyExtraLarge, other.bodyExtraLarge, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      bodyExtraSmall: TextStyle.lerp(bodyExtraSmall, other.bodyExtraSmall, t)!,
      captionLarge: TextStyle.lerp(captionLarge, other.captionLarge, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      captionSmall: TextStyle.lerp(captionSmall, other.captionSmall, t)!,
    );
  }
}