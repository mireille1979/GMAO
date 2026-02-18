import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/demande_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/intervention.dart';
import '../../models/user.dart';

class DemandeListScreen extends StatefulWidget {
  const DemandeListScreen({super.key});

  @override
  State<DemandeListScreen> createState() => _DemandeListScreenState();
}

class _DemandeListScreenState extends State<DemandeListScreen> {
  bool _enAttenteOnly = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DemandeProvider>(context, listen: false).fetchAllDemandes(enAttenteOnly: _enAttenteOnly);
      Provider.of<UserProvider>(context, listen: false).fetchTechnicians();
    });
  }

  void _refreshList() {
    Provider.of<DemandeProvider>(context, listen: false).fetchAllDemandes(enAttenteOnly: _enAttenteOnly);
  }

  Color _statutColor(Statut statut) {
    switch (statut) {
      case Statut.EN_ATTENTE:
        return Colors.orange;
      case Statut.PLANIFIEE:
        return Colors.blue;
      case Statut.EN_COURS:
        return Colors.indigo;
      case Statut.TERMINEE:
        return Colors.green;
      case Statut.ANNULEE:
        return Colors.red;
    }
  }

  String _statutLabel(Statut statut) {
    switch (statut) {
      case Statut.EN_ATTENTE:
        return 'En attente';
      case Statut.PLANIFIEE:
        return 'Planifiée';
      case Statut.EN_COURS:
        return 'En cours';
      case Statut.TERMINEE:
        return 'Terminée';
      case Statut.ANNULEE:
        return 'Refusée';
    }
  }

  Future<void> _showAccepterDialog(Intervention demande) async {
    final techniciens = Provider.of<UserProvider>(context, listen: false).technicians;
    User? selectedTech;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Accepter la demande'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Titre: ${demande.titre}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(demande.description, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  const Text('Assigner un technicien:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<User>(
                    value: selectedTech,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Choisir un technicien',
                    ),
                    items: techniciens.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text('${t.firstName} ${t.lastName}'),
                    )).toList(),
                    onChanged: (val) => setDialogState(() => selectedTech = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: selectedTech == null ? null : () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Accepter', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && selectedTech != null && mounted) {
      final success = await Provider.of<DemandeProvider>(context, listen: false)
          .accepterDemande(demande.id, technicienId: selectedTech!.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande acceptée !'), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<void> _refuserDemande(Intervention demande) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refuser la demande ?'),
        content: Text('Voulez-vous refuser la demande "${demande.titre}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Refuser', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await Provider.of<DemandeProvider>(context, listen: false)
          .refuserDemande(demande.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande refusée'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes / Tickets'),
        actions: [
          FilterChip(
            label: Text(_enAttenteOnly ? 'En attente' : 'Toutes'),
            selected: _enAttenteOnly,
            onSelected: (val) {
              setState(() => _enAttenteOnly = val);
              _refreshList();
            },
            selectedColor: Colors.orange.shade200,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<DemandeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.allDemandes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    _enAttenteOnly ? 'Aucune demande en attente' : 'Aucune demande',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAllDemandes(enAttenteOnly: _enAttenteOnly),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.allDemandes.length,
              itemBuilder: (context, index) {
                final demande = provider.allDemandes[index];
                final isEnAttente = demande.statut == Statut.EN_ATTENTE;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                demande.titre,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statutColor(demande.statut).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _statutColor(demande.statut)),
                              ),
                              child: Text(
                                _statutLabel(demande.statut),
                                style: TextStyle(
                                  color: _statutColor(demande.statut),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          demande.description,
                          style: TextStyle(color: Colors.grey[600]),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Client info
                        if (demande.client != null)
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Client: ${demande.client!.firstName} ${demande.client!.lastName}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),

                        // Metadata row
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.flag, size: 14,
                                color: demande.priorite == Priorite.URGENTE ? Colors.red : Colors.grey),
                            const SizedBox(width: 4),
                            Text(demande.priorite.toString().split('.').last,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            if (demande.batiment != null) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.business, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(demande.batiment!.nom,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ],
                        ),

                        // Action buttons (only for EN_ATTENTE)
                        if (isEnAttente) ...[
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _refuserDemande(demande),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Refuser'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () => _showAccepterDialog(demande),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Accepter'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
