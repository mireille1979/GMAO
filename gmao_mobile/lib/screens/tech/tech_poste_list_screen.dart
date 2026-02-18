import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';

/// Read-only view of Postes for technicians.
class TechPosteListScreen extends StatefulWidget {
  const TechPosteListScreen({super.key});

  @override
  _TechPosteListScreenState createState() => _TechPosteListScreenState();
}

class _TechPosteListScreenState extends State<TechPosteListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TeamProvider>(context, listen: false).fetchPostes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Les Postes'),
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
                  leading: CircleAvatar(
                    backgroundColor: Colors.brown.shade100,
                    child: Icon(Icons.work, color: Colors.brown.shade700),
                  ),
                  title: Text(poste.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(poste.description ?? 'Aucune description'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
