import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/intervention_provider.dart';
import '../../models/intervention.dart';
import '../auth/login_screen.dart';
import '../profile_screen.dart';
import 'intervention_details_screen.dart';
import 'tech_planning_screen.dart';
import 'my_team_screen.dart';
import 'my_absences_screen.dart';
import 'tech_poste_list_screen.dart';
import '../../widgets/tech_performance_card.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_bottom_nav_bar.dart'; // Reusing or need specific? Let's use specific logic inside

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user?.id != null) {
         final provider = Provider.of<InterventionProvider>(context, listen: false);
         provider.fetchTechnicianInterventions(auth.user!.id!);
         provider.startPolling(techId: auth.user!.id!);
      }
    });
  }

  @override
  void dispose() {
    Provider.of<InterventionProvider>(context, listen: false).stopPolling();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigation logic
    if (index == 1) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const TechPlanningScreen()));
    } else if (index == 2) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, ${user?.firstName ?? "Technicien"} !',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Prêt pour la journée ?',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGrey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.orange.withOpacity(0.2),
                      backgroundImage: user?.photo != null ? NetworkImage('http://10.0.2.2:8080${user!.photo}') : null,
                      child: user?.photo == null ? const Icon(Icons.person, color: Colors.orange) : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 2. Performance Card (Orange)
              // Calculate real stats if possible, else mock for visual first
              Consumer<InterventionProvider>(
                builder: (context, provider, _) {
                  final finished = provider.interventions.where((i) => i.statut == Statut.TERMINEE).length;
                  final total = provider.interventions.length;
                  final percentage = total > 0 ? (finished / total * 100).toStringAsFixed(0) : '0';
                  
                  return TechPerformanceCard(
                    title: 'Taux de Résolution',
                    value: '$percentage%',
                    trend: '+5% vs semaine dernière',
                    isPositive: true,
                  );
                }
              ),
              const SizedBox(height: 32),

              // 3. Stats Grid (4 cards)
              Consumer<InterventionProvider>(
                builder: (context, provider, _) {
                   final finished = provider.interventions.where((i) => i.statut == Statut.TERMINEE).length;
                   final total = provider.interventions.length;
                   final urgent = provider.interventions.where((i) => i.priorite == Priorite.URGENTE && i.statut != Statut.TERMINEE).length;
                   final active = provider.interventions.where((i) => i.statut == Statut.EN_COURS || i.statut == Statut.PLANIFIEE).length;
                   // Mock hours
                   final hours = (finished * 2.5).toStringAsFixed(1); // Avg 2.5h per task

                   return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatItem('Total Tâches', total.toString(), Icons.assignment, Colors.blue),
                      _buildStatItem('Urgences', urgent.toString(), Icons.warning_amber_rounded, Colors.red),
                      _buildStatItem('En Cours', active.toString(), Icons.play_circle_outline, Colors.orange),
                      _buildStatItem('Terminées', finished.toString(), Icons.check_circle_outline, Colors.green),
                    ],
                  );
                }
              ),
              const SizedBox(height: 32),

              // 4. Recent Tasks List (or Graph)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tâches Récentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: AppTheme.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {}, // Navigate to full history?
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Consumer<InterventionProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                  final recents = provider.interventions.take(3).toList();
                  
                  if (recents.isEmpty) return const Text('Aucune tâche récente.');

                  return Column(
                    children: recents.map((intervention) => _buildTaskItem(context, intervention)).toList(),
                  );
                }
              ),
              
              const SizedBox(height: 80), // Bottom padding
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_filled, 'Accueil', true),
            _buildNavItem(1, Icons.calendar_month, 'Planning', false),
            _buildNavItem(2, Icons.person, 'Profil', false),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textGrey,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Intervention intervention) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getPriorityColor(intervention.priorite).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.build_circle_outlined, color: _getPriorityColor(intervention.priorite)),
        ),
        title: Text(
          intervention.titre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${intervention.batiment?.nom ?? "?"} • ${intervention.datePrevue?.toLocal().toString().split(' ')[0] ?? ""}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
        onTap: () {
           Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => InterventionDetailsScreen(intervention: intervention)),
            );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFFF5722) : AppTheme.textGrey, // Orange active
            size: 24,
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5722),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Color _getPriorityColor(Priorite priority) {
    switch (priority) {
      case Priorite.URGENTE: return Colors.red;
      case Priorite.MOYENNE: return Colors.orange;
      default: return Colors.green;
    }
  }
}
