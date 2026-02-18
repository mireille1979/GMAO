import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/intervention_provider.dart';
import '../../models/intervention.dart';

class InterventionDetailsScreen extends StatefulWidget {
  final Intervention intervention;

  const InterventionDetailsScreen({super.key, required this.intervention});

  @override
  State<InterventionDetailsScreen> createState() => _InterventionDetailsScreenState();
}

class _InterventionDetailsScreenState extends State<InterventionDetailsScreen> with SingleTickerProviderStateMixin {
  late Statut _currentStatus;
  late TabController _tabController;
  final TextEditingController _reportController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.intervention.statut;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reportController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _onStart() async {
    try {
      await Provider.of<InterventionProvider>(context, listen: false)
          .startIntervention(widget.intervention.id);
      
      setState(() {
        _currentStatus = Statut.EN_COURS;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Intervention démarrée !")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
      }
    }
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clôturer l'intervention"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Veuillez saisir le rapport d'intervention :"),
            const SizedBox(height: 10),
            TextField(
              controller: _reportController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ex: Remplacement du fusible, test OK.",
              ),
            ),
            const SizedBox(height: 16),
            const Text("Coût de l'intervention (FCFA) :"),
            const SizedBox(height: 10),
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ex: 15000",
                suffixText: "FCFA",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 
              _onFinish(); 
            },
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  Future<void> _onFinish() async {
    if (_reportController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le rapport est vide !"), backgroundColor: Colors.orange));
        return;
    }
    
    double? cost = double.tryParse(_costController.text);

    try {
      await Provider.of<InterventionProvider>(context, listen: false)
          .finishIntervention(widget.intervention.id, _reportController.text, cost);
      
      setState(() {
        _currentStatus = Statut.TERMINEE;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Intervention terminée ! Bravo !")));
        Navigator.pop(context); // Return to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get latest data from provider to ensure UI updates
    final provider = Provider.of<InterventionProvider>(context);
    // Find the current intervention in the provider's list, fallback to widget.intervention
    final currentIntervention = provider.interventions.firstWhere(
      (i) => i.id == widget.intervention.id,
      orElse: () => widget.intervention,
    );
    
    // Update local status if needed to match global (though we rely on currentIntervention for fields)
    if (_currentStatus != currentIntervention.statut) {
        _currentStatus = currentIntervention.statut;
    }

    Color statusColor = Colors.grey;
    if (_currentStatus == Statut.EN_COURS) statusColor = Colors.orange;
    if (_currentStatus == Statut.TERMINEE) statusColor = Colors.green;
    if (_currentStatus == Statut.PLANIFIEE) statusColor = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails Intervention"),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Détails"),
              Tab(text: "Checklist"),
              Tab(text: "Rapport"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(currentIntervention),
            _buildChecklistTab(currentIntervention),
            _buildReportTab(currentIntervention),
          ],
        ),
      );
  }

  Widget _buildChecklistTab(Intervention intervention) {
    final checklist = intervention.checklist ?? [];
    return Column(
      children: [
        Expanded(
          child: checklist.isEmpty
              ? const Center(child: Text("Aucune tâche dans la checklist."))
              : ListView.builder(
                  itemCount: checklist.length,
                  itemBuilder: (context, index) {
                    final item = checklist[index];
                    return CheckboxListTile(
                      title: Text(item.description),
                      value: item.isChecked,
                      onChanged: intervention.statut.toString().contains("EN_COURS")
                          ? (bool? value) async {
                              // print("Toggling item ${item.id} to $value");
                              await Provider.of<InterventionProvider>(context, listen: false)
                                  .toggleChecklistItem(item.id, intervention.id);
                              // No setState needed given we listen to provider in build()
                            }
                          : null, 
                    );
                  },
                ),
        ),
        if (intervention.statut.toString().contains("EN_COURS"))
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Ajouter une tâche"),
              onPressed: () => _showAddChecklistDialog(),
            ),
          ),
      ],
    );
  }

  void _showAddChecklistDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouvelle tâche"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Description de la tâche"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                 await Provider.of<InterventionProvider>(context, listen: false)
                    .addChecklistItem(widget.intervention.id, controller.text);
                 Navigator.pop(context);
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Intervention intervention) {
    // Re-evaluate color based on current status from intervention
    Color statusColor = Colors.grey;
    if (intervention.statut == Statut.EN_COURS) statusColor = Colors.orange;
    if (intervention.statut == Statut.TERMINEE) statusColor = Colors.green;
    if (intervention.statut == Statut.PLANIFIEE) statusColor = Colors.blue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Priorité: ${intervention.priorite.toString().split('.').last}", 
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Chip(
                  label: Text(intervention.statut.toString().split('.').last),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Details
            ListTile(
              leading: const Icon(Icons.apartment, color: Colors.blue),
              title: Text(intervention.batiment?.nom ?? "N/A"),
              subtitle: const Text("Bâtiment"),
            ),
            ListTile(
              leading: const Icon(Icons.build, color: Colors.blue),
              title: Text(intervention.equipement?.nom ?? "Aucun équipement"),
              subtitle: const Text("Équipement"),
            ),
            const Divider(),
            const Text("Description du problème :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!)
              ),
              child: Text(intervention.description, style: const TextStyle(fontSize: 14)),
            ),
            
            const SizedBox(height: 20),

            // Action Zone
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _buildActionButton(intervention),
            ),
          ],
        ),
    );
  }

  Widget _buildActionButton(Intervention intervention) {
    if (intervention.statut == Statut.PLANIFIEE) {
      return ElevatedButton.icon(
        onPressed: _onStart,
        icon: const Icon(Icons.play_arrow),
        label: const Text("DÉMARRER L'INTERVENTION"),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, 
            foregroundColor: Colors.white
        ),
      );
    } else if (intervention.statut == Statut.EN_COURS) {
      return ElevatedButton.icon(
        onPressed: _showFinishDialog,
        icon: const Icon(Icons.check_circle),
        label: const Text("TERMINER & FAIRE RAPPORT"),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.lock),
        label: const Text("INTERVENTION CLÔTURÉE"),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey,
        ),
      );
    }
  }

  Widget _buildReportTab(Intervention intervention) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Rapport d'intervention", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (intervention.compteRendu != null && intervention.compteRendu!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(intervention.compteRendu!),
            )
          else
            const Text("Aucun rapport disponible.", style: TextStyle(color: Colors.grey)),
          
          const SizedBox(height: 20),
          const Text("Coût", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
           if (intervention.cout != null)
            Text("${intervention.cout} FCFA", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey))
          else
            const Text("Non renseigné", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
