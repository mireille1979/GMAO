import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/batiment_provider.dart';
import 'create_batiment_screen.dart';
import 'edit_batiment_screen.dart';
import 'equipement_list_screen.dart';
import 'zone_list_screen.dart';

class BatimentListScreen extends StatefulWidget {
  const BatimentListScreen({super.key});

  @override
  State<BatimentListScreen> createState() => _BatimentListScreenState();
}

class _BatimentListScreenState extends State<BatimentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BatimentProvider>(context, listen: false).fetchBatiments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Bâtiments'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Consumer<BatimentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (provider.batiments.isEmpty) {
            return const Center(child: Text('Aucun bâtiment enregistré.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.batiments.length,
            itemBuilder: (context, index) {
              final batiment = provider.batiments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.apartment, color: Colors.white),
                  ),
                  title: Text(batiment.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(batiment.adresse),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       IconButton(
                        icon: const Icon(Icons.settings_input_component, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EquipementListScreen(batiment: batiment),
                            ),
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditBatimentScreen(batiment: batiment),
                              ),
                            ).then((_) => provider.fetchBatiments());
                          } else if (value == 'zones') {
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ZoneListScreen(batiment: batiment),
                              ),
                            );
                          } else if (value == 'delete') {
                             final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Supprimer le bâtiment ?'),
                                content: const Text('Cela supprimera aussi toutes les zones et équipements associés.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await provider.deleteBatiment(batiment.id);
                            }
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'zones',
                            child: ListTile(
                              leading: Icon(Icons.meeting_room),
                              title: Text('Gérer les zones'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Modifier'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateBatimentScreen()),
          ).then((_) {
            // Refresh list upon return
            Provider.of<BatimentProvider>(context, listen: false).fetchBatiments();
          });
        },
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
