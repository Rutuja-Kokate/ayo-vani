import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  const kGeminiApiKey = 'AIzaSyDXw8e5_bsMdl0Ipnz2W-R68-WXrFj2gMs';
  final url = 'https://generativelanguage.googleapis.com/v1beta/models?key=$kGeminiApiKey';
  
  try {
    final response = await dio.get(url);
    print('Models: ${response.data}');
  } on DioException catch (e) {
    print('DioError: ${e.response?.statusCode}');
    print('Response: ${e.response?.data}');
  } catch (e) {
    print('Error: $e');
  }
}
