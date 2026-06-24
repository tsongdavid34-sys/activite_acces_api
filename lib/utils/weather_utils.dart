import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherUtils {
  // Constructeur privé pour empêcher l'instanciation (uniquement des méthodes statiques)
  WeatherUtils._();

  /// Met en majuscule la première lettre d'une chaîne
  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Formate la température en chaîne lisible (ex: 23°C)
  static String formatTemp(double temp) {
    return '${temp.toStringAsFixed(0)}°C';
  }

  /// Formate l'heure en HH:mm
  static String formatTime(DateTime dt) {
    return DateFormat('HH:mm').format(dt);
  }

  /// Formate la date en français complet
  static String formatDate(DateTime dt) {
    return capitalize(DateFormat('EEEE d MMMM yyyy', 'fr').format(dt));
  }

  /// Retourne l'emoji correspondant au code d'icône d'OpenWeather
  static String getWeatherEmoji(String iconCode) {
    if (iconCode.startsWith('01')) return '☀️'; // Ciel dégagé
    if (iconCode.startsWith('02')) return '⛅'; // Quelques nuages
    if (iconCode.startsWith('03')) return '☁️'; // Nuages épars
    if (iconCode.startsWith('04')) return '☁️'; // Nuages brisés
    if (iconCode.startsWith('09')) return '🌧️'; // Pluie d'averses
    if (iconCode.startsWith('10')) return '🌦️'; // Pluie
    if (iconCode.startsWith('11')) return '🌩️'; // Orage
    if (iconCode.startsWith('13')) return '❄️'; // Neige
    if (iconCode.startsWith('50')) return '🌫️'; // Brouillard
    return '✨';
  }

  /// Retourne les couleurs du dégradé selon la météo (Code icône)
  static List<Color> getGradientColors(String iconCode) {
    // Si c'est la nuit (indiqué par 'n' à la fin du code icône d'OpenWeather)
    if (iconCode.endsWith('n')) {
      return [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]; // Bleu marine très foncé
    }

    // Dégradés selon le type de temps en journée
    if (iconCode.startsWith('01')) {
      // Soleil / Ciel dégagé
      return [const Color(0xFF56CCF2), const Color(0xFF2F80ED)]; // Bleu ciel
    } else if (iconCode.startsWith('02') || iconCode.startsWith('03') || iconCode.startsWith('04')) {
      // Nuages
      return [const Color(0xFF61a5c2), const Color(0xFF4c5c68)]; // Gris bleu
    } else if (iconCode.startsWith('09') || iconCode.startsWith('10') || iconCode.startsWith('11')) {
      // Pluie ou Orage
      return [const Color(0xFF2B5876), const Color(0xFF4E4376)]; // Bleu foncé
    } else {
      // Par défaut (Brouillard, Neige, etc.)
      return [const Color(0xFF757F9A), const Color(0xFFD7DDE8)];
    }
  }
}