import 'package:flutter/material.dart';
import 'package:weather_app/weather_scree.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:ThemeData.dark(useMaterial3: true),
      home:const WeatherScreen(),
    );
  }
} 