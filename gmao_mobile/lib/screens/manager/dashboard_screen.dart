import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/intervention_provider.dart';
import '../../providers/notification_provider.dart';
import '../notification_screen.dart';
import '../profile_screen.dart';
import 'intervention_list_screen.dart';
import 'create_intervention_screen.dart';
import 'batiment_list_screen.dart';
import 'planning_screen.dart';
import 'maintenance_screen.dart';
import 'equipement_list_screen.dart';
import 'team_list_screen.dart';
import 'poste_list_screen.dart';
import 'technician_list_screen.dart';
import 'absence_list_screen.dart';
import 'supervisor_team_screen.dart';
import 'demande_list_screen.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/expandable_fab.dart';

import '../../widgets/custom_bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Pages for the bottom navigation
  final List<Widget> _pages = [
    const _DashboardHomeTab(),
    const PlanningScreen(),
    const CreateInterventionScreen(),
    const EquipementListScreen(batiment: null),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      extendBody: true, // Allow body to flow behind the floating navbar
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: _selectedIndex == 0 ? _buildFab(context) : null, 
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return ExpandableFab(
      distance: 10,
      actions: [
        FabAction(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TechnicianListScreen()));
          },
          icon: const Icon(Icons.engineering, color: Colors.white),
          label: 'Techniciens',
          color: Colors.teal,
        ),
        FabAction(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamListScreen()));
          },
          icon: const Icon(Icons.group, color: Colors.white),
          label: 'Équipes',
          color: Colors.orange,
        ),
        FabAction(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BatimentListScreen()));
          },
          icon: const Icon(Icons.apartment, color: Colors.white),
          label: 'Bâtiments',
          color: Colors.indigo,
        ),
         FabAction(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DemandeListScreen()));
          },
          icon: const Icon(Icons.confirmation_number, color: Colors.white),
          label: 'Demandes',
          color: Colors.amber.shade700,
        ),
      ],
    );
  }
}

// Extracted Home Tab Content
class _DashboardHomeTab extends StatefulWidget {
  const _DashboardHomeTab();

  @override
  State<_DashboardHomeTab> createState() => _DashboardHomeTabState();
}

class _DashboardHomeTabState extends State<_DashboardHomeTab> {
  late InterventionProvider _interventionProvider;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
       _interventionProvider = Provider.of<InterventionProvider>(context, listen: false);
       _interventionProvider.fetchDashboardStats();
       _interventionProvider.startPolling();
       Provider.of<NotificationProvider>(context, listen: false).fetchUnreadCount();
    });
  }

  @override
  void dispose() {
    _interventionProvider.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final stats = Provider.of<InterventionProvider>(context).dashboardStats;
    final unreadCount = Provider.of<NotificationProvider>(context).unreadCount;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.firstName ?? "Utilisateur"}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bienvenue !',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                     GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()))
                            .then((_) => Provider.of<NotificationProvider>(context, listen: false).fetchUnreadCount());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Stack(
                          children: [
                            const Icon(Icons.notifications_outlined, color: AppTheme.textDark),
                            if (unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.errorRed,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                      child: const CircleAvatar(
                        backgroundColor: AppTheme.lightTeal,
                        child: Icon(Icons.person, color: AppTheme.darkTeal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Aperçu GMAO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          stats != null ? '${stats.enCoursCount} En cours' : 'Chargement...',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Taux de Résolution',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        stats != null ? '${stats.tauxResolution.toStringAsFixed(1)}%' : '0%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.trending_up, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // stats Grid
            if (stats != null) ...[
               GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.6,
                children: [
                  _buildStatCard(
                    'Urgences', 
                    stats.activeUrgentCount.toString(), 
                    Icons.warning_amber_rounded, 
                    AppTheme.errorRed,
                    isLight: true,
                  ),
                  _buildStatCard(
                    'Terminées', 
                    stats.finishedCount.toString(), 
                    Icons.check_circle_outline, 
                    const Color(0xFF4CAF50),
                    isLight: true,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Actions Grid (Filtered - some moved to Navbar or FAB, but user said "Action Rapide" previously. Should we keep all?)
            // The user asked for specific Navbar/FAB behavior. The grid might be redundant or supplementary.
            // Let's keep the full grid for "completeness" as requested in previous step, but update navigation if needed.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Actions Rapides',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    fontFamily: 'Poppins',
                  ),
                ),
                Icon(Icons.widgets_outlined, color: AppTheme.textGrey.withOpacity(0.7)),
              ],
            ),
            const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                   _buildMenuCard(context, 'Interventions', Icons.assignment_outlined, Colors.purple, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InterventionListScreen()));
                  }),
                   _buildMenuCard(context, 'Postes', Icons.badge_outlined, Colors.deepPurple, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PosteListScreen()));
                  }),
                  _buildMenuCard(context, 'Maintenance', Icons.build_circle_outlined, Colors.redAccent, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MaintenanceScreen()));
                  }),
                  _buildMenuCard(context, 'Absences', Icons.event_busy_outlined, Colors.pink, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AbsenceListScreen()));
                  }),
                   _buildMenuCard(context, 'Superviseur', Icons.admin_panel_settings_outlined, Colors.cyan, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SupervisorTeamScreen()));
                  }),
                   _buildMenuCard(context, 'Export CSV', Icons.download_rounded, Colors.green.shade800, () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Export CSV : Vérifiez votre dossier de téléchargements ou ouvrez l\'URL API.'),
                          backgroundColor: AppTheme.primaryTeal,
                        ),
                      );
                    }),
                ],
              ),
            const SizedBox(height: 80), // Extra space for FAB and Navbar
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isLight = false}) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: isLight ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24), // Reduced icon size
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22, // Reduced font size
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 2), // Reduced spacing
           Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11, // Reduced font size
              color: AppTheme.textGrey,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, {bool isHighlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isHighlight ? AppTheme.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHighlight ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isHighlight ? Colors.white : color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isHighlight ? Colors.white : AppTheme.textDark,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
