import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/absence.dart';
import '../../providers/absence_provider.dart';

class MyAbsencesScreen extends StatefulWidget {
  const MyAbsencesScreen({super.key});

  @override
  _MyAbsencesScreenState createState() => _MyAbsencesScreenState();
}

class _MyAbsencesScreenState extends State<MyAbsencesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AbsenceProvider>(context, listen: false).fetchMyAbsences());
  }

  Color _statutColor(StatutAbsence statut) {
    switch (statut) {
      case StatutAbsence.EN_ATTENTE:
        return Colors.orange;
      case StatutAbsence.APPROUVEE:
        return Colors.green;
      case StatutAbsence.REFUSEE:
        return Colors.red;
    }
  }

  void _showCreateAbsenceDialog(BuildContext context) {
    final motifController = TextEditingController();
    DateTime? dateDebut;
    DateTime? dateFin;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Demande d\'absence'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date début
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(dateDebut != null
                      ? 'Début: ${dateDebut!.toIso8601String().split('T')[0]}'
                      : 'Sélectionner la date de début'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => dateDebut = picked);
                  },
                ),
                // Date fin
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(dateFin != null
                      ? 'Fin: ${dateFin!.toIso8601String().split('T')[0]}'
                      : 'Sélectionner la date de fin'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dateDebut ?? DateTime.now(),
                      firstDate: dateDebut ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => dateFin = picked);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: motifController,
                  decoration: const InputDecoration(
                    labelText: 'Motif',
                    hintText: 'Raison de l\'absence...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (dateDebut != null && dateFin != null && motifController.text.isNotEmpty) {
                  await Provider.of<AbsenceProvider>(context, listen: false).createAbsence(
                    dateDebut!.toIso8601String().split('T')[0],
                    dateFin!.toIso8601String().split('T')[0],
                    motifController.text,
                  );
                  Navigator.of(ctx).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir tous les champs')),
                  );
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Absences'),
      ),
      body: Consumer<AbsenceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myAbsences.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune absence enregistrée', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.myAbsences.length,
            itemBuilder: (context, index) {
              final absence = provider.myAbsences[index];
              final color = _statutColor(absence.statut);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '${absence.dateDebut} → ${absence.dateFin}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color),
                            ),
                            child: Text(
                              absence.statutLabel,
                              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(absence.motif, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAbsenceDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Demander'),
      ),
    );
  }
}
