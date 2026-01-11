// lib/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../Common/Widgets/custom_button.dart';
import '../../Common/Widgets/custom_text_field.dart';
import '../../Core/Dependency Injection/di.dart';
import '../../Core/Storage/credential_storage.dart';
import '../Bloc/auth/auth_bloc.dart';
import '../Bloc/files/files_bloc.dart';
import '../Bloc/theme/theme_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _urlController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _urlError;
  String? _passwordError;
  bool _isLoadingCredentials = true;
  bool _isPingingForProceed = false; // New: track auto-ping from Proceed

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final creds = await CredentialStorage.load();
    if (creds != null) {
      _urlController.text = creds['url']!;
      _passwordController.text = creds['password']!;
    }
    setState(() => _isLoadingCredentials = false);
  }

  bool _validate() {
    setState(() {
      _urlError = _urlController.text.trim().isEmpty ? 'Please enter URL' : null;
      _passwordError = _passwordController.text.trim().isEmpty ? 'Please enter password' : null;
    });
    return _urlError == null && _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCredentials) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('RSFM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => context.read<ThemeBloc>().add(ToggleTheme()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              label: 'Server URL',
              hintText: 'http://example.com/rsfm.php',
              controller: _urlController,
              errorText: _urlError,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              hintText: '********',
              obscureText: true,
              controller: _passwordController,
              errorText: _passwordError,
            ),
            const SizedBox(height: 24),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  CredentialStorage.save(
                    _urlController.text.trim(),
                    _passwordController.text,
                  );
                }
              },
              builder: (context, state) {
                bool loading = state is AuthLoading;
                Color? color;
                String text = 'Ping Test';
                if (state is AuthSuccess) { color = Colors.green; text = 'Passed'; }
                if (state is AuthFailure) { color = Colors.red; text = 'Failed'; }
                return CustomButton(
                  text: text,
                  isLoading: loading,
                  color: color,
                  onPressed: () {
                    if (_validate()) {
                      context.read<AuthBloc>().add(
                        AuthPing(_urlController.text.trim(), _passwordController.text),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess && _isPingingForProceed) {
                  // Auto-proceed after auto-ping from Proceed button
                  _isPingingForProceed = false;
                  context.go('/files', extra: {
                    'url': _urlController.text.trim(),
                    'password': _passwordController.text,
                  });
                }
              },
              builder: (context, state) {
                final isPinging = _isPingingForProceed && state is AuthLoading;

                return CustomButton(
                  text: isPinging ? 'Pinging server...' : 'Proceed to Files',
                  isLoading: false, // ← No spinner!
                  color: state is AuthSuccess ? Colors.green : null,
                  onPressed: isPinging
                      ? null
                      : () {
                    if (!_validate()) return;

                    if (state is AuthSuccess) {
                      context.go('/files', extra: {
                        'url': _urlController.text.trim(),
                        'password': _passwordController.text,
                      });
                    } else {
                      // Start auto-ping
                      setState(() => _isPingingForProceed = true);
                      context.read<AuthBloc>().add(
                        AuthPing(_urlController.text.trim(), _passwordController.text),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}