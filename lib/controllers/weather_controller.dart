import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherController extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _weather;
  String _errorMessage = '';
  final List<String> _searchHistory = [];

  WeatherStatus get status => _status;
  WeatherModel? get weather => _weather;
  String get errorMessage => _errorMessage;
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  bool get kIsLoading => _status == WeatherStatus.loading;
  bool get hasData => _status == WeatherStatus.success && _weather != null;
  bool get hasError => _status == WeatherStatus.error;

  Future<void> fetchWeather(String cityName) async {
    if (cityName.trim().isEmpty) return;

    _status = WeatherStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _weather = await _weatherService.fetchWeather(cityName.trim());
      _status = WeatherStatus.success;
      
      final formattedName = cityName.trim();
      _searchHistory.removeWhere((element) => element.toLowerCase() == formattedName.toLowerCase());
      _searchHistory.insert(0, formattedName);
      if (_searchHistory.length > 5) {
        _searchHistory.removeLast();
      }
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }
}