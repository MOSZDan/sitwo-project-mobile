import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final bool isRequired;
  final bool isPassword;
  final bool isEnabled;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final int? maxLength;
  final String? pattern;

  const CustomTextField({
    Key? key,
    required this.label,
    this.placeholder,
    this.isRequired = false,
    this.isPassword = false,
    this.isEnabled = true,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.controller,
    this.prefixIcon,
    this.maxLength,
    this.pattern,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${isRequired ? ' *' : ''}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151), // text-gray-700
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: isEnabled,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: placeholder,
            prefixIcon:
                prefixIcon != null
                    ? Icon(
                      prefixIcon,
                      color: const Color(0xFF22D3EE), // cyan-400
                      size: 20,
                    )
                    : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF67E8F9), // cyan-200
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF67E8F9), // cyan-200
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF22D3EE), // cyan-400
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                width: 2,
              ),
            ),
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF), // text-gray-400
            ),
            counterText: '', // Ocultar contador de caracteres
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF111827), // text-gray-900
          ),
        ),
      ],
    );
  }
}
