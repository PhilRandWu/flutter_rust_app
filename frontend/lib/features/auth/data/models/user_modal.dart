import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String username;

  const UserModel({required this.id, required this.username});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'] as String,
        username: json['username'] as String
    );
  }

  @override
  List<Object?> get props => [id, username];
}
