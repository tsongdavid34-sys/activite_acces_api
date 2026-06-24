import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherController extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  WeatherModel? _weather;
  bool _isLoading = false;
  String _errorMessage = '';
  List<String> _searchHistory = [];

  WeatherModel? get weather => _weather;
  bool get kIsLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<String> get searchHistory => _searchHistory;
  bool get hasData => _weather != null;
  bool get hasError => _errorMessage.isNotEmpty;

  WeatherController() {
    _loadSearchHistory();
  }

  Future<void> fetchWeather(String city) async {
    if (city.trim().isEmpty) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final weatherData = await _weatherService.getWeather(city);
      _weather = weatherData;
      _addToHistory(city);
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _weather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _addToHistory(String city) async {
    final formattedCity = city.trim().toLowerCase();
    
    _searchHistory.remove(formattedCity);
    _searchHistory.insert(0, formattedCity);

    if (_searchHistory.length > 5) {
      _searchHistory.removeLast();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('weather_history', _searchHistory);
    notifyListeners();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList('weather_history') ?? [];
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _searchHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('weather_history');
    notifyListeners();
  }
}