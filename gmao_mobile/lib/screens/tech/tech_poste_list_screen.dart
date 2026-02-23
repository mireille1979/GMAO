import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../utils/theme.dart';

/// Read-only view of Postes for technicians.
class TechPosteListScreen extends StatefulWidget {
  const TechPosteListScreen({super.key});

  @override
  _TechPosteListScreenState createState() => _TechPosteListScreenState();
}

class _TechPosteListScreenState extends State<TechPosteListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TeamProvider>(context, listen: false).fetchPostes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Postes & Rôles', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.textDark),
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
          }

          if (provider.postes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucun poste disponible.', style: TextStyle(color: AppTheme.textGrey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: provider.postes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final poste = provider.postes[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.work_outline, color: AppTheme.primaryOrange),
                  ),
                  title: Text(
                    poste.titre,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  subtitle: Text(
                    poste.description ?? 'Aucune description',
                    style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
