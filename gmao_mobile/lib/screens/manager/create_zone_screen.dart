import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/batiment_provider.dart';

class CreateZoneScreen extends StatefulWidget {
  final int batimentId;

  const CreateZoneScreen({super.key, required this.batimentId});

  @override
  State<CreateZoneScreen> createState() => _CreateZoneScreenState();
}

class _CreateZoneScreenState extends State<CreateZoneScreen> {
  final _nomController = TextEditingController();
  String _selectedType = 'ETAGE';
  final _formKey = GlobalKey<FormState>();

  final List<String> _types = ['ETAGE', 'SALLE', 'COULOIR', 'AUTRE'];

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await Provider.of<BatimentProvider>(context, listen: false)
          .createZone(widget.batimentId, _nomController.text, _selectedType);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zone ajoutée')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Zone')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom de la zone'),
                validator: (val) => val!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: _types.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('AJOUTER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
