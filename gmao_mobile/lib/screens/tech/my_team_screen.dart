import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/team_provider.dart';
import '../../models/equipe.dart';
import '../../utils/theme.dart';
import '../../models/user.dart'; // Ensure User is imported for type checks

class MyTeamScreen extends StatefulWidget {
  const MyTeamScreen({super.key});

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen> {
  bool _isLoading = false;
  Equipe? _myEquipe;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyTeam();
    });
  }

  Future<void> _loadMyTeam() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<AuthProvider>(context, listen: false);
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);

      final currentUser = userProvider.user;

      if (currentUser?.equipe != null && currentUser!.equipe!.id != null) {
        // Correctly awaiting the fetch
        final team = await teamProvider.fetchEquipeById(currentUser.equipe!.id);
        if (mounted) {
          setState(() {
            _myEquipe = team;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading my team: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Mon Équipe', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.textDark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : _myEquipe == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Vous n\'êtes assigné à aucune équipe.', style: TextStyle(color: AppTheme.textGrey)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Team Header Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppTheme.orangeGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: AppTheme.primaryOrange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _myEquipe!.nom,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            if (_myEquipe!.description != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _myEquipe!.description!,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Chef Section
                      if (_myEquipe!.chef != null) ...[
                        const Text("Chef d'équipe", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        const SizedBox(height: 12),
                        _buildMemberCard(_myEquipe!.chef!, isChef: true),
                        const SizedBox(height: 32),
                      ],
            
                      // Members Section
                      const Text("Mes Collègues", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      const SizedBox(height: 12),
                      
                      if (_myEquipe!.membres == null || _myEquipe!.membres!.isEmpty || (_myEquipe!.membres!.length == 1 && _myEquipe!.membres!.first.id == _myEquipe!.chef?.id))
                         const Text("Aucun autre membre dans cette équipe.", style: TextStyle(color: AppTheme.textGrey))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _myEquipe!.membres!.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final member = _myEquipe!.membres![index];
                            if (member.id == _myEquipe!.chef?.id) return const SizedBox.shrink(); 
                            return _buildMemberCard(member);
                          },
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMemberCard(User member, {bool isChef = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isChef ? Border.all(color: AppTheme.primaryOrange, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isChef ? AppTheme.primaryOrange.withOpacity(0.1) : Colors.grey.shade100,
          child: Text(
            member.firstName?[0].toUpperCase() ?? '?',
            style: TextStyle(color: isChef ? AppTheme.primaryOrange : AppTheme.textDark, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${member.firstName} ${member.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        subtitle: Text(
          member.poste?.titre ?? (isChef ? 'Responsable' : 'Membre'),
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
        ),
        trailing: isChef 
            ? const Icon(Icons.star, color: AppTheme.primaryOrange)
            :  null,
      ),
    );
  }
}
