import 'dart:convert';
import 'package:http/http.dart' as http;

class TodoApi {
  final String baseUrl;
  final String token;

  TodoApi({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final res = await http.get(
      Uri.parse('$baseUrl/blogs-api'),
      headers: _headers,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load tasks');
    }

    final body = jsonDecode(res.body);

    return List<Map<String, dynamic>>.from(body['data']);
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/blogs-api'),
      headers: _headers,
      body: jsonEncode(data),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to create task');
    }

    return body;
  }

  Future<Map<String, dynamic>> updateTask(
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/blogs-api/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to update task');
    }

    return body;
  }

  Future<Map<String, dynamic>> deleteTask(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/blogs-api/$id'),
      headers: _headers,
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(body['message'] ?? 'Failed to delete task');
    }

    return body; // 👈 return message
  }
}
