import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey = 'f7ffa86223eac45de1c2586554724f8c'; 
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherModel> fetchWeather(String cityName) async {
    final url = Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric&lang=fr');

    try {
      final response = await http.get(url);

      switch (response.statusCode) {
        case 200:
          final Map<String, dynamic> data = json.decode(response.body);
          return WeatherModel.fromJson(data);
        case 401:
          throw Exception("Clé API invalide. Vérifiez votre configuration.");
        case 404:
          throw Exception("Ville \"$cityName\" introuvable. Vérifiez l'orthographe.");
        case 429:
          throw Exception("Limite de requêtes atteinte. Réessayez plus tard.");
        default:
          throw Exception("Erreur serveur (code: ${response.statusCode}).");
      }
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        throw Exception("Pas de connexion internet ou serveur inaccessible.");
      }
      rethrow;
    }
  }
}