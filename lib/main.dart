import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controllers/weather_controller.dart';
import 'views/weather_view.dart';

void main() async {
  // Assure l'initialisation correcte des liaisons Flutter avant le code asynchrone
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialise les données de localisation pour formater les dates en français ('fr')
  await initializeDateFormatting('fr', null);
  
  runApp(
    // Injection du contrôleur MVC au niveau global de l'application
    ChangeNotifierProvider(
      create: (_) => WeatherController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Météo MVC',
      debugShowCheckedModeBanner: false, // Enlève la bannière "Debug"
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // Police claire et moderne
      ),
      home: const WeatherView(), // Définition de notre vue principale comme écran d'accueil
    );
  }
}