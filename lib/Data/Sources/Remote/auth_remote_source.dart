import 'package:dio/dio.dart';
import '../../../Common/Helper/utils.dart';


class AuthRemoteSource {
  final Dio dio;

  AuthRemoteSource(this.dio);

  Future<bool> ping(String baseUrl, String password) async {
    try {
      final response = await dio.get(
        mkCmd(baseUrl, 'ls'),
        queryParameters: {'path': '~'},
        options: Options(headers: {'Authorization': password}),
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }
}