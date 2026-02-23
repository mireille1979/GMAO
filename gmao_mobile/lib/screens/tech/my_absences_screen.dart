import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/absence.dart';
import '../../providers/absence_provider.dart';
import '../../utils/theme.dart';

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

  String _statutLabel(StatutAbsence statut) {
    switch (statut) {
      case StatutAbsence.EN_ATTENTE: return 'En attente';
      case StatutAbsence.APPROUVEE: return 'Approuvée';
      case StatutAbsence.REFUSEE: return 'Refusée';
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Nouvelle demande', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDatePicker(
                  context, 
                  label: 'Date de début', 
                  selectedDate: dateDebut, 
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(primary: AppTheme.primaryOrange),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) setState(() => dateDebut = picked);
                  }
                ),
                const SizedBox(height: 16),
                _buildDatePicker(
                  context, 
                  label: 'Date de fin', 
                  selectedDate: dateFin, 
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dateDebut ?? DateTime.now(),
                      firstDate: dateDebut ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(primary: AppTheme.primaryOrange),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) setState(() => dateFin = picked);
                  }
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: motifController,
                  decoration: InputDecoration(
                    labelText: 'Motif',
                    hintText: 'Raison de l\'absence...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler', style: TextStyle(color: AppTheme.textGrey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
                    const SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.orange),
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

  Widget _buildDatePicker(BuildContext context, {required String label, required DateTime? selectedDate, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                const SizedBox(height: 4),
                Text(
                  selectedDate != null ? selectedDate.toIso8601String().split('T')[0] : 'Sélectionner',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Icon(Icons.calendar_today, color: AppTheme.primaryOrange),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Mes Absences', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.textDark),
      ),
      body: Consumer<AbsenceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
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

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: provider.myAbsences.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final absence = provider.myAbsences[index];
              final color = _statutColor(absence.statut);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryOrange),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${absence.dateDebut} → ${absence.dateFin}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statutLabel(absence.statut),
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                       const Text("Motif :", style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                      const SizedBox(height: 4),
                      Text(
                        absence.motif, 
                        style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryOrange,
        onPressed: () => _showCreateAbsenceDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle demande'),
      ),
    );
  }
}
