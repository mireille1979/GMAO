import 'package:flutter/material.dart';
import '../../models/user.dart';

class TechnicianDetailScreen extends StatelessWidget {
  final User technician;

  const TechnicianDetailScreen({super.key, required this.technician});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${technician.firstName} ${technician.lastName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar + Status
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          '${technician.firstName.isNotEmpty ? technician.firstName[0] : ''}${technician.lastName.isNotEmpty ? technician.lastName[0] : ''}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: technician.disponible ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            technician.disponible ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${technician.firstName} ${technician.lastName}',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: technician.disponible ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: technician.disponible ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      technician.disponible ? 'Disponible' : 'Indisponible',
                      style: TextStyle(
                        color: technician.disponible ? Colors.green.shade800 : Colors.red.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info Cards
            _buildInfoCard(
              context,
              icon: Icons.email_outlined,
              label: 'Email',
              value: technician.email,
              color: Colors.blue,
            ),
            _buildInfoCard(
              context,
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              value: technician.telephone ?? 'Non renseigné',
              color: Colors.green,
            ),
            _buildInfoCard(
              context,
              icon: Icons.build_outlined,
              label: 'Spécialité',
              value: technician.specialite ?? 'Non renseignée',
              color: Colors.orange,
            ),
            _buildInfoCard(
              context,
              icon: Icons.work_outlined,
              label: 'Poste',
              value: technician.poste?.titre ?? 'Aucun poste',
              color: Colors.brown,
            ),
            _buildInfoCard(
              context,
              icon: Icons.group_outlined,
              label: 'Équipe',
              value: technician.equipe?.nom ?? 'Aucune équipe',
              color: Colors.indigo,
            ),
            _buildInfoCard(
              context,
              icon: Icons.person_outlined,
              label: 'Rôle',
              value: technician.role.toString().split('.').last,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
