import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/batiment_provider.dart';
import '../../models/batiment.dart';
import 'create_zone_screen.dart';

class ZoneListScreen extends StatefulWidget {
  final Batiment batiment;

  const ZoneListScreen({super.key, required this.batiment});

  @override
  State<ZoneListScreen> createState() => _ZoneListScreenState();
}

class _ZoneListScreenState extends State<ZoneListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BatimentProvider>(context, listen: false)
          .fetchZones(widget.batiment.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Zones - ${widget.batiment.nom}')),
      body: Consumer<BatimentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.zones.isEmpty) {
            return const Center(child: Text('Aucune zone définie.'));
          }

          return ListView.builder(
            itemCount: provider.zones.length,
            itemBuilder: (context, index) {
              final zone = provider.zones[index];
              return ListTile(
                leading: const Icon(Icons.meeting_room),
                title: Text(zone.nom),
                subtitle: Text(zone.type),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Supprimer ?'),
                        content: const Text('Cette action est irréversible.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await provider.deleteZone(zone.id);
                            },
                            child: const Text('Supprimer'),
                          ),
                        ],
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateZoneScreen(batimentId: widget.batiment.id),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
