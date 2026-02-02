import 'dart:async';

import 'package:frontend/features/auth/data/storage/token_storage.dart';
import 'package:http/http.dart';
import 'package:frontend/core/utils/user_agent.dart';
import 'package:http_interceptor/models/interceptor_contract.dart';

class AuthInterceptor extends InterceptorContract {
  final String baseUrl;
  final TokenStorage tokenStorage;

  AuthInterceptor({required this.baseUrl, required this.tokenStorage});

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
    String? accessToken = await tokenStorage.getAccessToken();
    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
    final userAgent = await getUserAgent();
    request.headers['X-User-Agent'] = userAgent;

    return request;
  }

  @override
  FutureOr<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    return response;
  }
}
