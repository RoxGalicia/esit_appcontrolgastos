// lib/screens/auth/password_recovery_screen.dart

import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({Key? key}) : super(key: key);

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _databaseHelper = DatabaseHelper();
  bool _isLoading = false;
  bool _isEmailVerified = false;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await _databaseHelper.getUserByEmail(
          _emailController.text.trim(),
        );

        if (user != null) {
          setState(() {
            _isEmailVerified = true;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No existe cuenta asociada a este correo electrónico'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al verificar correo: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _databaseHelper.updateUserPassword(
          _emailController.text.trim(),
          _newPasswordController.text,
        );

        if (result > 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contraseña actualizada exitosamente. Por favor inicie sesión.'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Regresar a la pantalla de login
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al actualizar contraseña'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al restablecer contraseña: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.recoverPasswordTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.lock_reset,
                  size: 70,
                  color: AppConstants.primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  _isEmailVerified
                      ? 'Ingrese su nueva contraseña'
                      : 'Ingrese su correo electrónico para recuperar su contraseña',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  label: 'Correo Electrónico',
                  hint: 'Ingrese su correo electrónico',
                  controller: _emailController,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email),
                  enabled: !_isEmailVerified,
                ),
                if (_isEmailVerified) ...[
                  CustomTextField(
                    label: 'Nueva Contraseña',
                    hint: 'Ingrese su nueva contraseña (mínimo 6 caracteres)',
                    controller: _newPasswordController,
                    validator: Validators.validatePassword,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  CustomTextField(
                    label: 'Confirmar Nueva Contraseña',
                    hint: 'Confirme su nueva contraseña',
                    controller: _confirmPasswordController,
                    validator: (value) => Validators.validatePasswordMatch(
                      _newPasswordController.text,
                      value,
                    ),
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ],
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_isEmailVerified ? _resetPassword : _verifyEmail),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_isEmailVerified
                          ? 'Cambiar Contraseña'
                          : 'Verificar Correo'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Volver al Inicio de Sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}