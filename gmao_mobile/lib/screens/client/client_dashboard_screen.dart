import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/demande_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/intervention.dart';
import '../auth/login_screen.dart';
import '../profile_screen.dart';
import '../notification_screen.dart';
import 'create_demande_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<NotificationProvider>(context, listen: false).fetchUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _MesDemandesTab(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Mes Demandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _MesDemandesTab extends StatefulWidget {
  const _MesDemandesTab();

  @override
  State<_MesDemandesTab> createState() => _MesDemandesTabState();
}

class _MesDemandesTabState extends State<_MesDemandesTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<DemandeProvider>(context, listen: false).fetchMesDemandes());
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

  IconData _prioriteIcon(Priorite p) {
    switch (p) {
      case Priorite.BASSE:
        return Icons.arrow_downward;
      case Priorite.MOYENNE:
        return Icons.remove;
      case Priorite.URGENTE:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Client'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()))
                          .then((_) => notifProvider.fetchUnreadCount());
                    },
                  ),
                  if (notifProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          notifProvider.unreadCount > 99 ? '99+' : '${notifProvider.unreadCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateDemandeScreen()),
          );
          if (result == true) {
            Provider.of<DemandeProvider>(context, listen: false).fetchMesDemandes();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Demande'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Welcome header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade400],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue, ${user?.firstName ?? "Client"} !',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Suivez vos demandes d\'intervention',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Demandes list
          Expanded(
            child: Consumer<DemandeProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.mesDemandes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune demande pour le moment',
                          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 8),
                        const Text('Appuyez sur + pour créer votre première demande'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchMesDemandes(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.mesDemandes.length,
                    itemBuilder: (context, index) {
                      final demande = provider.mesDemandes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(_prioriteIcon(demande.priorite), size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(demande.priorite.toString().split('.').last,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  const Spacer(),
                                  if (demande.batiment != null) ...[
                                    const Icon(Icons.business, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(demande.batiment!.nom,
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                  if (demande.technicien != null) ...[
                                    const SizedBox(width: 12),
                                    const Icon(Icons.person, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text('${demande.technicien!.firstName}',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
