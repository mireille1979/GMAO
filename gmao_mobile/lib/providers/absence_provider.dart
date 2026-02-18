import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/absence.dart';

class AbsenceProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Absence> _absences = [];
  List<Absence> _myAbsences = [];
  bool _isLoading = false;

  List<Absence> get absences => _absences;
  List<Absence> get myAbsences => _myAbsences;
  bool get isLoading => _isLoading;

  // Manager: fetch all absences
  Future<void> fetchAllAbsences() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/absences');
      if (response.statusCode == 200) {
        _absences = (response.data as List)
            .map((e) => Absence.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching absences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tech: fetch my absences
  Future<void> fetchMyAbsences() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/absences/me');
      if (response.statusCode == 200) {
        _myAbsences = (response.data as List)
            .map((e) => Absence.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching my absences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tech: create absence request
  Future<void> createAbsence(String dateDebut, String dateFin, String motif) async {
    try {
      await _apiClient.dio.post('/absences', data: {
        'dateDebut': dateDebut,
        'dateFin': dateFin,
        'motif': motif,
      });
      await fetchMyAbsences();
    } catch (e) {
      print('Error creating absence: $e');
      rethrow;
    }
  }

  // Manager: approve/refuse
  Future<void> updateStatut(int id, String statut) async {
    try {
      await _apiClient.dio.put('/absences/$id/statut', data: {
        'statut': statut,
      });
      await fetchAllAbsences();
    } catch (e) {
      print('Error updating absence status: $e');
      rethrow;
    }
  }
}
