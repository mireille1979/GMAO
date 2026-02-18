import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  
  // Default values
  bool _emailEnabled = true;
  bool _pushEnabled = true;
  bool _smsEnabled = false;
  bool _interventionUpdates = true;
  bool _generalInfo = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final response = await _apiClient.dio.get('/users/me/preferences');
      if (response.statusCode == 200) {
        final data = response.data;
        if (mounted) {
          setState(() {
            _emailEnabled = data['emailEnabled'] ?? true;
            _pushEnabled = data['pushEnabled'] ?? true;
            _smsEnabled = data['smsEnabled'] ?? false;
            _interventionUpdates = data['interventionUpdates'] ?? true;
            _generalInfo = data['generalInfo'] ?? true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur chargement préférences')),
        );
      }
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.dio.put('/users/me/preferences', data: {
        'emailEnabled': _emailEnabled,
        'pushEnabled': _pushEnabled,
        'smsEnabled': _smsEnabled,
        'interventionUpdates': _interventionUpdates,
        'generalInfo': _generalInfo,
      });

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Préférences sauvegardées')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur sauvegarde')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Canaux de communication',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Email'),
            subtitle: const Text('Recevoir des emails'),
            value: _emailEnabled,
            onChanged: (val) => setState(() => _emailEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Push (Mobile)'),
            subtitle: const Text('Recevoir des notifications sur l\'app'),
            value: _pushEnabled,
            onChanged: (val) => setState(() => _pushEnabled = val),
          ),
          SwitchListTile(
            title: const Text('SMS'),
            subtitle: const Text('Recevoir des SMS (Frais possibles)'),
            value: _smsEnabled,
            onChanged: (val) => setState(() => _smsEnabled = val),
          ),
          const Divider(height: 40),
          const Text(
            'Types de notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Mises à jour Interventions'),
            subtitle: const Text('Changement de statut, assignation...'),
            value: _interventionUpdates,
            onChanged: (val) => setState(() => _interventionUpdates = val),
          ),
          SwitchListTile(
            title: const Text('Informations Générales'),
            subtitle: const Text('Newsletters, maintenance système...'),
            value: _generalInfo,
            onChanged: (val) => setState(() => _generalInfo = val),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _savePreferences,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('ENREGISTRER'),
          ),
        ],
      ),
    );
  }
}
