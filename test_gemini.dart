import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  const kGeminiApiKey = 'AIzaSyDXw8e5_bsMdl0Ipnz2W-R68-WXrFj2gMs';
  const model = 'gemini-1.5-flash-latest';
  final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$kGeminiApiKey';
  
  try {
    final response = await dio.post(
      url,
      data: {
        'contents': [
          {'role': 'user', 'parts': [{'text': 'Hello'}]}
        ]
      },
    );
    print('Success: ${response.statusCode}');
  } on DioException catch (e) {
    print('DioError: ${e.response?.statusCode}');
    print('Response: ${e.response?.data}');
  } catch (e) {
    print('Error: $e');
  }
}
