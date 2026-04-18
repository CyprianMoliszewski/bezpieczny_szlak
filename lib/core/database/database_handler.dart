import 'package:bezpieczny_szlak/core/database/database_init.dart';
import 'package:bezpieczny_szlak/features/weather/data/weather_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {
  ///
  /// SINGLETON + CONN WITH DATABASE
  ///
  static final DatabaseHandler _instance = DatabaseHandler._internal();

  factory DatabaseHandler() => _instance;

  DatabaseHandler._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    
    _db = await DatabaseInit().init(); 
    return _db!;
  }

  ///
  /// WEATHER FORECAST
  ///
  
  // DELETE OLD DATA AND INSERT NEW ONE
  Future<void> saveWeatherForecast(WeatherForecast forecast) async {
    final db = await database;

    await db.delete('weather_forecast');

    await db.insert(
      'weather_forecast',
      forecast.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // SELECT
  Future<WeatherForecast?> getLatestWeatherForecast() async {
    final db = await database;

    final List<Map<String, dynamic>> forecastMaps = await db.query(
      'weather_forecast',
      limit: 1,
    );

    if (forecastMaps.isEmpty) return null;

    final List<Map<String, dynamic>> detailMaps = await db.query(
      'weather_forecast_details',
      orderBy: 'WFD_time ASC',
    );

    List<WeatherForecastDetail> details = detailMaps.map((map) {
      return WeatherForecastDetail(
        time: DateTime.parse(map['WFD_time']),
        temperature: (map['WFD_temperature'] as num).toDouble(),
        windSpeed: (map['WFD_wind_speed'] as num).toDouble(),
        precipitation: (map['WFD_precipitation'] as num).toDouble(),
        status: map['WFD_status'] as String,
      );
    }).toList();

    final mainMap = forecastMaps.first;
    
    return WeatherForecast(
      time: DateTime.parse(mainMap['WF_time']),
      lat: (mainMap['WF_lat'] as num).toDouble(),
      lon: (mainMap['WF_lon'] as num).toDouble(),
      details : details,
    );
  }

  ///
  /// WEATHER FORECAST DETAILS
  ///
  
  // DELETE OLD DATA AND INSERT NEW ONE
  Future<void> saveWeatherForecastDetails(List<WeatherForecastDetail> details) async {
    final db = await database;

    await db.delete('weather_forecast_details');

    await db.delete(
      'sqlite_sequence', 
      where: 'name = ?', 
      whereArgs: ['weather_forecast_details']
    );
    
    final batch = db.batch();
    
    for (var detail in details) {
      batch.insert(
        'weather_forecast_details',
        detail.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }
}