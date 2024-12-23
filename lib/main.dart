import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'descriptions.dart';

Future<WeatherData> fetchWeatherData(double latitude, double longitude) async {
  final String apiKey = '3c18a24b88e87312af59f3b9f92fb0cf';
  final Uri url = Uri.parse(
      'http://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return WeatherData.fromJson(data);
  } else {
    throw Exception('Failed to fetch weather data');
  }
}

class WeatherData {
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final String weatherMain;
  final String weatherDescription;
  final String icon;

  WeatherData({
    this.temp = 0.0,
    this.feelsLike = 0.0,
    this.humidity = 0,
    this.windSpeed = 0.0,
    this.windDeg = 0,
    this.weatherMain = "",
    this.weatherDescription = "",
    this.icon = "",
  });
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temp: json['main']['temp'],
      feelsLike: json['main']['feels_like'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'],
      windDeg: json['wind']['deg'],
      weatherMain: json['weather'][0]['main'],
      weatherDescription: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentic Weather Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GeolocationApp(),
    );
  }
}

class GeolocationApp extends StatefulWidget {
  const GeolocationApp({super.key});

  @override
  State<GeolocationApp> createState() => _GeolocationAppState();
}

class _GeolocationAppState extends State<GeolocationApp> {
  late Future<Position>? _currentLocation;
  late Future<WeatherDescription>? _weatherDesc;
  late WeatherData _weatherData = WeatherData();
  late WeatherDescription _weatherDescription = WeatherDescription("", "");
  late bool servicePermission = false;
  late LocationPermission permission;
  Future<Position>? _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();

    if (!servicePermission) {
      print("Service Disabled");
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _currentLocation = _getCurrentLocation();
    _currentLocation?.then((position) {
      {
        fetchWeatherData(position.latitude, position.longitude)
            .then((weatherData) {
          setState(() {
            _weatherData = weatherData;
          });
        }).then((_) {
          _weatherDesc = getWeatherDescription(_weatherData.weatherMain,
              _weatherData.weatherDescription, _weatherData.temp);
          _weatherDesc?.then((weatherDesc) {
            setState(() {
              _weatherDescription = weatherDesc;
            });
          }).catchError((error) {
            print('Error fetching weather description: $error');
          });
        }).catchError((error) {
          print('Error fetching weather data: $error');
        });
      }
    });
    print(
        "${_weatherData.weatherMain} ${_weatherData.weatherDescription} ${_weatherData.temp}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 149, 165, 166),
        body: FutureBuilder<Position>(
            future: _currentLocation,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                //return Text('Error: ${snapshot.error}');
              }
              if (snapshot.hasData) {
                return Center(
                    child: SizedBox(
                        width: 350,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  width: 195,
                                  height: 300,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.fitHeight,
                                          alignment: FractionalOffset.center,
                                          image: NetworkImage(
                                              'https://openweathermap.org/img/wn/${_weatherData.icon}@4x.png')))),
                              Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _weatherDescription.text,
                                      style: GoogleFonts.arimo(
                                        textStyle: TextStyle(
                                          fontSize: 80,
                                          fontWeight: FontWeight.w700,
                                          height: 0.8,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 120,
                                    ),
                                    Text(
                                      _weatherDescription.subtext,
                                      style: GoogleFonts.arimo(
                                          textStyle: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w300,
                                              height: 0.8)),
                                    ),
                                    Container(height: 20)
                                  ])
                            ])));
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
