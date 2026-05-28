// lib/app/data/exceptions/app_exception.dart
import 'package:dio/dio.dart';

abstract class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException({required this.message, this.prefix});

  @override
  String toString() {
    return "${prefix ?? ''}$message";
  }
}

class NetworkException extends AppException {
  NetworkException({
    super.message = 'Koneksi internet bermasalah. Periksa koneksi Anda.',
  }) : super(prefix: 'Koneksi Error: ');
}

class UnauthorizedException extends AppException {
  UnauthorizedException({
    super.message = 'Sesi Anda telah berakhir. Silakan login kembali.',
  }) : super(prefix: 'Autentikasi Gagal: ');
}

class ForbiddenException extends AppException {
  ForbiddenException({
    super.message = 'Anda tidak memiliki hak akses untuk tindakan ini.',
  }) : super(prefix: 'Akses Ditolak: ');
}

class NotFoundException extends AppException {
  NotFoundException({super.message = 'Data atau layanan tidak ditemukan.'})
    : super(prefix: 'Tidak Ditemukan: ');
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;
  ValidationException({
    super.message = 'Data yang dikirim tidak valid.',
    this.errors,
  }) : super(prefix: 'Validasi Gagal: ');
}

class ServerException extends AppException {
  ServerException({
    super.message =
        'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.',
  }) : super(prefix: 'Server Error: ');
}

class UnexpectedException extends AppException {
  UnexpectedException({super.message = 'Terjadi kesalahan tidak terduga.'})
    : super(prefix: 'Error: ');
}

class AppExceptionMapper {
  static AppException fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException();
      case DioExceptionType.badResponse:
        final response = dioException.response;
        final statusCode = response?.statusCode;
        final data = response?.data;

        String customMessage = '';
        if (data is Map && data.containsKey('message')) {
          customMessage = data['message'].toString();
        }

        switch (statusCode) {
          case 400:
            Map<String, dynamic>? validationErrors;
            if (data is Map && data.containsKey('errors')) {
              validationErrors = Map<String, dynamic>.from(data['errors']);
            }
            return ValidationException(
              message: customMessage.isNotEmpty
                  ? customMessage
                  : 'Permintaan tidak valid.',
              errors: validationErrors,
            );
          case 401:
            return UnauthorizedException(
              message: customMessage.isNotEmpty
                  ? customMessage
                  : 'Sesi Anda telah berakhir. Silakan login kembali.',
            );
          case 403:
            return ForbiddenException(
              message: customMessage.isNotEmpty
                  ? customMessage
                  : 'Anda tidak memiliki akses.',
            );
          case 404:
            return NotFoundException(
              message: customMessage.isNotEmpty
                  ? customMessage
                  : 'Data tidak ditemukan.',
            );
          case 500:
          case 502:
          case 503:
            return ServerException(
              message: customMessage.isNotEmpty
                  ? customMessage
                  : 'Server sedang bermasalah.',
            );
          default:
            return UnexpectedException(
              message: customMessage.isNotEmpty
                  ? customMessage
                  : 'Terjadi kesalahan pada sistem.',
            );
        }
      case DioExceptionType.cancel:
        return UnexpectedException(message: 'Permintaan dibatalkan.');
      default:
        return UnexpectedException(message: 'Tidak dapat terhubung ke server.');
    }
  }
}
