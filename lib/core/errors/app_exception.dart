import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

@freezed
sealed class AppException with _$AppException implements Exception {
  const factory AppException.network({
    required String message,
    int? statusCode,
  }) = NetworkException;

  const factory AppException.auth({required String message, String? sasoCode}) =
      AuthException;

  const factory AppException.notFound({required String resource}) =
      NotFoundException;

  const factory AppException.validation({
    required String field,
    required String message,
  }) = ValidationException;

  const factory AppException.unknown({required String message, Object? cause}) =
      UnknownException;
}
