import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bezpieczny_szlak/features/weather/data/weather_model.dart';
import 'package:bezpieczny_szlak/core/database/database_handler.dart';
import 'package:bezpieczny_szlak/features/weather/data/weather_service.dart';

class WeatherRepository {
  final _db = DatabaseHandler();
  final _api = WeatherService();

  Future<WeatherResult> getWeather(double lat, double lon) async {
    // 1. Pobierz dane z bazy
    final localForecast = await _db.getLatestWeatherForecast(); // Musisz dopisać tę metodę w DBHandler

    if (localForecast == null) {
      // Brak jakichkolwiek danych - musimy uderzyć do API
      return await _fetchFromApiAndSave(lat, lon);
    }

    // 2. Sprawdź warunki
    bool isOld = _isDataOlderThan(localForecast.time, 4);
    bool hasRisk = _checkStormRisk(localForecast.details, 2);

    // 3. Decyzja
    if (!isOld && !hasRisk) {
      return WeatherResult(forecast: localForecast);
    }

    // Jeśli dane są stare LUB jest ryzyko - próbujemy odświeżyć
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return WeatherResult(
        forecast: localForecast,
        warning: "Brak internetu. Dane mogą być nieaktualne!"
      );
    }

    // Mamy net - pobieramy świeżynkę
    return await _fetchFromApiAndSave(lat, lon);
  }

  // --- HELPERY ---

  Future<WeatherResult> _fetchFromApiAndSave(double lat, double lon) async {
    try {
      final freshData = await _api.getWeatherForecastFromAPI(lat, lon);
      await _db.saveWeatherForecast(freshData);
      await _db.saveWeatherForecastDetails(freshData.details);
      return WeatherResult(forecast: freshData);
    } catch (e) {
      return WeatherResult(warning: "Błąd pobierania danych: $e");
    }
  }

  bool _isDataOlderThan(DateTime time, int hours) {
    return DateTime.now().difference(time).inHours >= hours;
  }

  bool _checkStormRisk(List<WeatherForecastDetail> details, int hoursLimit) {
    final now = DateTime.now();
    // Szukamy w detalach rekordów z najbliższych X godzin
    final nextHours = details.where((d) => 
      d.time.isAfter(now) && 
      d.time.isBefore(now.add(Duration(hours: hoursLimit)))
    );

    for (var hour in nextHours) {
      // Definicja "ryzyka": opady > 0 LUB status zawiera słowo 'rain', 'bolt', 'snow'
      if (hour.precipitation > 0 || 
          hour.status.contains('rain') || 
          hour.status.contains('sleet') || 
          hour.status.contains('snow')) {
        return true;
      }
    }
    return false;
  }
}