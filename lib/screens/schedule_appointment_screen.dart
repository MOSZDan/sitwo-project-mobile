// lib/screens/schedule_appointment_screen.dart
import 'package:flutter/material.dart';
import '../services/http_service.dart';
import '../models/odontologo.dart';
import '../models/horario.dart';
import '../models/consulta.dart'; // Importar el modelo Consulta

class ScheduleAppointmentScreen extends StatefulWidget {
  final Consulta? appointmentToReschedule;

  const ScheduleAppointmentScreen({super.key, this.appointmentToReschedule});

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _httpService = HttpService();
  bool _isLoading = false;
  bool _isDataLoading = true;
  bool get _isRescheduling => widget.appointmentToReschedule != null;

  List<Odontologo> _odontologos = [];
  List<Odontologo> _odontologosFiltrados = [];
  List<String> _especialidades = [];
  List<Horario> _horarios = [];

  String? _selectedEspecialidad;
  Odontologo? _selectedOdontologo;
  Horario? _selectedHorario;
  DateTime? _selectedDate;

  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final result = await _httpService.get('/api/odontologos/');

      if (mounted) {
        setState(() {
          _odontologos = (result['results'] as List)
              .map((json) => Odontologo.fromJson(json))
              .toList();

          // Extraer especialidades únicas de los odontólogos
          _especialidades = _odontologos
              .map((odontologo) => odontologo.especialidad)
              .toSet()
              .toList()
            ..sort();

          if (_isRescheduling) {
            _prefillFormForReschedule();
          }
        });
      }
    } catch (e) {
      if (mounted) _showMessage('Error al cargar datos: ${e.toString()}', true);
    } finally {
      if (mounted) setState(() => _isDataLoading = false);
    }
  }

  void _prefillFormForReschedule() {
    final a = widget.appointmentToReschedule!;
    _selectedDate = DateTime.parse(a.fecha);
    _dateController.text = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";

    _selectedOdontologo = _odontologos.firstWhere(
        (o) => o.codUsuario == a.odontologo.codUsuario,
        orElse: () => _odontologos.first);

    // Pre-seleccionar la especialidad del odontólogo
    if (_selectedOdontologo != null) {
      _selectedEspecialidad = _selectedOdontologo!.especialidad;
      _filterOdontologosByEspecialidad();
    }

    _fetchAvailableHorarios();
  }

  void _filterOdontologosByEspecialidad() {
    if (_selectedEspecialidad == null) {
      _odontologosFiltrados = [];
      return;
    }

    _odontologosFiltrados = _odontologos
        .where((odontologo) => odontologo.especialidad == _selectedEspecialidad)
        .toList();
  }

  Future<void> _fetchAvailableHorarios() async {
    if (_selectedOdontologo == null || _selectedDate == null) return;

    setState(() {
      _isLoading = true;
      _horarios = [];
      _selectedHorario = null;
    });

    try {
      final fecha =
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

      String apiUrl =
          '/api/horarios/disponibles/?odontologo_id=${_selectedOdontologo!.codUsuario}&fecha=$fecha';

      final response = await _httpService.get(apiUrl);

      final List<dynamic> horariosList =
          response is List ? response : (response['results'] ?? response);

      if (mounted) {
        setState(() {
          _horarios =
              horariosList.map((json) => Horario.fromJson(json)).toList();
        });

        // Mostrar mensaje si no hay horarios disponibles
        if (_horarios.isEmpty) {
          _showMessage(
              'No hay horarios disponibles para esta fecha y odontólogo.',
              true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error al cargar horarios: ${e.toString()}', true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) {
      _showMessage('Por favor, completa todos los campos.', true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final patientId = await _httpService.getPatientId();
      if (patientId == null) {
        throw Exception('No se encontró el ID del paciente.');
      }

      // Obtener el primer tipo de consulta disponible (tipo de consulta por defecto)
      final tiposConsultaResponse = await _httpService.get('/api/tipos-consulta/');
      final tiposConsulta = tiposConsultaResponse['results'] as List;

      if (tiposConsulta.isEmpty) {
        throw Exception('No hay tipos de consulta configurados. Contacta al administrador.');
      }

      final tipoConsultaId = tiposConsulta[0]['id'];

      final requestData = {
        'fecha':
            "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
        'codpaciente': patientId,
        'cododontologo': _selectedOdontologo!.codUsuario,
        'idhorario': _selectedHorario!.id,
        'idtipoconsulta': tipoConsultaId, // Usar el primer tipo de consulta disponible
        'idestadoconsulta': 1, // 'Agendada'
      };

      if (_isRescheduling) {
        await _httpService.put(
            '/api/consultas/${widget.appointmentToReschedule!.id}/',
            requestData);
        if (mounted) {
          _showMessage('¡Cita reprogramada con éxito!', false);
          Navigator.of(context).pop(true);
        }
      } else {
        await _httpService.post('/api/consultas/', requestData);
        if (mounted) {
          _showMessage('¡Cita agendada con éxito!', false);
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error al procesar la cita: ${e.toString()}', true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              _isRescheduling ? 'Reprogramar Cita' : 'Agendar Nueva Cita')),
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. ESPECIALIDAD
                    _buildEspecialidadDropdown(),
                    const SizedBox(height: 20),

                    // 2. ODONTÓLOGO (filtrado por especialidad)
                    _buildDropdown<Odontologo>(
                      label: 'Odontólogo',
                      value: _selectedOdontologo,
                      items: _odontologosFiltrados,
                      onChanged: (value) {
                        setState(() {
                          _selectedOdontologo = value;
                          _horarios = [];
                          _selectedHorario = null;
                        });
                        _fetchAvailableHorarios();
                      },
                      itemAsString: (odontologo) =>
                          '${odontologo.nombreCompleto} - ${odontologo.especialidad}',
                      enabled: _selectedEspecialidad != null,
                    ),
                    const SizedBox(height: 20),

                    // 3. FECHA
                    _buildDatePicker(),
                    const SizedBox(height: 20),

                    // 4. HORARIO (solo se carga después de seleccionar odontólogo y fecha)
                    _buildDropdown<Horario>(
                      label: 'Horario',
                      value: _selectedHorario,
                      items: _horarios,
                      onChanged: (value) => setState(() => _selectedHorario = value),
                      itemAsString: (horario) => horario.hora,
                      enabled: _selectedOdontologo != null &&
                          _selectedDate != null &&
                          !_isLoading,
                    ),
                    if (_selectedOdontologo != null &&
                        _selectedDate != null &&
                        _horarios.isEmpty &&
                        !_isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'No hay horarios disponibles para esta fecha.',
                          style: TextStyle(color: Colors.red[700], fontSize: 14),
                        ),
                      ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitAppointment,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(_isRescheduling
                              ? 'Confirmar Reprogramación'
                              : 'Confirmar Cita'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) itemAsString,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: Colors.grey[200],
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(itemAsString(item)));
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (val) => val == null ? 'Este campo es requerido' : null,
    );
  }

  Widget _buildEspecialidadDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedEspecialidad,
      decoration: InputDecoration(
        labelText: 'Especialidad',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.medical_services, color: Colors.teal),
        filled: false,
      ),
      items: _especialidades.map((especialidad) {
        return DropdownMenuItem<String>(
          value: especialidad,
          child: Text(especialidad),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedEspecialidad = value;
          _selectedOdontologo =
              null; // Reset odontólogo cuando cambia especialidad
          _horarios = [];
          _selectedHorario = null;
        });
        _filterOdontologosByEspecialidad();
      },
      validator: (val) =>
          val == null ? 'Primero selecciona una especialidad' : null,
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Fecha de la Cita',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            _dateController.text =
                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          });
          _fetchAvailableHorarios();
        }
      },
      validator: (value) =>
          _selectedDate == null ? 'Selecciona una fecha' : null,
    );
  }
}