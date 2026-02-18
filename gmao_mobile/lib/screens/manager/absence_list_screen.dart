import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/absence.dart';
import '../../providers/absence_provider.dart';

class AbsenceListScreen extends StatefulWidget {
  const AbsenceListScreen({super.key});

  @override
  _AbsenceListScreenState createState() => _AbsenceListScreenState();
}

class _AbsenceListScreenState extends State<AbsenceListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AbsenceProvider>(context, listen: false).fetchAllAbsences());
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

  IconData _statutIcon(StatutAbsence statut) {
    switch (statut) {
      case StatutAbsence.EN_ATTENTE:
        return Icons.hourglass_empty;
      case StatutAbsence.APPROUVEE:
        return Icons.check_circle;
      case StatutAbsence.REFUSEE:
        return Icons.cancel;
    }
  }

  void _showActions(BuildContext context, Absence absence) {
    if (absence.statut != StatutAbsence.EN_ATTENTE) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Approuver'),
              onTap: () async {
                Navigator.of(ctx).pop();
                await Provider.of<AbsenceProvider>(context, listen: false)
                    .updateStatut(absence.id!, 'APPROUVEE');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Refuser'),
              onTap: () async {
                Navigator.of(ctx).pop();
                await Provider.of<AbsenceProvider>(context, listen: false)
                    .updateStatut(absence.id!, 'REFUSEE');
              },
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
        title: const Text('Gestion des Absences'),
      ),
      body: Consumer<AbsenceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.absences.isEmpty) {
            return const Center(child: Text('Aucune demande d\'absence.'));
          }

          return ListView.builder(
            itemCount: provider.absences.length,
            itemBuilder: (context, index) {
              final absence = provider.absences[index];
              final color = _statutColor(absence.statut);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(_statutIcon(absence.statut), color: color),
                  ),
                  title: Text(
                    absence.user != null
                        ? '${absence.user!.firstName} ${absence.user!.lastName}'
                        : 'Utilisateur inconnu',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${absence.dateDebut} → ${absence.dateFin}'),
                      Text(absence.motif, style: const TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                  trailing: Container(
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
                  onTap: () => _showActions(context, absence),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
