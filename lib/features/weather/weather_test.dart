import 'package:flutter/material.dart';
import 'package:bezpieczny_szlak/core/database/database_init.dart';
import 'package:bezpieczny_szlak/features/weather/data/weather_repository.dart';

// Ta funkcja pozwoli Ci uruchomić to jako osobną aplikację
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicjalizacja bazy
  await DatabaseInit().init();

  runApp(const WeatherTestApp());
}

class WeatherTestApp extends StatelessWidget {
  const WeatherTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Weather Integration Test")),
        body: const WeatherTestRunner(),
      ),
    );
  }
}

class WeatherTestRunner extends StatefulWidget {
  const WeatherTestRunner({super.key});

  @override
  State<WeatherTestRunner> createState() => _WeatherTestRunnerState();
}

class _WeatherTestRunnerState extends State<WeatherTestRunner> {
  String _logs = "Kliknij przycisk, aby rozpocząć test...";
  bool _isLoading = false;

  void _log(String message) {
    setState(() {
      _logs += "\n$message";
    });
    print(message);
  }

 Future<void> _runFullTest() async {
    setState(() {
      _logs = "🚀 URUCHAMIANIE TESTU...";
      _isLoading = true;
    });

    try {
      final repo = WeatherRepository();
      const lat = 51.7592;
      const lon = 19.4560;

      _log("📍 Cel: Łódź ($lat, $lon)");
      
      // --- TEST 1: PIERWSZY STRZAŁ (API LUB BAZA) ---
      _log("📡 Test 1: Pobieranie danych...");
      final stopwatch = Stopwatch()..start();
      final result = await repo.getWeather(lat, lon);
      stopwatch.stop();

      if (result.forecast != null) {
        _log("✅ Sukces! Pobrano ${result.forecast!.details.length} rekordów.");
        _log("⏱️ Czas operacji: ${stopwatch.elapsedMilliseconds}ms");
        
        _log("\n--- PEŁNA LISTA PROGNOZY (24h) ---");
        for (var d in result.forecast!.details) {
          // Wyświetlamy wszystkie rekordy
          _log("${d.time.hour.toString().padLeft(2, '0')}:00 | ${d.temperature.toString().padRight(4)}°C | Wiatr: ${d.windSpeed.toString().padRight(4)}m/s | Opady: ${d.precipitation}mm | [${d.status}]");
        }
      }

      // --- PAUZA 10 SEKUND ---
      _log("\n⏳ Czekam 10 sekund przed kolejnym testem...");
      await Future.delayed(const Duration(seconds: 10));

      // --- TEST 2: CACHE (DRUGI STRZAŁ) ---
      _log("💾 Test 2: Ponowne wywołanie (Sprawdzamy CACHE)...");
      stopwatch.reset();
      stopwatch.start();
      final cacheResult = await repo.getWeather(lat, lon);
      stopwatch.stop();

      if (cacheResult.forecast != null) {
        _log("✅ Dane pobrane!");
        _log("⏱️ Czas z cache: ${stopwatch.elapsedMilliseconds}ms");
        _log("ℹ️ (Jeśli czas jest < 100ms, to znaczy, że baza danych śmiga aż miło)");
      }

    } catch (e) {
      _log("💥 BŁĄD TESTU: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _isLoading ? null : _runFullTest,
            child: Text(_isLoading ? "Testuję..." : "ODPALAJ TEST"),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.black87,
              child: SingleChildScrollView(
                child: Text(
                  _logs,
                  style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}