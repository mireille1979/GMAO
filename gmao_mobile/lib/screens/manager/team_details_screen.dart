import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/equipe.dart';
import '../../models/user.dart';
import '../../providers/team_provider.dart';

class TeamDetailsScreen extends StatefulWidget {
  final Equipe equipe;

  const TeamDetailsScreen({super.key, required this.equipe});

  @override
  _TeamDetailsScreenState createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  User? _selectedChef;
  late Equipe _currentEquipe;

  @override
  void initState() {
    super.initState();
    _currentEquipe = widget.equipe;
    _selectedChef = _currentEquipe.chef;
  }

  Future<void> _updateChef(User? newChef) async {
    if (newChef == null) return;

    // Create updated equipe object
    final updatedEquipe = Equipe(
      id: _currentEquipe.id,
      nom: _currentEquipe.nom,
      description: _currentEquipe.description,
      chef: newChef,
      membres: _currentEquipe.membres,
    );

    try {
      await Provider.of<TeamProvider>(context, listen: false)
          .updateEquipe(updatedEquipe);
      
      setState(() {
        _currentEquipe = updatedEquipe;
        _selectedChef = newChef;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chef d\'équipe mis à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter members to exclude those who might not be suitable if needed, 
    // but generally any member can be chef.
    final members = _currentEquipe.membres ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentEquipe.nom),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description: ${_currentEquipe.description ?? "Aucune description"}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            const Text(
              'Chef d\'équipe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<User>(
                  isExpanded: true,
                  hint: const Text('Sélectionner un chef'),
                  value: _selectedChef != null && members.any((m) => m.id == _selectedChef!.id) 
                      ? members.firstWhere((m) => m.id == _selectedChef!.id) 
                      : null,
                  onChanged: (User? newValue) {
                    if (newValue != null) {
                       _updateChef(newValue);
                    }
                  },
                  items: members.map<DropdownMenuItem<User>>((User member) {
                    return DropdownMenuItem<User>(
                      value: member,
                      child: Text('${member.firstName} ${member.lastName} (${member.poste?.titre ?? "Sans poste"})'),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Membres de l\'équipe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: members.isEmpty
                  ? const Center(child: Text('Aucun membre dans cette équipe.'))
                  : ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final isChef = _selectedChef?.id == member.id;
                        return Card(
                          color: isChef ? Colors.blue.shade50 : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(member.firstName?[0] ?? '?'),
                            ),
                            title: Text('${member.firstName} ${member.lastName}'),
                            subtitle: Text(member.poste?.titre ?? 'Sans poste'),
                            trailing: isChef 
                                ? const Chip(
                                    label: Text('Chef'),
                                    backgroundColor: Colors.blue,
                                    labelStyle: TextStyle(color: Colors.white),
                                  )
                                : null,
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
