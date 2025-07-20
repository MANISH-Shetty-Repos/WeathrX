import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HourlyWeather {
  final String time;
  final double temp;

  HourlyWeather({required this.time, required this.temp});
}

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

  String selectedCity = 'Udupi';
  final TextEditingController cityController = TextEditingController();
  List<HourlyWeather> hourlyForecast = [];

  final String apiKey = 'a55f2dbb01cec59b0d5dd3c1b89bfacf'; // Replace with your API key

  @override
  void initState() {
    super.initState();
    fetchWeather(selectedCity);
  }

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
      selectedCity = 'Udupi';
      weatherCondition = 'Clear';
      temperature = 0.0;
      humidity = 0;
      windSpeed = 0.0;
      pressure = 0;
      cityController.clear();
      hourlyForecast.clear();
    });
    fetchWeather(selectedCity);
  }

  Future<void> fetchWeather(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        selectedCity = city[0].toUpperCase() + city.substring(1);
        weatherCondition = data['weather'][0]['main'];
        temperature = data['main']['temp'].toDouble();
        humidity = data['main']['humidity'];
        windSpeed = data['wind']['speed'].toDouble();
        pressure = data['main']['pressure'];
      });

      fetchHourlyForecast(city);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('City not found or API error!')),
      );
    }
  }

  Future<void> fetchHourlyForecast(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['list'];

      List<HourlyWeather> tempHourly = [];

      for (int i = 0; i < 8; i++) { // next 8 * 3 hours = 24 hours, you can adjust
        final item = list[i];
        final time = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final temp = item['main']['temp'].toDouble();

        tempHourly.add(HourlyWeather(
          time: DateFormat('hh:mm a').format(time),
          temp: temp,
        ));
      }

      setState(() {
        hourlyForecast = tempHourly;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hourly forecast fetching error!')),
      );
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
        title: Text(
          'WeatherX',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: iconColor,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Weather Card
            SizedBox(
              width: double.infinity,
              child: Card(
                color:
                    isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
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
                            selectedCity,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            time,
                            style: TextStyle(color: iconColor, fontSize: 16),
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

            const SizedBox(height: 20),

            /// Hourly Forecast
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ' Hourly Forecast',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hourlyForecast.length,
                itemBuilder: (context, index) {
                  final item = hourlyForecast[index];
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
                        Text(item.time,
                            style:
                                TextStyle(color: iconColor, fontSize: 12)),
                        const SizedBox(height: 5),
                        Icon(Icons.thermostat, color: iconColor),
                        const SizedBox(height: 5),
                        Text('${item.temp.toStringAsFixed(0)}°C',
                            style: TextStyle(color: iconColor)),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// Additional Info
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(height: 10),

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

            const SizedBox(height: 20),

            /// Search City
            TextField(
              controller: cityController,
              style: TextStyle(color: iconColor),
              onSubmitted: (value) {
                fetchWeather(value);
                cityController.clear();
              },
              decoration: InputDecoration(
                hintText: 'Enter city name',
                hintStyle: TextStyle(color: iconColor.withOpacity(0.5)),
                filled: true,
                fillColor:
                    isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    fetchWeather(cityController.text);
                    cityController.clear();
                  },
                  icon: Icon(Icons.search, color: iconColor),
                ),
              ),
            ),
          ],
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
