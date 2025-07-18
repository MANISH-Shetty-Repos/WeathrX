import 'package:flutter/material.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,

            child: Card(
              child: Column(
                children: [
                  Text(
                    '300°F',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Placeholder(fallbackHeight: 250),
          const SizedBox(height: 20),

          const Placeholder(fallbackHeight: 150),
        ],
      ),
    );
  }
}
