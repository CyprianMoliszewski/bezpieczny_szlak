import 'package:bezpieczny_szlak/features/weather/data/weather_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {

  final Map<String, String> _headers = {
    'User-Agent': 'bezpieczny_szlak-Development/1.0 (cmoliszewski1@gmail.com)'
  };

  Future<WeatherForecast> getWeatherForecastFromAPI(double lat, double lon) async {
    final url = Uri.parse(
        'https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=$lat&lon=$lon');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        final forecast = WeatherForecast(
          lat : lat,
          lon : lon,
          time : DateTime.now(),
          details : _parseDetails(data)
          );

        return forecast;

      } else {
        throw Exception({response.statusCode});
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  List<WeatherForecastDetail> _parseDetails(Map<String, dynamic> data) {

    List<WeatherForecastDetail> detailsList = [];
    
    final List timeseries = data['properties']['timeseries'];

    for (var entry in timeseries.take(24)) {
      final time = DateTime.parse(entry['time']);
      final instant = entry['data']['instant']['details'];
      
      final next1h = entry['data']['next_1_hours'];
      
      detailsList.add(
        WeatherForecastDetail(
          time : time,
          temperature: (instant['air_temperature'] as num).toDouble(),
          windSpeed: (instant['wind_speed'] as num).toDouble(),
          precipitation: next1h != null 
              ? (next1h['details']['precipitation_amount'] as num).toDouble() 
              : 0.0,
          status: next1h != null 
              ? next1h['summary']['symbol_code'] 
              : 'clearsky_day',
        ),
      );
    }

    return detailsList;
  }


  void getWeatherForecastForWidget(){
    //sprawdzenie czy internet
    //sprawdzenie godizny
    //decyzja czy z neta czy lokalnie
    //zwrocenie pogody
  }
}