import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/batiment.dart';
import '../../models/equipement.dart';
import '../../providers/equipement_provider.dart';
import '../../providers/batiment_provider.dart';

class CreateEquipementScreen extends StatefulWidget {
  final Batiment batiment;

  const CreateEquipementScreen({super.key, required this.batiment});

  @override
  State<CreateEquipementScreen> createState() => _CreateEquipementScreenState();
}

class _CreateEquipementScreenState extends State<CreateEquipementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  TypeEquipement _selectedType = TypeEquipement.AUTRE;
  EtatEquipement _selectedEtat = EtatEquipement.FONCTIONNEL;
  int? _selectedZoneId;

  @override
  void initState() {
    super.initState();
    // Fetch zones when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BatimentProvider>(context, listen: false).fetchZones(widget.batiment.id);
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await Provider.of<EquipementProvider>(context, listen: false)
          .createEquipement(
            _nomController.text,
            _selectedType,
            _selectedEtat,
            widget.batiment.id,
            zoneId: _selectedZoneId,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Équipement ajouté avec succès')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter à ${widget.batiment.nom}'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'équipement',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Ascenseur Nord, TGBT principal...',
                ),
                validator: (value) => value!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TypeEquipement>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: TypeEquipement.values.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e.toString().split('.').last));
                }).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EtatEquipement>(
                value: _selectedEtat,
                decoration: const InputDecoration(labelText: 'État Initial', border: OutlineInputBorder()),
                 items: EtatEquipement.values.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e.toString().split('.').last));
                }).toList(),
                onChanged: (v) => setState(() => _selectedEtat = v!),
              ),
              const SizedBox(height: 16),
              Consumer<BatimentProvider>(
                  builder: (context, batimentProvider, child) {
                    final zones = batimentProvider.zones;
                    return DropdownButtonFormField<int>(
                      value: _selectedZoneId,
                      decoration: const InputDecoration(labelText: 'Zone (Optionnel)', border: OutlineInputBorder()),
                      items: [
                         const DropdownMenuItem<int>(value: null, child: Text('Aucune zone')),
                        ...zones.map((z) => DropdownMenuItem(value: z.id, child: Text('${z.nom} (${z.type})'))),
                      ],
                      onChanged: (v) => setState(() => _selectedZoneId = v),
                    );
                  },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Consumer<EquipementProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: provider.isLoading ? null : _submit,
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('AJOUTER L\'ÉQUIPEMENT'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
