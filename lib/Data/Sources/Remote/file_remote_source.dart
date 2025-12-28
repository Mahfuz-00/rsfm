import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../Common/Helper/utils.dart';
import '../../../Data/Models/file_model.dart';


class FileRemoteSource {
  final Dio dio;
  FileRemoteSource(this.dio);

  Future<List<FileModel>> getFiles(String baseUrl, String password, String path) async {
    final response = await dio.get(
      mkCmd(baseUrl, 'ls'),
      queryParameters: {'path': path},
      options: Options(headers: {'Authorization': password}),
    );
    print('Loaded File : $response');
    return _handleResponseList(response);
  }

  Future<void> createDir(String baseUrl, String password, String path, String dirname) async {
    final response = await dio.get(
      mkCmd(baseUrl, 'mkdir/$dirname'),
      queryParameters: {'path': path},
      options: Options(headers: {'Authorization': password}),
    );
    _throwIfNotSuccess(response);
  }

  Future<void> createFile(String baseUrl, String password, String path, String fname) async {
    final response = await dio.get(
      mkCmd(baseUrl, 'newfile/$fname'),
      queryParameters: {'path': path},
      options: Options(headers: {'Authorization': password}),
    );
    _throwIfNotSuccess(response);
  }

  Future<void> touch(String baseUrl, String password, String path, String fname) async {
    final response = await dio.get(
      mkCmd(baseUrl, 'touch/$fname'),
      queryParameters: {'path': path},
      options: Options(headers: {'Authorization': password}),
    );
    _throwIfNotSuccess(response);
  }

  Future<void> delete(String baseUrl, String password, String path) async {
    final response = await dio.delete(
      mkCmd(baseUrl, 'rm'),
      queryParameters: {'path': path},
      options: Options(headers: {'Authorization': password}),
    );
    _throwIfNotSuccess(response);
  }

  Future<String> getFileContent(String baseUrl, String password, String path) async {
    final response = await dio.get(
      mkCmd(baseUrl, 'cat'),
      queryParameters: {'path': path},
      options: Options(headers: {'Authorization': password}),
    );
    final data = jsonDecode(response.data);
    if (data['success'] == true) {
      return data['content'] as String;
    }
    throw Exception(data['message'] ?? 'Failed to read file');
  }

  Future<void> saveFileContent(String baseUrl, String password, String path, String content) async {
    final response = await dio.post(
      mkCmd(baseUrl, 'put_data'),
      data: {'content': content},
      queryParameters: {'path': path},
      options: Options(headers: {'Authorization': password}),
    );
    _throwIfNotSuccess(response);
  }

  List<FileModel> _handleResponseList(Response response) {
    if (response.statusCode == 200) {
      print('Response: $response');
      final data = response.data;
      print('Parsed Data: $data');
      if (data['success'] == true) {
        return (data['list'] as List).map((e) => FileModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception(data['message'] ?? 'Unknown error');
    }
    throw Exception('Failed to load directory');
  }

  void _throwIfNotSuccess(Response response) {
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 202) {
      final data = jsonDecode(response.data);
      throw Exception(data['message'] ?? 'Request failed');
    }
  }
}