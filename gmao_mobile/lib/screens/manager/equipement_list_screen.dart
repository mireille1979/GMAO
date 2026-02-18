import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/batiment.dart';
import '../../providers/equipement_provider.dart';
import 'create_equipement_screen.dart';
import 'equipement_details_screen.dart';
import 'edit_equipement_screen.dart';

class EquipementListScreen extends StatefulWidget {
  final Batiment? batiment;

  const EquipementListScreen({super.key, this.batiment});

  @override
  State<EquipementListScreen> createState() => _EquipementListScreenState();
}

class _EquipementListScreenState extends State<EquipementListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.batiment != null) {
        Provider.of<EquipementProvider>(context, listen: false)
            .fetchEquipementsByBatiment(widget.batiment!.id);
      } else {
        Provider.of<EquipementProvider>(context, listen: false)
            .fetchAllEquipements();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGlobal = widget.batiment == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isGlobal ? 'Tous les Équipements' : 'Équipements - ${widget.batiment!.nom}'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Consumer<EquipementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.equipements.isEmpty) {
            return Center(child: Text(isGlobal ? 'Aucun équipement enregistré.' : 'Aucun équipement lié à ce bâtiment.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.equipements.length,
            itemBuilder: (context, index) {
              final equip = provider.equipements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Icon(_getIconForType(equip.type), color: Colors.white),
                  ),
                  title: Text(equip.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    isGlobal 
                    ? '${equip.batiment?.nom ?? "N/A"} - ${equip.type.toString().split('.').last}'
                    : 'Type: ${equip.type.toString().split('.').last} - État: ${equip.etat.toString().split('.').last}'
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit' && widget.batiment != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditEquipementScreen(equipement: equip, batiment: widget.batiment!)),
                        ).then((_) {
                           Provider.of<EquipementProvider>(context, listen: false)
                            .fetchEquipementsByBatiment(widget.batiment!.id);
                        });
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmer'),
                            content: const Text('Voulez-vous vraiment supprimer cet équipement ?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await Provider.of<EquipementProvider>(context, listen: false).deleteEquipement(equip.id);
                        }
                      }
                    },
                    itemBuilder: (context) {
                      final List<PopupMenuEntry<String>> items = [];
                      if (!isGlobal && widget.batiment != null) {
                         items.add(const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text('Modifier')])));
                      }
                      items.add(const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Supprimer')])));
                      return items;
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EquipementDetailsScreen(equipement: equip),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isGlobal ? null : FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateEquipementScreen(batiment: widget.batiment!),
            ),
          ).then((_) {
             Provider.of<EquipementProvider>(context, listen: false)
                .fetchEquipementsByBatiment(widget.batiment!.id);
          });
        },
        label: const Text('Ajouter Équipement'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
    );
  }

  IconData _getIconForType(dynamic type) {
    // Basic mapping, assuming enum names match
    if (type.toString().contains('ELECTRIQUE')) return Icons.electric_bolt;
    if (type.toString().contains('PLOMBERIE')) return Icons.water_drop;
    if (type.toString().contains('CVC')) return Icons.ac_unit;
    if (type.toString().contains('ASCENSEUR')) return Icons.elevator;
    return Icons.build;
  }
}
