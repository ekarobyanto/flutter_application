import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HttpClientNotifier extends ChangeNotifier {
  final http.BaseClient client;
  final String baseUrl;
  HttpClientNotifier({required this.client, required this.baseUrl});

  Uri parseUri(String url) {
    return Uri.parse("$baseUrl$url");
  }

  Future<T?> get<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      Uri uri = parseUri(url);
      http.Response response = await client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return fromJson(jsonData);
      } else {
        debugPrint("❌ Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      return null;
    }
  }

  Future<T?> post<T>(
    String url,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, String>? headers,
  }) async {
    try {
      Uri uri = parseUri(url);
      headers ??= {"Content-Type": "application/json"};
      http.Response response = await client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return fromJson(jsonData);
      } else {
        debugPrint("❌ Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      return null;
    }
  }
}

class JsonResponse {
  final String id;
  final String username;

  JsonResponse({required this.username, required this.id});
  JsonResponse.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        username = json["username"];
}
