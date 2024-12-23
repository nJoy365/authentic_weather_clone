import 'package:authentic_weather_clone/helpers.dart' as helpers;
import 'dart:math';

class WeatherDescription {
  String text;
  String subtext;
  WeatherDescription(this.text, this.subtext);
}

Future<WeatherDescription> getWeatherDescription(
    String weatherMain, String weatherDescription, double weatherTemp) async {
  print(
      "Getting weather description for $weatherMain, $weatherDescription, $weatherTemp");
  WeatherDescription weatherDesc = WeatherDescription("", "");
  Map<String, dynamic> descriptions =
      await helpers.loadJson("weatherDescriptions");
  final random = Random();
  int randomIndex =
      random.nextInt(descriptions[weatherMain][weatherDescription].length);
  weatherDesc.text =
      descriptions[weatherMain][weatherDescription][randomIndex]["text"];
  print("Weather description: $weatherDesc.text");
  weatherDesc.subtext =
      descriptions[weatherMain][weatherDescription][randomIndex]["subtext"];
  print("Weather subtext: $weatherDesc.subtext");

  return weatherDesc;
}
