import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';

class PosteListScreen extends StatefulWidget {
  const PosteListScreen({super.key});

  @override
  _PosteListScreenState createState() => _PosteListScreenState();
}

class _PosteListScreenState extends State<PosteListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TeamProvider>(context, listen: false).fetchPostes());
  }

  void _showPosteDialog(BuildContext context, {int? id, String? currentTitre, String? currentDesc}) {
    final titleController = TextEditingController(text: currentTitre ?? '');
    final descController = TextEditingController(text: currentDesc ?? '');
    final isEditing = id != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Modifier le Poste' : 'Nouveau Poste'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Titre du poste'),
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
              if (titleController.text.isNotEmpty) {
                final provider = Provider.of<TeamProvider>(context, listen: false);
                if (isEditing) {
                  await provider.updatePoste(id, titleController.text, descController.text);
                } else {
                  await provider.createPoste(titleController.text, descController.text);
                }
                Navigator.of(ctx).pop();
              }
            },
            child: Text(isEditing ? 'Enregistrer' : 'Créer'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, String titre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le poste "$titre" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await Provider.of<TeamProvider>(context, listen: false).deletePoste(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Postes'),
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.postes.isEmpty) {
            return const Center(child: Text('Aucun poste trouvé.'));
          }

          return ListView.builder(
            itemCount: provider.postes.length,
            itemBuilder: (context, index) {
              final poste = provider.postes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.work)),
                  title: Text(poste.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(poste.description ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showPosteDialog(
                          context,
                          id: poste.id,
                          currentTitre: poste.titre,
                          currentDesc: poste.description,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, poste.id, poste.titre),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPosteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
