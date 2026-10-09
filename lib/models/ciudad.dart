/// Representa una ciudad de Colombia con sus coordenadas geográficas.
class Ciudad {
  final String nombre;
  final double latitud;
  final double longitud;

  const Ciudad(this.nombre, this.latitud, this.longitud);

  static const List<Ciudad> colombia = [
    Ciudad('Bogotá', 4.61, -74.08),
    Ciudad('Medellín', 6.25, -75.56),
    Ciudad('Cali', 3.44, -76.52),
    Ciudad('Barranquilla', 10.96, -74.80),
    Ciudad('Cartagena', 10.39, -75.51),
    Ciudad('Bucaramanga', 7.12, -73.12),
    Ciudad('Pereira', 4.81, -75.69),
    Ciudad('Santa Marta', 11.24, -74.20),
  ];
}
