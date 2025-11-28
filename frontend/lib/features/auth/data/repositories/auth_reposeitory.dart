import 'dart:convert';

import 'package:frontend/features/auth/data/models/user_modal.dart' show UserModel;
import 'package:http/http.dart' as http;

class AuthRepository {
  final String baseUrl;

  AuthRepository({required this.baseUrl});

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return UserModel.fromJson(jsonBody['user']);
    } else {
      throw Exception('Invalid username or password');
    }
  }
}
