import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/batiment_provider.dart';
import '../../models/batiment.dart';

class EditBatimentScreen extends StatefulWidget {
  final Batiment batiment;

  const EditBatimentScreen({super.key, required this.batiment});

  @override
  State<EditBatimentScreen> createState() => _EditBatimentScreenState();
}

class _EditBatimentScreenState extends State<EditBatimentScreen> {
  late TextEditingController _nomController;
  late TextEditingController _adresseController;
  late TextEditingController _descController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.batiment.nom);
    _adresseController = TextEditingController(text: widget.batiment.adresse);
    _descController = TextEditingController(text: widget.batiment.description);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await Provider.of<BatimentProvider>(context, listen: false)
          .updateBatiment(
        widget.batiment.id,
        _nomController.text,
        _adresseController.text,
        _descController.text,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bâtiment mis à jour')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier Bâtiment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (val) => val!.isEmpty ? 'Requis' : null,
              ),
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(labelText: 'Adresse'),
                validator: (val) => val!.isEmpty ? 'Requis' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('ENREGISTRER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
