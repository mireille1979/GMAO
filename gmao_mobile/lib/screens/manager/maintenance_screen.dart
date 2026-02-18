import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/batiment_provider.dart';
import '../../models/batiment_maintenance_stats.dart';
import 'intervention_list_screen.dart'; // To drill down if needed

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BatimentProvider>(context, listen: false).fetchMaintenanceStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<BatimentProvider>(context, listen: false).fetchMaintenanceStats();
            },
          ),
        ],
      ),
      body: Consumer<BatimentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.maintenanceStats.isEmpty) {
            return const Center(child: Text('Aucune donnée de maintenance.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.maintenanceStats.length,
            itemBuilder: (context, index) {
              final stats = provider.maintenanceStats[index];
              return _buildMaintenanceCard(context, stats);
            },
          );
        },
      ),
    );
  }

  Widget _buildMaintenanceCard(BuildContext context, BatimentMaintenanceStats stats) {
    Color cardColor;
    IconData statusIcon;
    String statusText;

    switch (stats.status) {
      case 'CRITICAL':
        cardColor = Colors.red.shade100;
        statusIcon = Icons.warning;
        statusText = 'Critique';
        break;
      case 'WARNING':
        cardColor = Colors.orange.shade100;
        statusIcon = Icons.report_problem;
        statusText = 'Attention';
        break;
      default:
        cardColor = Colors.green.shade100;
        statusIcon = Icons.check_circle;
        statusText = 'Sûr';
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(statusIcon, color: _getIconColor(stats.status)),
        ),
        title: Text(
          stats.batimentName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Statut: $statusText', style: TextStyle(color: _getIconColor(stats.status), fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Interventions actives: ${stats.activeInterventionCount}'),
            Text('Urgences critiques: ${stats.criticalPriorityCount}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Drill down to interventions filtered by building roughly
          // Ideally we would pass a filter to InterventionListScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InterventionListScreen()), 
          );
        },
      ),
    );
  }

  Color _getIconColor(String status) {
    switch (status) {
      case 'CRITICAL': return Colors.red;
      case 'WARNING': return Colors.orange;
      default: return Colors.green;
    }
  }
}
