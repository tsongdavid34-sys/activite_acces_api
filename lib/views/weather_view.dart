import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/weather_controller.dart';
import '../utils/weather_utils.dart';
import '../widgets/weather_widgets.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> with TickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _fadeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherController>(
      builder: (context, controller, child) {
        if (controller.hasData && _fadeController.status == AnimationStatus.dismissed) {
          _triggerAnimation();
        }

        final gradientColors = controller.hasData
            ? WeatherUtils.getGradientColors(controller.weather!.iconCode)
            : [const Color(0xFF1F1C2C), const Color(0xFF928DAB)];

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Application Météo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 15),

                    WeatherSearchBar(
                      controller: _cityController,
                      onSearch: () {
                        if (_cityController.text.isNotEmpty) {
                          _fadeController.reset();
                          controller.fetchWeather(_cityController.text);
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    if (controller.searchHistory.isNotEmpty)
                      SizedBox(
                        height: 35,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.searchHistory.length,
                          itemBuilder: (context, index) {
                            final city = controller.searchHistory[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ActionChip(
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                label: Text(
                                  WeatherUtils.capitalize(city),
                                  style: const TextStyle(
                                    color: Color(0xFF1F1C2C), 
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () {
                                  _cityController.text = city;
                                  _fadeController.reset();
                                  controller.fetchWeather(city);
                                },
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 15),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Builder(
                          builder: (context) {
                            if (controller.kIsLoading) {
                              return const WeatherLoadingWidget();
                            }

                            if (controller.hasError) {
                              return WeatherErrorWidget(
                                message: controller.errorMessage,
                                onRetry: () {
                                  if (_cityController.text.isNotEmpty) {
                                    controller.fetchWeather(_cityController.text);
                                  }
                                },
                              );
                            }

                            if (controller.hasData) {
                              final weather = controller.weather!;
                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.location_on, color: Colors.white, size: 24),
                                        const SizedBox(width: 5),
                                        Text(
                                          "${weather.cityName}, ${weather.country}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      WeatherUtils.formatDate(DateTime.now()),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: 15,
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 15),

                                    Text(
                                      WeatherUtils.getWeatherEmoji(weather.iconCode),
                                      style: const TextStyle(fontSize: 70),
                                    ),
                                    
                                    Text(
                                      WeatherUtils.formatTemp(weather.temperature),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 55,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                    
                                    Text(
                                      WeatherUtils.capitalize(weather.description),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: WeatherDetailCard(
                                            title: "Ressenti",
                                            value: WeatherUtils.formatTemp(weather.feelsLike),
                                            icon: Icons.thermostat,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: WeatherDetailCard(
                                            title: "Vent",
                                            value: "${weather.windSpeed} m/s",
                                            icon: Icons.air,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 10),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: WeatherDetailCard(
                                            title: "Humidité",
                                            value: "${weather.humidity}%",
                                            icon: Icons.water_drop,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: WeatherDetailCard(
                                            title: "Pression",
                                            value: "${weather.pressure} hPa",
                                            icon: Icons.compress,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 10),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: WeatherDetailCard(
                                            title: "Lever du soleil",
                                            value: WeatherUtils.formatTime(weather.sunrise),
                                            icon: Icons.wb_sunny_outlined,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: WeatherDetailCard(
                                            title: "Coucher du soleil",
                                            value: WeatherUtils.formatTime(weather.sunset),
                                            icon: Icons.nights_stay_outlined,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 60),
                                  Icon(Icons.cloud_queue, color: Colors.white.withValues(alpha: 0.4), size: 100),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Aucune donnée.\nRecherchez une ville pour commencer !",
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}