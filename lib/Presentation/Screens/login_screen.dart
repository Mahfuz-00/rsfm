import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../Common/Widgets/custom_button.dart';
import '../../Common/Widgets/custom_text_field.dart';
import '../../Core/Dependency Injection/di.dart';
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

  bool _validate() {
    setState(() {
      _urlError = _urlController.text.trim().isEmpty ? 'Please enter URL' : null;
      _passwordError = _passwordController.text.trim().isEmpty ? 'Please enter password' : null;
    });
    return _urlError == null && _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSFM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleTheme());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(label: 'Server URL', hintText: 'http://example.com/rsfm.php', controller: _urlController, errorText: _urlError),
            const SizedBox(height: 16),
            CustomTextField(label: 'Password', hintText: '********', obscureText: true, controller: _passwordController, errorText: _passwordError),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
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
                    print('Pinging');
                    print('Current auth state: ${context.read<AuthBloc>().state.runtimeType}');
                    if (_validate()) {
                      context.read<AuthBloc>().add(AuthPing(_urlController.text.trim(), _passwordController.text));
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Proceed to Files',
              onPressed: () {
                print('Checking');
                print('Current auth state: ${context.read<AuthBloc>().state.runtimeType}');
                if (_validate() && context.read<AuthBloc>().state is AuthSuccess) {
                  print('Proceeding');
                  context.go(
                    '/files',
                    extra: {
                      'url': _urlController.text.trim(),
                      'password': _passwordController.text,
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}