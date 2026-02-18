import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/team_provider.dart';
import '../../models/equipe.dart';

class MyTeamScreen extends StatefulWidget {
  const MyTeamScreen({super.key});

  @override
  _MyTeamScreenState createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen> {
  bool _isLoading = false;
  Equipe? _myEquipe;

  @override
  void initState() {
    super.initState();
    _loadMyTeam();
  }

  Future<void> _loadMyTeam() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<AuthProvider>(context, listen: false);
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);

      final currentUser = userProvider.user;

      if (currentUser?.equipe != null && currentUser!.equipe!.id != null) {
        // Fetch only the tech's own team by ID
        _myEquipe = await teamProvider.fetchEquipeById(currentUser.equipe!.id);
      }
    } catch (e) {
      print('Error loading my team: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_myEquipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon Équipe')),
        body: const Center(child: Text('Vous n\'êtes assigné à aucune équipe.')),
      );
    }

    final members = _myEquipe!.membres ?? [];
    final chef = _myEquipe!.chef;

    return Scaffold(
      appBar: AppBar(title: Text(_myEquipe!.nom)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_myEquipe!.description != null) ...[
              Text(
                'Description: ${_myEquipe!.description}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
            ],

            // Display Chef
            const Text(
              'Chef d\'équipe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.blue.shade50,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: chef != null 
                     ? Text(chef.firstName?[0] ?? 'C', style: const TextStyle(color: Colors.white))
                     : const Icon(Icons.person_off, color: Colors.white),
                ),
                title: Text(chef != null ? '${chef.firstName} ${chef.lastName}' : 'Aucun chef désigné'),
                subtitle: const Text('Responsable'),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Display Colleagues
            const Text(
              'Mes Collègues',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: members.isEmpty
                  ? const Center(child: Text('Aucun autre membre.'))
                  : ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        // Skip displaying chef in the colleagues list to avoid duplication if preferred,
                        // or highlight differently. Here we show all.
                        if (member.id == chef?.id) return const SizedBox.shrink(); // Hide chef from colleagues list

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(member.firstName?[0] ?? '?'),
                            ),
                            title: Text('${member.firstName} ${member.lastName}'),
                            subtitle: Text(member.poste?.titre ?? 'Sans poste'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
