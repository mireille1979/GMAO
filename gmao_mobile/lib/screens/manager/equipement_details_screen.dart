import 'package:flutter/material.dart';
import '../../models/equipement.dart';
import '../../models/intervention.dart';
import '../../providers/intervention_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EquipementDetailsScreen extends StatefulWidget {
  final Equipement equipement;

  const EquipementDetailsScreen({super.key, required this.equipement});

  @override
  State<EquipementDetailsScreen> createState() => _EquipementDetailsScreenState();
}

class _EquipementDetailsScreenState extends State<EquipementDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.equipement.nom),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Informations"),
            Tab(text: "Historique"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.label, "Nom", widget.equipement.nom),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.category, "Type", widget.equipement.type.toString().split('.').last),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.info_outline, "État", widget.equipement.etat.toString().split('.').last),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.apartment, "Bâtiment", widget.equipement.batiment?.nom ?? "N/A"),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.place, "Zone", widget.equipement.zoneName ?? "N/A"),
          // Add more fields if available in model
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return FutureBuilder<List<Intervention>>(
      future: Provider.of<InterventionProvider>(context, listen: false)
          .fetchInterventionsByEquipement(widget.equipement.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Erreur: ${snapshot.error}"));
        }
        final interventions = snapshot.data ?? [];

        if (interventions.isEmpty) {
          return const Center(child: Text("Aucune intervention enregistrée."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: interventions.length,
          itemBuilder: (context, index) {
            final intervention = interventions[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: intervention.statut.toString().contains("TERMINEE") ? Colors.green : Colors.orange,
                  child: const Icon(Icons.history, color: Colors.white),
                ),
                title: Text(intervention.titre),
                subtitle: Text("Du ${intervention.datePrevue != null ? DateFormat('dd/MM/yyyy').format(intervention.datePrevue!) : 'N/A'} par ${intervention.technicien?.firstName ?? 'N/A'}"),
                trailing: Text(intervention.statut.toString().split('.').last),
              ),
            );
          },
        );
      },
    );
  }
}
