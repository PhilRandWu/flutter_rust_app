// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get alreadyAnAccountLogin => '已有账号？立即登录';

  @override
  String get about => '关于';

  @override
  String get aboutText => '本应用由 Thomas Simmer 为您提供。';

  @override
  String get cancel => '取消';

  @override
  String get changePassword => '修改密码';

  @override
  String get challenges => '挑战';

  @override
  String get confirmDeletion => '确认删除';

  @override
  String get confirmDeletionQuestion => '您确定要删除此设备上的会话吗？';

  @override
  String get comeBack => '返回';

  @override
  String get currentPassword => '当前密码';

  @override
  String get dark => '深色';

  @override
  String get defaultError => '发生错误，请重试。';

  @override
  String get delete => '删除';

  @override
  String get devices => '我的设备';

  @override
  String deviceInfo(String isMobile, String os, String browser, String model) {
    String _temp0 = intl.Intl.selectLogic(isMobile, {
      'true': '移动设备',
      'false': '电脑',
      'other': '未知设备',
    });
    String _temp1 = intl.Intl.selectLogic(os, {
      'null': '。',
      'other': ' 运行于 $os 系统。 ',
    });
    String _temp2 = intl.Intl.selectLogic(browser, {
      'null': '客户端应用',
      'other': '浏览器：$browser',
    });
    String _temp3 = intl.Intl.selectLogic(model, {
      'null': '',
      'other': ' 设备型号：$model。',
    });
    return '$_temp0$_temp1$_temp2$_temp3';
  }

  @override
  String get deviceDeleteSuccessful => '您已成功终止此设备上的会话';

  @override
  String get disableTwoFA => '关闭';

  @override
  String get enable => '开启';

  @override
  String get enterOneTimePassword => '输入您的认证应用生成的6位验证码以完成身份验证。';

  @override
  String get enterPassword => '请输入您的密码。';

  @override
  String get enterRecoveryCode => '输入您的任意一个恢复码。';

  @override
  String get enterUsername => '请输入您的用户名。';

  @override
  String get enterValidationCode => '输入您的认证应用中的验证码。';

  @override
  String get failedToLoadProfile => '加载个人资料失败';

  @override
  String get forbiddenError => '您无权执行此操作。';

  @override
  String get generateNewQrCode => '生成新的二维码';

  @override
  String get goToTwoFASetup => '设置双因素认证';

  @override
  String get habits => '习惯';

  @override
  String hello(String userName) {
    return '你好 $userName';
  }

  @override
  String get home => '首页';

  @override
  String get internalServerError => '服务器内部错误，请重试。';

  @override
  String get invalidOneTimePasswordError => '一次性验证码无效，请重试。';

  @override
  String get invalidRequestError => '您的请求未被服务器接受。';

  @override
  String get invalidResponseError => '无法处理服务器返回的响应。';

  @override
  String get invalidUsernameOrCodeOrRecoveryCodeError =>
      '用户名、一次性验证码或恢复码无效，请重试。';

  @override
  String get invalidUsernameOrPasswordError => '用户名或密码错误，请重试。';

  @override
  String get invalidUsernameOrPasswordOrRecoveryCodeError =>
      '用户名、密码或恢复码无效，请重试。';

  @override
  String get invalidUsernameOrRecoveryCodeError => '用户名或恢复码无效，请重试。';

  @override
  String get keepRecoveryCodesSafe =>
      '请妥善保管这些恢复码。\n如果您丢失密码或无法访问双因素认证应用，这些代码将是您找回账号的关键。';

  @override
  String get language => '语言';

  @override
  String get lastActivityDate => '最后活动时间：';

  @override
  String get light => '浅色';

  @override
  String get logIn => '登录';

  @override
  String get loginSuccessful => '您已成功登录。';

  @override
  String get logout => '退出登录';

  @override
  String get logoutSuccessful => '您已成功退出登录。';

  @override
  String get messages => '消息';

  @override
  String get newPassword => '新密码';

  @override
  String get next => '下一步';

  @override
  String get noAccountCreateOne => '还没有账号？立即创建。';

  @override
  String get noContent => '暂无内容可展示';

  @override
  String get noDevices => '暂无设备可展示';

  @override
  String get noDeviceInfo => '暂无设备信息可展示';

  @override
  String get noRecoveryCodeAvailable => '暂无可用的恢复码。';

  @override
  String get password => '密码';

  @override
  String get passwordForgotten => '忘记密码？';

  @override
  String get passwordMustBeChangedError => '您需要修改密码后才能登录。';

  @override
  String get passwordNotComplexEnough => '您的密码必须至少包含一个字母、一个数字和一个特殊字符。';

  @override
  String get passwordNotExpiredError => '您的密码尚未过期，无法通过此方式修改。';

  @override
  String get passwordTooShortError => '您的密码长度必须至少为8个字符。';

  @override
  String get passwordUpdateSuccessful => '您的密码已成功更新。';

  @override
  String get pleaseLoginOrSignUp => '请登录或注册以继续使用。';

  @override
  String get profile => '个人资料';

  @override
  String get profileSettings => '个人资料设置';

  @override
  String get profileUpdateSuccessful => '个人资料已保存。';

  @override
  String get qrCodeSecretKeyCopied => '二维码密钥已复制到剪贴板。';

  @override
  String get recoverAccount => '找回账号';

  @override
  String get recoveryCode => '恢复码';

  @override
  String get recoveryCodesCopied => '恢复码已复制到剪贴板。';

  @override
  String get refreshTokenExpiredError => '您的会话已过期，请重新登录。';

  @override
  String get regenerateQrCode => '重新生成二维码';

  @override
  String get save => '保存';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get selectTheme => '选择主题';

  @override
  String get setNewPassword => '请输入您的新密码。';

  @override
  String get signUp => '注册';

  @override
  String get theme => '主题';

  @override
  String get twoFA => '双因素认证';

  @override
  String get twoFAInvitation => '安全与隐私是我们的首要任务。\n请设置双因素认证，以保护您的账号免受暴力破解攻击。';

  @override
  String get twoFAIsWellSetup => '您的账号已成功开启双因素认证。';

  @override
  String get twoFAScanQrCode => '使用您的认证应用扫描此二维码。';

  @override
  String twoFASecretKey(String secretKey) {
    return '您的密钥是：$secretKey';
  }

  @override
  String get twoFASetup => '开启双因素认证以保护您的账号安全。';

  @override
  String get twoFactorAuthenticationNotEnabledError => '您的账号尚未开启双因素认证。';

  @override
  String get unableToLoadRecoveryCodes => '无法加载恢复码。';

  @override
  String get unauthorizedError => '您无权执行此操作。';

  @override
  String get unknownError => '发生意外错误，请重试。';

  @override
  String get updatePassword => '请输入您的当前密码和新密码。';

  @override
  String get userAlreadyExistingError => '该用户名已被注册，请选择其他用户名。';

  @override
  String get userNotFoundError => '未找到该用户。';

  @override
  String get username => '用户名';

  @override
  String get usernameNotRespectingRulesError =>
      '您的用户名必须遵守以下规则：\n - 以字母或数字开头和结尾\n - 允许的特殊字符为 . _ -\n - 不允许连续的特殊字符';

  @override
  String get usernameWrongSizeError => '用户名长度必须在3到20个字符之间。';

  @override
  String get validationCode => '验证码';

  @override
  String get validationCodeCorrect => '您的验证码正确！';

  @override
  String get verify => '验证';

  @override
  String get welcome => '欢迎使用 Flutter Actix 应用。';

  @override
  String get previous => '上一步';

  @override
  String get unknown => '未知';
}
