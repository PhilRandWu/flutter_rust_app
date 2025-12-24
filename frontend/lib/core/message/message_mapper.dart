import 'package:flutter/cupertino.dart';
import 'package:frontend/core/message/message.dart';
import 'package:frontend/l10n/app_localizations.dart';

String getTranslatedMessage(BuildContext context, Message message) {
  final localizations = AppLocalizations.of(context);

  if (message is ErrorMessage) {
    switch (message.messageKey) {
      // Generic
      case 'unknown_error':
        return localizations.unknownError;
      case 'internalServerError':
        return localizations.internalServerError;
      case 'invalidRequestError':
        return localizations.invalidRequestError;
      case 'invalidResponseError':
        return localizations.invalidResponseError;
      case 'forbiddenError':
        return localizations.forbiddenError;
      case 'unauthorizedError':
        return localizations.unauthorizedError;

      // Auth
      case 'invalidUsernameOrCodeOrRecoveryCodeError':
        return localizations.invalidUsernameOrCodeOrRecoveryCodeError;
      case 'invalidUsernameOrRecoveryCodeError':
        return localizations.invalidUsernameOrRecoveryCodeError;
      case 'invalidUsernameOrPasswordOrRecoveryCodeError':
        return localizations.invalidUsernameOrPasswordOrRecoveryCodeError;
      case 'userNotFoundError':
        return localizations.userNotFoundError;
      case 'invalidOneTimePasswordError':
        return localizations.invalidOneTimePasswordError;
      case 'invalidUsernameOrPasswordError':
        return localizations.invalidUsernameOrPasswordError;
      case 'passwordMustBeChangedError':
        return localizations.passwordMustBeChangedError;
      case 'passwordTooShortError':
        return localizations.passwordTooShortError;
      case 'passwordNotComplexEnough':
        return localizations.passwordNotComplexEnough;
      case 'refreshTokenExpiredError':
        return localizations.refreshTokenExpiredError;
      default:
        return localizations.defaultError;
    }
  } else if (message is SuccessMessage) {
    switch (message.messageKey) {
      // Auth
      case 'loginSuccessful':
        return localizations.loginSuccessful;
      case 'logoutSuccessful':
        return localizations.logoutSuccessful;
      case 'validationCodeCorrect':
        return localizations.validationCodeCorrect;

      // Profile
      case 'passwordUpdateSuccessful':
        return localizations.passwordUpdateSuccessful;
      case 'profileUpdateSuccessful':
        return localizations.profileUpdateSuccessful;
      case 'deviceDeleteSuccessful':
        return localizations.deviceDeleteSuccessful;

      default:
        return localizations.defaultError;
    }
  } else if (message is InfoMessage) {
    switch (message.messageKey) {
      // Auth
      case 'recoveryCodesCopied':
        return localizations.recoveryCodesCopied;
      case 'qrCodeSecretKeyCopied':
        return localizations.qrCodeSecretKeyCopied;

      default:
        return localizations.defaultError;
    }
  } else {
    return localizations.defaultError;
  }
}
