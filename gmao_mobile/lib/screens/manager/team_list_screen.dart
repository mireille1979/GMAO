import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../models/equipe.dart';
import 'team_details_screen.dart';

class TeamListScreen extends StatefulWidget {
  const TeamListScreen({super.key});

  @override
  _TeamListScreenState createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TeamProvider>(context, listen: false).fetchEquipes());
  }

  void _showAddTeamDialog(BuildContext context) {
    final nomController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle Équipe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              decoration: const InputDecoration(labelText: 'Nom de l\'équipe'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nomController.text.isNotEmpty) {
                await Provider.of<TeamProvider>(context, listen: false)
                    .createEquipe(nomController.text, descController.text);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Équipes'),
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.equipes.isEmpty) {
            return const Center(child: Text('Aucune équipe trouvée.'));
          }

          return ListView.builder(
            itemCount: provider.equipes.length,
            itemBuilder: (context, index) {
              final equipe = provider.equipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(equipe.nom[0].toUpperCase()),
                  ),
                  title: Text(equipe.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(equipe.description ?? 'Pas de description'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Confirm delete
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirmer'),
                          content: const Text('Voulez-vous vraiment supprimer cette équipe ?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Non')),
                            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Oui')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await provider.deleteEquipe(equipe.id);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TeamDetailsScreen(equipe: equipe),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTeamDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
