import 'package:flutter/material.dart';

/// 特点：低饱和度、不艳丽、协调统一、视觉舒适、适配所有UI场景
class AppColors {
  // 主色调体系（浅灰白+浅青蓝为核心，保持柔和质感）
  static const Color primary = Color(0xFFF9FAFA); // 主色：浅灰白（背景/基础色）
  static const Color primaryLight = Color(0xFF6BAFBF); // 主色浅版：浅青蓝（强调/高亮）
  static const Color primaryDark = Color(0xFF4A8A9A); // 主色深版：深青蓝（按压/重点）
  static const Color primaryTransparent = Color(0x1A6BAFBF); // 主色透明版：浅青蓝10%透明

  // 辅助色体系（暖棕色系，与主色形成温和对比）
  static const Color secondary = Color(0xFFA08268); // 辅助色：浅棕（次要强调）
  static const Color secondaryLight = Color(0xFFC8A88E); // 辅助色浅版：浅棕黄（弱强调）
  static const Color secondaryDark = Color(0xFF7D634A); // 辅助色深版：深棕（强对比）
  static const Color secondaryTransparent = Color(0x26A08268); // 辅助色透明版：浅棕15%透明

  // 功能色体系（低饱和，避免刺眼）
  static const Color success = Color(0xFF6A994E); // 成功色：低饱和绿（保持原有协调色）
  static const Color warning = Color(0xFFF2E0C0); // 警告色：浅暖黄（降低饱和度）
  static const Color error = Color(0xFFB85456); // 错误色：低饱和红（柔和不刺眼）
  static const Color info = Color(0xFF5A7D98); // 信息色：浅蓝灰（与主色呼应）

  // 文本色体系（层级清晰，高可读性）
  static const Color textPrimary = Color(0xFF333333); // 主文本：深灰（高对比度）
  static const Color textSecondary = Color(0xFF666666); // 次文本：中灰（次要信息）
  static const Color textHint = Color(0xFF999999); // 提示文本：浅灰（占位/辅助）
  static const Color textInverse = Color(0xFFFFFFFF); // 反色文本：白色（深色背景用）
  static const Color textInverseSecondary = Color(0xCCE0E8E8); // 反色次文本：浅青灰（透明导航栏用）

  // 背景色体系（基于主色延伸，层次分明）
  static const Color background = Color(0xFFF5F8F7); // 页面背景：极浅青灰（比主色略深）
  static const Color backgroundCard = Color(0xFFFFFFFF); // 卡片背景：白色（干净清爽）
  static const Color backgroundDark = Color(0xFF2D3748); // 深色背景：深灰（夜间模式）
  static const Color backgroundHighlight = Color(0xFFE8F0EF); // 高亮背景：浅青灰（选中/ hover）

  // 边框色体系（低对比度，不突兀）
  static const Color borderPrimary = Color(0xFFE0E6E3); // 主边框：浅灰（卡片/容器）
  static const Color borderSecondary = Color(0xFFF0F2F1); // 次边框：极浅灰（分割线）
  static const Color borderDark = Color(0xFF4A5568); // 深色边框：中深灰（深色模式）

  // ====================== 导航栏专用色（与主色调统一）======================
  /// 导航栏背景色（主色，统一视觉）
  static const Color navigationBackground = primary;
  /// 导航栏未选中图标/文本色（浅灰白，不抢选中状态）
  static const Color navigationUnselected = textInverseSecondary;
  /// 导航栏选中图标色（主色浅版，温和突出）
  static const Color navigationSelectedIcon = primaryLight;
  /// 导航栏选中文本色（深灰，高可读性）
  static const Color navigationSelectedText = textPrimary;
  /// 导航栏指示器色（主色透明版，柔和不刺眼）
  static const Color navigationIndicator = primaryTransparent;

  // ====================== 系统栏专用色（与导航栏统一）======================
  /// 状态栏背景色（主色深版，提升层次感）
  static const Color statusBarColor = primaryDark;
  /// 底部系统导航栏背景色（主色，统一视觉）
  static const Color systemNavigationBarColor = primary;

  // ====================== 透明度预设（通用复用）======================
  /// 完全透明
  static const Color transparent = Color(0x00000000);
  /// 10% 透明度
  static const Color opacity10 = Color(0x1A000000);
  /// 20% 透明度
  static const Color opacity20 = Color(0x33000000);
  /// 30% 透明度
  static const Color opacity30 = Color(0x4D000000);

  // ====================== 常用渐变（柔和过渡，提升质感）======================
  /// 主色渐变（主色 -> 主色浅版，用于按钮/卡片背景）
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  /// 背景渐变（主背景 -> 极浅青灰，用于页面背景）
  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [background, Color(0xFFEAF2F1)],
  );

  // ====================== 工具方法（提升开发效率）======================
  /// 根据背景色自动匹配文本色（确保对比度，无障碍友好）
  static Color getTextColorForBackground(Color background) {
    final double brightness = (background.red * 299 +
        background.green * 587 +
        background.blue * 114) /
        1000;
    return brightness > 180 ? textPrimary : textInverse;
  }

  /// 调整颜色透明度（复用基础色，保持一致性）
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}