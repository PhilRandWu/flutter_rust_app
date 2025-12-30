import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/data_error.dart';
import 'package:frontend/features/auth/data/errors/data_error.dart';
import 'package:frontend/features/auth/data/models/user_token_model.dart';
import 'package:frontend/features/auth/data/models/user_token_request_model.dart';
import 'package:frontend/features/auth/domain/errors/domain_error.dart';
import 'package:http_interceptor/http/intercepted_client.dart';

class AuthRemoteDataSource {
  final String baseUrl;
  final InterceptedClient apiClient;

  const AuthRemoteDataSource({required this.baseUrl, required this.apiClient});

  Future<UserTokenModel> signup(
    RegisterUserRequestModel registerUserRequestModel,
  ) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(registerUserRequestModel.toJson()),
    );

    final jsonBody = json.decode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 201) {
      try {
        return UserTokenModel.fromJson(jsonBody);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'PASSWORD_TOO_SHORT') {
        throw PasswordTooShortError();
      }
      if (responseCode == 'PASSWORD_TOO_WEAK') {
        throw PasswordNotComplexEnoughError();
      }
      if (responseCode == 'USERNAME_WRONG_SIZE') {
        throw UsernameWrongSizeError();
      }
      if (responseCode == 'USERNAME_NOT_RESPECTING_RULES') {
        throw UsernameNotRespectingRulesError();
      }
    }

    if (response.statusCode == 409) {
      if (responseCode == 'USER_ALREADY_EXISTS') {
        throw UserAlreadyExistingError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<Either<UserTokenModel, String>> login(
    LoginUserRequestModel loginUserRequestMode,
  ) async {
    final url = Uri.parse('$baseUrl/auth/signin');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(loginUserRequestMode.toJson()),
    );

    final jsonBody = json.decode(response.body);
    // final responseCode = jsonBody['code'] as String;

    print('jsonBody $jsonBody');
    if (response.statusCode == 200) {
      return Left(UserTokenModel.fromJson(jsonBody));
      // try {
      //   if (responseCode == 'USER_LOGGED_IN_WITHOUT_OTP') {
      //     return Left(UserTokenModel.fromJson(jsonBody));
      //   }
      //
      //   if (responseCode == 'USER_LOGS_IN_WITH_OTP_ENABLED') {
      //     return Right(jsonBody['user_id']);
      //   }
      //
      //   throw ParsingError();
      // } catch (e) {
      //   throw ParsingError();
      // }
    }

    if (response.statusCode == 401) {
      // if (responseCode == 'INVALID_USERNAME_OR_PASSWORD') {
      //   throw InvalidUsernameOrPasswordError();
      // }

      throw UnauthorizedError();
    }

    if (response.statusCode == 403) {
      // if (responseCode == 'PASSWORD_MUST_BE_CHANGED') {
      //   throw PasswordMustBeChangedError();
      // }

      throw ForbiddenError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }
    throw UnknownError();
  }

  Future<void> logout() async {
    final url = Uri.parse('$baseUrl/auth/logout');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }
}
