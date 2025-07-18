import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const WeatherScreen({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String weatherCondition = 'Clear';
  double temperature = 0.0;
  int humidity = 0;
  double windSpeed = 0.0;
  int pressure = 0;

  final TextEditingController cityController = TextEditingController();

  final String apiKey = 'a55f2dbb01cec59b0d5dd3c1b89bfacf'; 

  IconData getWeatherIcon() {
    switch (weatherCondition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud_queue;
      case 'rain':
      case 'drizzle':
        return Icons.umbrella;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.cloud;
    }
  }

  void resetWeather() {
    setState(() {
      weatherCondition = 'Clear';
      temperature = 0.0;
      humidity = 0;
      windSpeed = 0.0;
      pressure = 0;
      cityController.clear();
    });
  }

  Future<void> fetchWeather(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        weatherCondition = data['weather'][0]['main'];
        temperature = data['main']['temp'].toDouble();
        humidity = data['main']['humidity'];
        windSpeed = data['wind']['speed'].toDouble();
        pressure = data['main']['pressure'];
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('City not found or API error!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final iconColor = isDark ? Colors.white : Colors.black;

    final time = DateFormat('hh:mm a').format(DateTime.now());
    final date = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: isDark
            ? const Text(
                'Weather App',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.blue, Colors.orange],
                ).createShader(bounds),
                child: const Text(
                  'Weather App',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),
          IconButton(onPressed: resetWeather, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Weather Card
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey[200],
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              time,
                              style: TextStyle(color: iconColor, fontSize: 18),
                            ),
                            Text(
                              date,
                              style: TextStyle(
                                color: iconColor.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Icon(getWeatherIcon(), size: 64, color: iconColor),
                            const SizedBox(height: 15),
                            Text(
                              '${temperature.toStringAsFixed(1)}°C',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: iconColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              weatherCondition,
                              style: TextStyle(fontSize: 20, color: iconColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Hourly Forecast (Dummy as API provides current weather only here)
              Text(
                'Hourly Forecast',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    final times = [
                      '03:00',
                      '06:00',
                      '09:00',
                      '12:00',
                      '15:00',
                      '18:00',
                      '21:00',
                      '00:00',
                    ];
                    return Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            times[index],
                            style: TextStyle(color: iconColor),
                          ),
                          const SizedBox(height: 5),
                          Icon(Icons.cloud, color: iconColor),
                          const SizedBox(height: 5),
                          Text('30°C', style: TextStyle(color: iconColor)),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              /// Additional Info
              Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InfoTile(
                    label: 'Humidity',
                    value: '$humidity%',
                    color: iconColor,
                  ),
                  InfoTile(
                    label: 'Wind',
                    value: '${windSpeed.toStringAsFixed(1)} km/h',
                    color: iconColor,
                  ),
                  InfoTile(
                    label: 'Pressure',
                    value: '$pressure hPa',
                    color: iconColor,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// Search City
              Text(
                'Search City Weather',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: cityController,
                style: TextStyle(color: iconColor),
                onSubmitted: (value) {
                  fetchWeather(value);
                },
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  hintStyle: TextStyle(color: iconColor.withOpacity(0.5)),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      fetchWeather(cityController.text);
                    },
                    icon: Icon(Icons.search, color: iconColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: color.withOpacity(0.7))),
      ],
    );
  }
}
