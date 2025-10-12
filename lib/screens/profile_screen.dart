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

  // --- Campos EDITABLES ---
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();

  // --- Campos de SOLO LECTURA (para mostrar) ---
  String _nombre = '';
  String _apellido = '';
  String _sexo = '';
  String _codigo = '';

  // --- Datos del perfil específico (solo lectura) ---
  Map<String, dynamic>? _perfilData;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userRole = await _httpService.getUserRole();
      // Usar el endpoint correcto /api/usuario/me
      final userData = await _httpService.get('/api/usuario/me');

      setState(() {
        _userRole = userRole;

        // Cargar datos editables
        _emailController.text = userData['correoelectronico'] ?? '';
        _telefonoController.text = userData['telefono'] ?? '';

        // Cargar datos de solo lectura
        _nombre = userData['nombre'] ?? '';
        _apellido = userData['apellido'] ?? '';
        _sexo = userData['sexo'] ?? '';
        _codigo = userData['codigo']?.toString() ?? '';
        _perfilData = userData['perfil'];
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el perfil: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Solo enviar los campos editables: correoelectronico y telefono
      final Map<String, dynamic> updatedData = {
        'correoelectronico': _emailController.text.trim().toLowerCase(),
        'telefono': _telefonoController.text.trim(),
      };

      // Enviar PATCH al endpoint correcto
      await _httpService.patch('/api/usuario/me', updatedData);

      if (mounted) {
        _showMessage('Perfil actualizado con éxito', true);
        // Recargar para mostrar cambios
        await _loadUserProfile();
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error al guardar: ${e.toString()}', false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading && _emailController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- AVATAR ---
                          _buildAvatar(),
                          const SizedBox(height: 24),

                          // --- CAMPOS DE SOLO LECTURA ---
                          _buildSectionTitle('Información Personal (Solo lectura)'),
                          _buildReadOnlyField('Nombre', _nombre),
                          const SizedBox(height: 12),
                          _buildReadOnlyField('Apellido', _apellido),
                          const SizedBox(height: 12),
                          _buildReadOnlyField('Sexo', _sexo),
                          const SizedBox(height: 12),
                          _buildReadOnlyField(
                              'Código de Usuario', _codigo),

                          const SizedBox(height: 32),

                          // --- CAMPOS EDITABLES ---
                          _buildSectionTitle('Datos Editables'),
                          const Text(
                            'Solo puedes editar tu correo electrónico y número de teléfono',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          _buildEditableEmailField(),
                          const SizedBox(height: 16),
                          _buildEditableTelefonoField(),

                          // --- PERFIL ESPECÍFICO DEL ROL (SOLO LECTURA) ---
                          if (_perfilData != null) ...[
                            const SizedBox(height: 32),
                            _buildSectionTitle('Datos del Perfil (Solo lectura)'),
                            ..._buildPerfilFields(),
                          ],

                          const SizedBox(height: 32),

                          // --- BOTÓN GUARDAR ---
                          ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ))
                                : const Text(
                                    'Guardar Cambios',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  // --- AVATAR ---
  Widget _buildAvatar() {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.teal.shade100,
        child: Text(
          _nombre.isNotEmpty ? _nombre[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ),
    );
  }

  // --- CAMPO EDITABLE: EMAIL ---
  Widget _buildEditableEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Correo Electrónico *',
        prefixIcon: const Icon(Icons.email, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El correo electrónico es requerido';
        }
        // Validación simple de email
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Ingresa un correo electrónico válido';
        }
        return null;
      },
    );
  }

  // --- CAMPO EDITABLE: TELÉFONO ---
  Widget _buildEditableTelefonoField() {
    return TextFormField(
      controller: _telefonoController,
      keyboardType: TextInputType.phone,
      maxLength: 8,
      decoration: InputDecoration(
        labelText: 'Teléfono *',
        prefixIcon: const Icon(Icons.phone, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        helperText: 'Debe tener exactamente 8 dígitos',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El teléfono es requerido';
        }
        // Validar que sean exactamente 8 dígitos
        if (value.trim().length != 8) {
          return 'El teléfono debe tener exactamente 8 dígitos';
        }
        // Validar que solo sean números
        if (!RegExp(r'^\d{8}$').hasMatch(value.trim())) {
          return 'El teléfono debe contener solo números';
        }
        return null;
      },
    );
  }

  // --- CAMPO DE SOLO LECTURA ---
  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'No especificado' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  // --- PERFIL ESPECÍFICO DEL ROL ---
  List<Widget> _buildPerfilFields() {
    if (_perfilData == null) return [];

    List<Widget> fields = [];

    if (_userRole == 'paciente') {
      fields.addAll([
        _buildReadOnlyField(
            'Dirección', _perfilData!['direccion'] ?? 'No especificado'),
        const SizedBox(height: 12),
        _buildReadOnlyField('Fecha de Nacimiento',
            _perfilData!['fechanacimiento'] ?? 'No especificado'),
        const SizedBox(height: 12),
        _buildReadOnlyField('Carnet de Identidad',
            _perfilData!['carnetidentidad'] ?? 'No especificado'),
      ]);
    } else if (_userRole == 'odontologo') {
      fields.addAll([
        _buildReadOnlyField(
            'Especialidad', _perfilData!['especialidad'] ?? 'No especificado'),
        const SizedBox(height: 12),
        _buildReadOnlyField('Experiencia Profesional',
            _perfilData!['experienciaProfesional'] ?? 'No especificado'),
        const SizedBox(height: 12),
        _buildReadOnlyField('N° de Matrícula',
            _perfilData!['noMatricula'] ?? 'No especificado'),
      ]);
    } else if (_userRole == 'recepcionista') {
      fields.addAll([
        _buildReadOnlyField('Habilidades de Software',
            _perfilData!['habilidadesSoftware'] ?? 'No especificado'),
      ]);
    }

    return fields;
  }

  // --- TÍTULO DE SECCIÓN ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
      ),
    );
  }

  // --- MENSAJE ---
  void _showMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
