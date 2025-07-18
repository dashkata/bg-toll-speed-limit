import 'package:dio/dio.dart';

class ConnectionException extends DioException {
  ConnectionException({required DioException super.error, this.errorMessage})
    : super(requestOptions: error.requestOptions);

  String? errorMessage;

  @override
  String get message => errorMessage ?? '';
}
