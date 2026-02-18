import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../models/poste.dart';
import '../../core/api_client.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _specialiteController = TextEditingController();
  Role _selectedRole = Role.TECH;
  List<Poste> _postes = [];
  Poste? _selectedPoste;

  @override
  void initState() {
    super.initState();
    _fetchPostes();
  }

  Future<void> _fetchPostes() async {
    try {
      final response = await ApiClient().dio.get('/postes');
      if (response.statusCode == 200) {
        setState(() {
          _postes = (response.data as List).map((e) => Poste.fromJson(e)).toList();
        });
      }
    } catch (e) {
      print('Error fetching postes: $e');
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
        posteId: _selectedPoste?.id,
        telephone: _telephoneController.text.isNotEmpty ? _telephoneController.text : null,
        specialite: _specialiteController.text.isNotEmpty ? _specialiteController.text : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé avec succès ! Connectez-vous.')),
        );
        Navigator.pop(context); // Go back to login
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de l\'inscription')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, size: 80, color: Color(0xFF1565C0)),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value != null && value.isNotEmpty ? null : 'Requis',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value != null && value.isNotEmpty ? null : 'Requis',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value != null && value.contains('@') ? null : 'Email invalide',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value != null && value.length >= 4 ? null : 'Trop court',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telephoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Role>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                    prefixIcon: Icon(Icons.work),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: Role.TECH, child: Text('Technicien')),
                    DropdownMenuItem(value: Role.CLIENT, child: Text('Client')),
                  ],
                  onChanged: (Role? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                ),
                if (_selectedRole == Role.TECH) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Poste>(
                    value: _selectedPoste,
                    decoration: const InputDecoration(
                      labelText: 'Poste (Fonction)',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<Poste>(value: null, child: Text('Aucun')),
                      ..._postes.map((p) => DropdownMenuItem(value: p, child: Text(p.titre))),
                    ],
                    onChanged: (val) => setState(() => _selectedPoste = val),
                    validator: (val) => val == null ? 'Veuillez choisir un poste' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _specialiteController,
                    decoration: const InputDecoration(
                      labelText: 'Spécialité',
                      prefixIcon: Icon(Icons.build),
                      border: OutlineInputBorder(),
                      hintText: 'Ex: Électricité, Plomberie, CVC...',
                    ),
                  ),
                ],
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
                            : const Text('S\'INSCRIRE'),
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
