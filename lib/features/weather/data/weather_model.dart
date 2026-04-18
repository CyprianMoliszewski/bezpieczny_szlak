///
/// MAIN INFO ABOUT WEATHER + LIST OF NEXT 24 HOURS
///
class WeatherForecast{
  final DateTime time;
  final double lat;
  final double lon;
  final List<WeatherForecastDetail> details;

  WeatherForecast({
    required this.lat, 
    required this.lon, 
    required this.time, 
    required this.details,
    });

    Map<String, dynamic> toMap() {
    return {
      'WF_id' : 1,
      'WF_time': time.toIso8601String(),
      'WF_lat': lat,
      'WF_lon': lon,
    };
  }
}

///
/// SINGLE HOUR INFO, CONTAINS TEMP,WIND,PERP AND STATUS
///
class WeatherForecastDetail{
  final DateTime time;
  final double temperature;
  final double windSpeed;
  final double precipitation;
  final String status;

  WeatherForecastDetail({
    required this.time,
    required this.temperature,
    required this.windSpeed,
    required this.precipitation,
    required this.status,
    });

  Map<String, dynamic> toMap() {
    return {
      'WFD_time': time.toIso8601String(),
      'WFD_temperature': temperature,
      'WFD_status': status,
      'WFD_precipitation': precipitation,
      'WFD_wind_speed': windSpeed,
    };
  }
}

///
/// THIS OBJECT GOES TO WIDGET - WHOLE FORECAST + POTENTIAL WARNING
///
class WeatherResult {
  final WeatherForecast? forecast;
  final String? warning;

  WeatherResult({this.forecast, this.warning});
}