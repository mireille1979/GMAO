import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../utils/theme.dart';
import 'auth/login_screen.dart';
import 'profile/change_password_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'settings/notification_settings_screen.dart';
import 'tech/my_absences_screen.dart';
import 'tech/my_team_screen.dart';
import 'tech/tech_poste_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    // Determine theme color based on role
    Color primaryColor = AppTheme.primaryTeal;
    if (user?.role == Role.TECH) {
      primaryColor = AppTheme.primaryOrange;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Avatar + Availability badge
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(0.1),
                      border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${user?.firstName.isNotEmpty == true ? user!.firstName[0] : ''}${user?.lastName.isNotEmpty == true ? user!.lastName[0] : ''}',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                  ),
                  if (user?.role == Role.TECH)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: user!.disponible ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(
                        user.disponible ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              '${user?.firstName} ${user?.lastName}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${user?.email}',
              style: const TextStyle(fontSize: 14, color: AppTheme.textGrey),
               textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Chips Container
            Wrap(
              spacing: 12,
              alignment: WrapAlignment.center,
              children: [
                Chip(
                  label: Text(user?.role.toString().split('.').last ?? 'Rôle Inconnu'),
                  backgroundColor: primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                if (user?.role == Role.TECH) 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: (user?.disponible ?? true) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      (user?.disponible ?? true) ? 'Disponible' : 'Indisponible',
                      style: TextStyle(
                        color: (user?.disponible ?? true) ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // Tech-specific fields
            if (user?.role == Role.TECH) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.phone, 'Téléphone', user?.telephone ?? 'Non renseigné', primaryColor),
                    const Divider(),
                    _buildInfoTile(Icons.build, 'Spécialité', user?.specialite ?? 'Non renseignée', primaryColor),
                    const Divider(),
                    _buildNavTile(context, Icons.badge, 'Mon Poste', user?.poste?.titre ?? 'Aucun poste', const TechPosteListScreen(), primaryColor),
                    const Divider(),
                    _buildNavTile(context, Icons.group, 'Mon Équipe', user?.equipe?.nom ?? 'Aucune équipe', const MyTeamScreen(), primaryColor),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tech Actions
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    _buildActionTile(context, Icons.event_busy, 'Mes Absences', const MyAbsencesScreen(), primaryColor),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // General Settings
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildActionTile(context, Icons.edit, 'Modifier le profil', const EditProfileScreen(), primaryColor),
                  const Divider(height: 1),
                  _buildActionTile(context, Icons.lock, 'Changer le mot de passe', const ChangePasswordScreen(), primaryColor),
                  const Divider(height: 1),
                  _buildActionTile(context, Icons.notifications, 'Paramètres de notification', const NotificationSettingsScreen(), primaryColor),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Se Déconnecter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, Widget destination, Color color) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      },
    );
  }

  Widget _buildNavTile(BuildContext context, IconData icon, String label, String value, Widget destination, Color color) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      },
    );
  }
}
