import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/team_provider.dart';
import '../../models/user.dart';
import '../../models/equipe.dart';
import '../../models/poste.dart';
import 'technician_detail_screen.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_card.dart';

class TechnicianListScreen extends StatefulWidget {
  const TechnicianListScreen({super.key});

  @override
  State<TechnicianListScreen> createState() => _TechnicianListScreenState();
}

class _TechnicianListScreenState extends State<TechnicianListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<UserProvider>(context, listen: false).fetchTechnicians();
      Provider.of<TeamProvider>(context, listen: false).fetchEquipes();
      Provider.of<TeamProvider>(context, listen: false).fetchPostes(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                      'Nos Techniciens',
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
                    child: const Icon(Icons.search, color: AppTheme.textDark),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Consumer<UserProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
                  }

                  if (provider.technicians.isEmpty) {
                    return const Center(child: Text('Aucun technicien trouvé.', style: TextStyle(color: AppTheme.textGrey)));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8, // Tall cards
                    ),
                    itemCount: provider.technicians.length,
                    itemBuilder: (context, index) {
                      return _buildTechnicianCard(context, provider.technicians[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianCard(BuildContext context, User tech) {
    return CustomCard(
      padding: EdgeInsets.zero,
      onTap: () {
         Navigator.of(context).push(
           MaterialPageRoute(
             builder: (_) => TechnicianDetailScreen(technician: tech),
           ),
         );
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTeal.withOpacity(0.5),
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/placeholder_tech.png'), // Placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      tech.firstName.isNotEmpty ? tech.firstName[0].toUpperCase() : 'T',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.darkTeal),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Name
                Text(
                  '${tech.firstName} ${tech.lastName}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: AppTheme.textDark,
                  ),
                ),
                
                // Role
                const SizedBox(height: 4),
                Text(
                  tech.poste?.titre ?? 'Technicien',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 8),
                // Rating/Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 12, color: AppTheme.accentOrange),
                      const SizedBox(width: 4),
                      const Text(
                        '4.8', // Dummy rating
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          // Availability Dot
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: (tech.disponible ?? true) ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
