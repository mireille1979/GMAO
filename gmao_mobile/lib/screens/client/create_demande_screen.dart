import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/demande_provider.dart';
import '../../providers/batiment_provider.dart';
import '../../providers/equipement_provider.dart';
import '../../models/batiment.dart';
import '../../models/equipement.dart';

class CreateDemandeScreen extends StatefulWidget {
  const CreateDemandeScreen({super.key});

  @override
  State<CreateDemandeScreen> createState() => _CreateDemandeScreenState();
}

class _CreateDemandeScreenState extends State<CreateDemandeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priorite = 'MOYENNE';
  Batiment? _selectedBatiment;
  Equipement? _selectedEquipement;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BatimentProvider>(context, listen: false).fetchBatiments();
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<DemandeProvider>(context, listen: false);
      final success = await provider.createDemande(
        titre: _titreController.text,
        description: _descriptionController.text,
        priorite: _priorite,
        batimentId: _selectedBatiment?.id,
        equipementId: _selectedEquipement?.id,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande envoyée avec succès !'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Erreur lors de l\'envoi'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Demande'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.description, size: 60, color: Color(0xFF1565C0)),
              const SizedBox(height: 8),
              Text(
                'Décrivez votre besoin',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Titre
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre de la demande *',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Le titre est requis',
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description détaillée *',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) => v != null && v.isNotEmpty ? null : 'La description est requise',
              ),
              const SizedBox(height: 16),

              // Priorité
              DropdownButtonFormField<String>(
                value: _priorite,
                decoration: const InputDecoration(
                  labelText: 'Priorité',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'BASSE', child: Text('🟢 Basse')),
                  DropdownMenuItem(value: 'MOYENNE', child: Text('🟡 Moyenne')),
                  DropdownMenuItem(value: 'URGENTE', child: Text('🔴 Urgente')),
                ],
                onChanged: (val) => setState(() => _priorite = val!),
              ),
              const SizedBox(height: 16),

              // Bâtiment
              Consumer<BatimentProvider>(
                builder: (context, batProv, _) {
                  return DropdownButtonFormField<Batiment>(
                    value: _selectedBatiment,
                    decoration: const InputDecoration(
                      labelText: 'Bâtiment (optionnel)',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<Batiment>(value: null, child: Text('Aucun')),
                      ...batProv.batiments.map((b) => DropdownMenuItem(value: b, child: Text(b.nom))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedBatiment = val;
                        _selectedEquipement = null;
                      });
                      if (val != null) {
                        Provider.of<EquipementProvider>(context, listen: false)
                            .fetchEquipementsByBatiment(val.id);
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Équipement (filtered by building)
              if (_selectedBatiment != null)
                Consumer<EquipementProvider>(
                  builder: (context, eqProv, _) {
                    return DropdownButtonFormField<Equipement>(
                      value: _selectedEquipement,
                      decoration: const InputDecoration(
                        labelText: 'Équipement (optionnel)',
                        prefixIcon: Icon(Icons.precision_manufacturing),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<Equipement>(value: null, child: Text('Aucun')),
                        ...eqProv.equipements.map((e) => DropdownMenuItem(value: e, child: Text(e.nom))),
                      ],
                      onChanged: (val) => setState(() => _selectedEquipement = val),
                    );
                  },
                ),

              const SizedBox(height: 32),

              Consumer<DemandeProvider>(
                builder: (context, prov, _) {
                  return ElevatedButton.icon(
                    onPressed: prov.isLoading ? null : _submit,
                    icon: prov.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send),
                    label: const Text('ENVOYER LA DEMANDE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
