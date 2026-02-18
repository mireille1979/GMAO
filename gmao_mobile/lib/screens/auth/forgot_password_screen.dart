import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Added FormKey

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) { // Validate
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final success = await auth.forgotPassword(_emailController.text);

        if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email envoyé (Simulé: Voir console backend)')),
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
        );
        } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur: Email introuvable ou problème serveur')),
        );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form( // Wrapped in Form
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                const Icon(Icons.lock_reset, size: 80, color: Color(0xFF1565C0)),
                const SizedBox(height: 24),
                const Text(
                    'Entrez votre email pour recevoir un lien de réinitialisation.',
                    textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value != null && value.contains('@') ? null : 'Email invalide', // Validator
                ),
                const SizedBox(height: 32),
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                        return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                        ),
                        onPressed: auth.isLoading ? null : _submit,
                        child: auth.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('ENVOYER'),
                        );
                    },
                    ),
                ),
                ],
            ),
          ),
        ),
      ),
    );
  }
}
