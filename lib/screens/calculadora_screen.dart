import 'package:flutter/material.dart';

import '../models/ciudad.dart';
import '../models/indice_exposicion.dart';
import '../services/calidad_aire_service.dart';

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _horasController = TextEditingController();
  final _service = CalidadAireService();

  Ciudad? _ciudad;
  bool _cargando = false;
  IndiceExposicion? _resultado;
  String? _error;

  @override
  void dispose() {
    _fechaController.dispose();
    _horasController.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) =>
      '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-'
      '${fecha.day.toString().padLeft(2, '0')}';

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: DateTime(2022, 8, 1),
      // Open-Meteo ofrece pronóstico de calidad del aire hasta ~5 días.
      lastDate: hoy.add(const Duration(days: 4)),
    );
    if (fecha != null) {
      _fechaController.text = _formatearFecha(fecha);
    }
  }

  Future<void> _calcular() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _resultado = null;
      _error = null;
    });

    try {
      final promedio = await _service.obtenerPromedioPm25(
        _ciudad!,
        _fechaController.text,
      );
      setState(() {
        _resultado = IndiceExposicion(
          promedioPm25: promedio,
          horas: double.parse(_horasController.text.replaceAll(',', '.')),
        );
      });
    } catch (e) {
      setState(() => _error = 'No se pudo consultar la API: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  Color _colorRiesgo(String nivel) {
    switch (nivel) {
      case 'Bajo':
        return Colors.green;
      case 'Moderado':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de Calidad del Aire')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<Ciudad>(
                initialValue: _ciudad,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  border: OutlineInputBorder(),
                ),
                items: Ciudad.colombia
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.nombre)))
                    .toList(),
                onChanged: (c) => setState(() => _ciudad = c),
                validator: (c) => c == null ? 'Seleccione una ciudad' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaController,
                readOnly: true,
                onTap: _seleccionarFecha,
                decoration: const InputDecoration(
                  labelText: 'Fecha de consulta',
                  hintText: 'AAAA-MM-DD',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Seleccione una fecha' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _horasController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Horas de exposición diaria',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final horas = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (horas == null) return 'Ingrese un número válido';
                  if (horas < 0 || horas > 24) return 'Debe estar entre 0 y 24';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cargando ? null : _calcular,
                child: _cargando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Calcular Nivel de Riesgo'),
              ),
              const SizedBox(height: 24),
              if (_resultado != null) ...[
                Text(
                  'PM2.5 promedio: ${_resultado!.promedioPm25.toStringAsFixed(1)} µg/m³',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Índice de exposición: ${_resultado!.valor.toStringAsFixed(1)}\n'
                  'Nivel de riesgo: ${_resultado!.nivelRiesgo}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: _colorRiesgo(_resultado!.nivelRiesgo),
                  ),
                ),
              ],
              if (_error != null)
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
