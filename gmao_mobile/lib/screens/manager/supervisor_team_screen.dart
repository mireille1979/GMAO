import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/absence_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class SupervisorTeamScreen extends StatefulWidget {
  const SupervisorTeamScreen({super.key});

  @override
  _SupervisorTeamScreenState createState() => _SupervisorTeamScreenState();
}

class _SupervisorTeamScreenState extends State<SupervisorTeamScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TeamProvider>(context, listen: false).fetchEquipes();
      Provider.of<AbsenceProvider>(context, listen: false).fetchAllAbsences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vue Superviseur'),
      ),
      body: Consumer2<TeamProvider, AbsenceProvider>(
        builder: (context, teamProvider, absenceProvider, child) {
          if (teamProvider.isLoading || absenceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (teamProvider.equipes.isEmpty) {
            return const Center(child: Text('Aucune équipe trouvée.'));
          }

          return ListView.builder(
            itemCount: teamProvider.equipes.length,
            itemBuilder: (context, index) {
              final equipe = teamProvider.equipes[index];
              final membres = equipe.membres ?? [];
              final disponibles = membres.where((m) => m.disponible).length;
              final indisponibles = membres.length - disponibles;

              // Count active absences for this team
              final absencesEquipe = absenceProvider.absences
                  .where((a) => a.user != null && membres.any((m) => m.id == a.user!.id))
                  .where((a) => a.statut.toString().contains('APPROUVEE') || a.statut.toString().contains('EN_ATTENTE'))
                  .toList();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      equipe.nom[0].toUpperCase(),
                      style: TextStyle(color: Colors.indigo.shade900, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(equipe.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Row(
                    children: [
                      _buildBadge('${membres.length} membres', Colors.blue),
                      const SizedBox(width: 8),
                      _buildBadge('$disponibles dispo', Colors.green),
                      if (indisponibles > 0) ...[
                        const SizedBox(width: 8),
                        _buildBadge('$indisponibles absent', Colors.red),
                      ],
                    ],
                  ),
                  children: [
                    if (equipe.chef != null)
                      ListTile(
                        leading: const Icon(Icons.star, color: Colors.amber),
                        title: Text('Chef: ${equipe.chef!.firstName} ${equipe.chef!.lastName}'),
                      ),
                    const Divider(),
                    ...membres.map((m) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: m.disponible ? Colors.green.shade50 : Colors.red.shade50,
                        child: Icon(
                          m.disponible ? Icons.person : Icons.person_off,
                          color: m.disponible ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text('${m.firstName} ${m.lastName}'),
                      subtitle: Text(m.poste?.titre ?? 'Sans poste'),
                      trailing: Text(
                        m.disponible ? 'Disponible' : 'Absent',
                        style: TextStyle(
                          color: m.disponible ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    )),
                    if (absencesEquipe.isNotEmpty) ...[
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Absences en cours/en attente (${absencesEquipe.length})',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                        ),
                      ),
                      ...absencesEquipe.map((a) => ListTile(
                        dense: true,
                        leading: Icon(
                          a.statut.toString().contains('EN_ATTENTE')
                              ? Icons.hourglass_empty
                              : Icons.check_circle,
                          color: a.statut.toString().contains('EN_ATTENTE')
                              ? Colors.orange
                              : Colors.green,
                          size: 20,
                        ),
                        title: Text(
                          '${a.user?.firstName ?? ''} ${a.user?.lastName ?? ''}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        subtitle: Text('${a.dateDebut} → ${a.dateFin} - ${a.motif}',
                            style: const TextStyle(fontSize: 12)),
                      )),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
