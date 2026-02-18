import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Added FormKey

  Future<void> _submit() async {
     if (_formKey.currentState!.validate()) { // Validate
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final success = await auth.resetPassword(
        _tokenController.text,
        _passwordController.text,
        );

        if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mot de passe réinitialisé ! Connectez-vous.')),
        );
        Navigator.popUntil(context, (route) => route.isFirst); // Back to Login
        } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur: Token invalide ou expiré')),
        );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Réinitialisation')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form( // Wrapped in Form
            key: _formKey,
             child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                const Icon(Icons.password, size: 80, color: Color(0xFF1565C0)),
                const SizedBox(height: 24),
                const Text(
                    'Entrez le token reçu (simulé dans console) et votre nouveau mot de passe.',
                    textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                    controller: _tokenController,
                    decoration: const InputDecoration(
                    labelText: 'Token',
                    prefixIcon: Icon(Icons.vpn_key),
                    border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value != null && value.isNotEmpty ? null : 'Requis', // Validator
                ),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) =>
                        value != null && value.length >= 4 ? null : 'Trop court', // Validator
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
                            : const Text('CONFIRMER'),
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
