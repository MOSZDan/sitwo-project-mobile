// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/http_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _httpService = HttpService();
  bool _isLoading = true;
  String _errorMessage = '';
  String? _userRole;

  // --- Controladores para TODOS los campos posibles ---
  // Comunes
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();

  // Paciente
  final _direccionController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _carnetController = TextEditingController();

  // Odontólogo
  final _especialidadController = TextEditingController();
  final _experienciaController = TextEditingController();
  final _matriculaController = TextEditingController();

  // Recepcionista
  final _habilidadesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final userRole = await _httpService.getUserRole();
      final userData = await _httpService.get('/api/auth/user/');

      setState(() {
        _userRole = userRole;

        // Cargar datos comunes
        _nombreController.text = userData['nombre'] ?? '';
        _apellidoController.text = userData['apellido'] ?? '';
        _telefonoController.text = userData['telefono'] ?? '';

        final perfilData = userData['perfil'];
        if (perfilData == null) return;

        // Cargar datos específicos del rol desde el objeto 'perfil'
        if (_userRole == 'paciente') {
          _direccionController.text = perfilData['direccion'] ?? '';
          _fechaNacimientoController.text = perfilData['fechanacimiento'] ?? '';
          _carnetController.text = perfilData['carnetidentidad'] ?? '';
        } else if (_userRole == 'odontologo') {
          _especialidadController.text = perfilData['especialidad'] ?? '';
          _experienciaController.text = perfilData['experienciaProfesional'] ?? '';
          _matriculaController.text = perfilData['noMatricula'] ?? '';
        } else if (_userRole == 'recepcionista') {
          _habilidadesController.text = perfilData['habilidadesSoftware'] ?? '';
        }
      });
    } catch (e) {
      setState(() { _errorMessage = 'Error al cargar el perfil: ${e.toString()}'; });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Prepara los datos comunes
      final Map<String, dynamic> updatedData = {
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'telefono': _telefonoController.text,
      };

      // 2. Añade los datos específicos del rol al mismo mapa
      if (_userRole == 'paciente') {
        updatedData['direccion'] = _direccionController.text;
        updatedData['fechanacimiento'] = _fechaNacimientoController.text;
        updatedData['carnetidentidad'] = _carnetController.text;
      } else if (_userRole == 'odontologo') {
        updatedData['especialidad'] = _especialidadController.text;
        updatedData['experienciaProfesional'] = _experienciaController.text;
        updatedData['noMatricula'] = _matriculaController.text;
      } else if (_userRole == 'recepcionista') {
        updatedData['habilidadesSoftware'] = _habilidadesController.text;
      }

      // 3. Envía todo en una sola petición PATCH
      await _httpService.patch('/api/auth/user/', updatedData);

      if (mounted) {
        _showMessage('Perfil actualizado con éxito', true);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) { _showMessage('Error al guardar: ${e.toString()}', false); }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: _isLoading && _nombreController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
          : RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- CAMPOS COMUNES PARA TODOS ---
                _buildSectionTitle('Información General'),
                _buildTextField(_nombreController, 'Nombre'),
                const SizedBox(height: 16),
                _buildTextField(_apellidoController, 'Apellido'),
                const SizedBox(height: 16),
                _buildTextField(_telefonoController, 'Teléfono', keyboardType: TextInputType.phone),

                // --- CAMPOS ESPECÍFICOS DEL ROL ---
                if (_userRole == 'paciente') ..._buildPacienteFields(),
                if (_userRole == 'odontologo') ..._buildOdontologoFields(),
                if (_userRole == 'recepcionista') ..._buildRecepcionistaFields(),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Guardar Cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Métodos para construir los campos de cada rol ---
  List<Widget> _buildPacienteFields() {
    return [
      const SizedBox(height: 24),
      _buildSectionTitle('Datos del Paciente'),
      _buildTextField(_direccionController, 'Dirección'),
      const SizedBox(height: 16),
      _buildTextField(_fechaNacimientoController, 'Fecha de Nacimiento (YYYY-MM-DD)'),
      const SizedBox(height: 16),
      _buildTextField(_carnetController, 'Carnet de Identidad'),
    ];
  }

  List<Widget> _buildOdontologoFields() {
    return [
      const SizedBox(height: 24),
      _buildSectionTitle('Perfil Profesional'),
      _buildTextField(_especialidadController, 'Especialidad'),
      const SizedBox(height: 16),
      _buildTextField(_experienciaController, 'Experiencia Profesional'),
      const SizedBox(height: 16),
      _buildTextField(_matriculaController, 'N° de Matrícula'),
    ];
  }

  List<Widget> _buildRecepcionistaFields() {
    return [
      const SizedBox(height: 24),
      _buildSectionTitle('Perfil Profesional'),
      _buildTextField(_habilidadesController, 'Habilidades de Software'),
    ];
  }

  // --- Widgets reusables ---
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) { return 'Este campo es requerido'; }
        return null;
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }
}