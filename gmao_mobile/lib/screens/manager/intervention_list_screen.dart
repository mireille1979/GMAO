import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/intervention_provider.dart';
import '../../models/intervention.dart';
import 'create_intervention_screen.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_card.dart';

class InterventionListScreen extends StatefulWidget {
  const InterventionListScreen({super.key});

  @override
  State<InterventionListScreen> createState() => _InterventionListScreenState();
}

class _InterventionListScreenState extends State<InterventionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InterventionProvider>(context, listen: false).fetchInterventions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Mes Interventions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.filter_list, color: AppTheme.textDark),
                  ),
                ],
              ),
            ),
            
            // Calendar Strip Placeholder
            SizedBox(
              height: 90,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = index == 0;
                  return Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 12, bottom: 8, top: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryTeal : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (!isSelected)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E().format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textGrey,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Interventions List
            Expanded(
              child: Consumer<InterventionProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
                  }

                  if (provider.interventions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: AppTheme.textGrey.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text('Aucune intervention planifiée.', style: TextStyle(color: AppTheme.textGrey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: provider.interventions.length,
                    itemBuilder: (context, index) {
                      return _buildInterventionCard(provider.interventions[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateInterventionScreen()),
          ).then((_) {
            Provider.of<InterventionProvider>(context, listen: false).fetchInterventions();
          });
        },
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInterventionCard(Intervention intervention) {
    if (intervention.datePrevue == null) return const SizedBox.shrink();
    
    final date = intervention.datePrevue!;
    
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightTeal.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat.E().format(date).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    intervention.titre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppTheme.textGrey),
                      const SizedBox(width: 4),
                      Text(
                        intervention.technicien?.firstName ?? "Non assigné",
                        style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          intervention.batiment?.nom ?? "N/A",
                          style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontFamily: 'Poppins'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(intervention.statut).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                intervention.statut.toString().split('.').last,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(intervention.statut),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(Statut? status) {
    if (status == null) return Colors.grey;
    switch (status) {
      case Statut.PLANIFIEE: return Colors.blue;
      case Statut.EN_COURS: return Colors.orange;
      case Statut.TERMINEE: return Colors.green;
      case Statut.ANNULEE: return Colors.red;
      default: return Colors.grey;
    }
  }
}
