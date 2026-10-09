import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ciudad.dart';

/// Consulta la Air Quality API de Open-Meteo.
class CalidadAireService {
  static const String _baseUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  /// Devuelve el promedio diario de PM2.5 (µg/m³) para la ciudad y fecha
  /// indicadas. La fecha debe tener formato yyyy-MM-dd.
  Future<double> obtenerPromedioPm25(Ciudad ciudad, String fecha) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': ciudad.latitud.toString(),
      'longitude': ciudad.longitud.toString(),
      'hourly': 'pm2_5',
      'start_date': fecha,
      'end_date': fecha,
      'timezone': 'America/Bogota',
    });

    final respuesta = await http.get(uri).timeout(const Duration(seconds: 15));
    if (respuesta.statusCode != 200) {
      final cuerpo = jsonDecode(respuesta.body);
      throw Exception(cuerpo['reason'] ?? 'Error HTTP ${respuesta.statusCode}');
    }

    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
    final valores = (datos['hourly']['pm2_5'] as List)
        .whereType<num>()
        .map((v) => v.toDouble())
        .toList();

    if (valores.isEmpty) {
      throw Exception('No hay datos de PM2.5 para esa fecha');
    }
    return valores.reduce((a, b) => a + b) / valores.length;
  }
}
