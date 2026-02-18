import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/equipe.dart';
import '../models/poste.dart';
import '../models/user.dart';

class TeamProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Equipe> _equipes = [];
  List<Poste> _postes = [];
  bool _isLoading = false;

  List<Equipe> get equipes => _equipes;
  List<Poste> get postes => _postes;
  bool get isLoading => _isLoading;

  Future<void> fetchEquipes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/equipes');
      if (response.statusCode == 200) {
        _equipes = (response.data as List)
            .map((e) => Equipe.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching equipes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Equipe?> fetchEquipeById(int id) async {
    try {
      final response = await _apiClient.dio.get('/equipes/$id');
      if (response.statusCode == 200) {
        return Equipe.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetching equipe by id: $e');
    }
    return null;
  }

  Future<void> fetchPostes() async {
    try {
      final response = await _apiClient.dio.get('/postes');
      if (response.statusCode == 200) {
        _postes = (response.data as List)
            .map((e) => Poste.fromJson(e))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching postes: $e');
    }
  }

  Future<void> createEquipe(String nom, String description) async {
    try {
      await _apiClient.dio.post('/equipes', data: {
        'nom': nom,
        'description': description,
      });
      await fetchEquipes();
    } catch (e) {
      print('Error creating equipe: $e');
      rethrow;
    }
  }

  Future<void> createPoste(String titre, String description) async {
    try {
      await _apiClient.dio.post('/postes', data: {
        'titre': titre,
        'description': description,
      });
      await fetchPostes();
    } catch (e) {
      print('Error creating poste: $e');
      rethrow;
    }
  }
  
  // Assign user to team and poste
  Future<void> assignUser(int userId, int? equipeId, int? posteId) async {
    try {
      await _apiClient.dio.patch('/users/$userId/affectation', data: {
        'equipeId': equipeId,
        'posteId': posteId,
      });
      // You might want to refresh user list or selected user here
    } catch (e) {
      print('Error assigning user: $e');
      rethrow;
    }
  }

  Future<void> deleteEquipe(int id) async {
    try {
      await _apiClient.dio.delete('/equipes/$id');
      _equipes.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting equipe: $e');
      rethrow;
    }
  }

  Future<void> updateEquipe(Equipe equipe) async {
    try {
      await _apiClient.dio.put('/equipes/${equipe.id}', data: equipe.toJson());
      final index = _equipes.indexWhere((e) => e.id == equipe.id);
      if (index != -1) {
        _equipes[index] = equipe;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating equipe: $e');
      rethrow;
    }
  }

  Future<void> updatePoste(int id, String titre, String description) async {
    try {
      await _apiClient.dio.put('/postes/$id', data: {
        'titre': titre,
        'description': description,
      });
      await fetchPostes();
    } catch (e) {
      print('Error updating poste: $e');
      rethrow;
    }
  }

  Future<void> deletePoste(int id) async {
    try {
      await _apiClient.dio.delete('/postes/$id');
      _postes.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting poste: $e');
      rethrow;
    }
  }
}
