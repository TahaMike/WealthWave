import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionService {
  static const String _baseUrl = 'http://127.0.0.1:5000';

  static Future<Map<String, dynamic>> predictPriorityLevel(String date, double amount) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'date': date, 'amount': amount}),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> predictNextAmount(List<double> history) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/predict-next-amount'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'history': history}),
    );
    return json.decode(response.body);
  }
}
