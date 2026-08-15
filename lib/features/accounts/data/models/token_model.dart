import '../../domain/entities/token_entity.dart';

class TokenModel extends TokenEntity {
  const TokenModel({
    required super.access,
    required super.refresh,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      access: json['access'] ?? '',
      refresh: json['refresh'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
    };
  }
}