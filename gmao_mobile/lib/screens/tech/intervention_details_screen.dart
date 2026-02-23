import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/intervention_provider.dart';
import '../../models/intervention.dart';
import '../../utils/theme.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Intervention démarrée !"), backgroundColor: AppTheme.primaryOrange),
        );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Clôturer l'intervention", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rapport:", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _reportController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Description des travaux effectués...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Coût (FCFA):", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Ex: 15000",
                suffixText: "FCFA",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Annuler", style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Intervention terminée ! Bravo !"),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
      }
    }
  }

  Color _getStatusColor(Statut status) {
    if (status == Statut.EN_COURS) return Colors.orange;
    if (status == Statut.TERMINEE) return Colors.green;
    if (status == Statut.PLANIFIEE) return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InterventionProvider>(context);
    final currentIntervention = provider.interventions.firstWhere(
      (i) => i.id == widget.intervention.id,
      orElse: () => widget.intervention,
    );
    
    if (_currentStatus != currentIntervention.statut) {
        _currentStatus = currentIntervention.statut;
    }

    final statusColor = _getStatusColor(_currentStatus);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Détails Intervention", style: TextStyle(color: AppTheme.textDark, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentStatus.toString().split('.').last,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
        bottom: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryOrange,
            unselectedLabelColor: AppTheme.textGrey,
            indicatorColor: AppTheme.primaryOrange,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            tabs: const [
              Tab(text: "Info"),
              Tab(text: "Checklist"),
              Tab(text: "Rapport"),
            ],
          ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(currentIntervention, statusColor),
          _buildChecklistTab(currentIntervention),
          _buildReportTab(currentIntervention),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Intervention intervention, Color statusColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.orangeGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryOrange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        intervention.titre,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      intervention.priorite == Priorite.URGENTE ? Icons.warning_rounded : Icons.info_outline,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      intervention.datePrevue?.toLocal().toString().split(' ')[0] ?? "Date inconnue",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          const Text("Localisation & Équipement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.apartment, "Bâtiment", intervention.batiment?.nom ?? "N/A"),
                const Divider(height: 24),
                _buildInfoRow(Icons.build_circle, "Équipement", intervention.equipement?.nom ?? "N/A"),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(intervention.description, style: const TextStyle(color: AppTheme.textDark, height: 1.5)),
          ),
          
          const SizedBox(height: 40),
          _buildActionButton(intervention),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryOrange, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildChecklistTab(Intervention intervention) {
    final checklist = intervention.checklist ?? [];
    return Column(
      children: [
         Padding(
           padding: const EdgeInsets.all(20),
           child: Row(
             children: [
               const Icon(Icons.checklist, color: AppTheme.primaryOrange),
               const SizedBox(width: 10),
               Text(
                 "Tâches (${checklist.where((i) => i.isChecked).length}/${checklist.length})",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
               ),
             ],
           ),
         ),
        Expanded(
          child: checklist.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text("Aucune checklist", style: TextStyle(color: AppTheme.textGrey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: checklist.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = checklist[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.isChecked ? AppTheme.primaryOrange.withOpacity(0.5) : Colors.transparent,
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                      ),
                      child: CheckboxListTile(
                        activeColor: AppTheme.primaryOrange,
                        title: Text(
                          item.description,
                          style: TextStyle(
                            decoration: item.isChecked ? TextDecoration.lineThrough : null,
                            color: item.isChecked ? AppTheme.textGrey : AppTheme.textDark,
                          ),
                        ),
                        value: item.isChecked,
                        onChanged: intervention.statut == Statut.EN_COURS
                            ? (bool? value) async {
                                await Provider.of<InterventionProvider>(context, listen: false)
                                    .toggleChecklistItem(item.id, intervention.id);
                              }
                            : null, 
                      ),
                    );
                  },
                ),
        ),
        if (intervention.statut == Statut.EN_COURS)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryOrange,
                  side: const BorderSide(color: AppTheme.primaryOrange),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add),
                label: const Text("Ajouter une tâche"),
                onPressed: () => _showAddChecklistDialog(),
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Nouvelle tâche"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Description de la tâche",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
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

  Widget _buildReportTab(Intervention intervention) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Rapport final", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 12),
                if (intervention.compteRendu != null && intervention.compteRendu!.isNotEmpty)
                  Text(intervention.compteRendu!, style: const TextStyle(fontSize: 14, height: 1.5))
                else
                  const Text("Aucun rapport disponible. Clôturez l'intervention pour en ajouter un.", 
                      style: TextStyle(color: AppTheme.textGrey, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Coût Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                Text(
                  intervention.cout != null ? "${intervention.cout} FCFA" : "---",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Intervention intervention) {
    if (intervention.statut == Statut.PLANIFIEE) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _onStart,
          icon: const Icon(Icons.play_arrow),
          label: const Text("DÉMARRER"),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange, 
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppTheme.primaryOrange.withOpacity(0.4),
          ),
        ),
      );
    } else if (intervention.statut == Statut.EN_COURS) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _showFinishDialog,
          icon: const Icon(Icons.check_circle),
          label: const Text("TERMINER"),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: Colors.green.withOpacity(0.4),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.lock),
          label: const Text("CLÔTURÉE"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey,
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      );
    }
  }
}
