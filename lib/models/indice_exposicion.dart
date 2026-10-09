/// Índice de exposición diaria = promedio PM2.5 × horas de exposición.
class IndiceExposicion {
  final double promedioPm25;
  final double horas;

  IndiceExposicion({required this.promedioPm25, required this.horas});

  double get valor => promedioPm25 * horas;

  /// < 100 Bajo, 100–200 Moderado, > 200 Alto.
  String get nivelRiesgo {
    if (valor < 100) return 'Bajo';
    if (valor <= 200) return 'Moderado';
    return 'Alto';
  }
}
