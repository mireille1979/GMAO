import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/batiment.dart';
import '../../models/equipement.dart';
import '../../models/zone.dart';
import '../../providers/equipement_provider.dart';
import '../../providers/batiment_provider.dart';

class EditEquipementScreen extends StatefulWidget {
  final Equipement equipement;
  final Batiment batiment;

  const EditEquipementScreen({super.key, required this.equipement, required this.batiment});

  @override
  State<EditEquipementScreen> createState() => _EditEquipementScreenState();
}

class _EditEquipementScreenState extends State<EditEquipementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TypeEquipement _selectedType;
  late EtatEquipement _selectedEtat;
  int? _selectedZoneId;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.equipement.nom);
    _selectedType = widget.equipement.type;
    _selectedEtat = widget.equipement.etat;
    _selectedZoneId = widget.equipement.zoneId;

    // Fetch zones for the building to populate dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BatimentProvider>(context, listen: false).fetchZones(widget.batiment.id);
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await Provider.of<EquipementProvider>(context, listen: false)
          .updateEquipement(
            widget.equipement.id,
            _nomController.text,
            _selectedType,
            _selectedEtat,
            widget.batiment.id,
            zoneId: _selectedZoneId,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Équipement modifié avec succès')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la modification')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier Équipement'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'équipement',
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(labelText: 'État', border: OutlineInputBorder()),
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
                      value: _selectedZoneId != null && zones.any((z) => z.id == _selectedZoneId) ? _selectedZoneId : null,
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
                            : const Text('ENREGISTRER LES MODIFICATIONS'),
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
