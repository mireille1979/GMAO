import 'dart:async';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/globals.dart';
import '../models/intervention.dart';
import '../models/batiment.dart';
import '../models/equipement.dart';
import '../models/user.dart';
import '../models/dashboard_stats.dart';

import '../models/checklist.dart';

class InterventionProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<Intervention> _interventions = [];
  List<Batiment> _batiments = [];
  List<Equipement> _equipements = [];
  List<User> _technicians = [];
  
  bool _isLoading = false;

  List<Intervention> get interventions => _interventions;
  List<Batiment> get batiments => _batiments;
  List<Equipement> get equipements => _equipements;
  List<User> get technicians => _technicians;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? _errorMessage;

  Future<void> fetchInterventions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/interventions');
      if (response.statusCode == 200) {
        _interventions = (response.data as List)
            .map((e) => Intervention.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching interventions: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAuxData() async {
    _errorMessage = null;
    notifyListeners();
    try {
      final batResponse = await _apiClient.dio.get('/batiments');
      if (batResponse.statusCode == 200) {
        _batiments = (batResponse.data as List)
            .map((e) => Batiment.fromJson(e))
            .toList();
      }

      final equipResponse = await _apiClient.dio.get('/equipements');
      if (equipResponse.statusCode == 200) {
        _equipements = (equipResponse.data as List)
            .map((e) => Equipement.fromJson(e))
            .toList();
      }

      final techResponse = await _apiClient.dio.get('/users/technicians');
      if (techResponse.statusCode == 200) {
        _technicians = (techResponse.data as List)
            .map((e) => User.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching aux data: $e');
      _errorMessage = 'Erreur chargement données: $e';
    }
    notifyListeners();
  }

  Future<bool> createIntervention(Intervention intervention) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post('/interventions', data: {
        'titre': intervention.titre,
        'description': intervention.description,
        'priorite': intervention.priorite.toString().split('.').last,
        'statut': intervention.statut.toString().split('.').last,
        'datePrevue': intervention.datePrevue?.toIso8601String(),
        'batiment': intervention.batiment != null ? {'id': intervention.batiment!.id} : null,
        'equipement': intervention.equipement != null ? {'id': intervention.equipement!.id} : null,
        'technicien': intervention.technicien != null ? {'id': intervention.technicien!.id} : null,
        'manager': intervention.manager != null ? {'id': intervention.manager!.id} : null,
        'checklist': intervention.checklist?.map((e) => e.toJson()).toList(),
      });

      if (response.statusCode == 200) {
        _interventions.add(Intervention.fromJson(response.data));
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error creating intervention: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchTechnicianInterventions(int techId) async {
    _isLoading = true;
    notifyListeners();
    print('DEBUG: fetchTechnicianInterventions called for techId: $techId');
    try {
      final response = await _apiClient.dio.get('/interventions/technicien/$techId');
      print('DEBUG: fetchTechnicianInterventions status: ${response.statusCode}');
      print('DEBUG: fetchTechnicianInterventions data: ${response.data}');
      
      if (response.statusCode == 200) {
        final List data = response.data as List;
        print('DEBUG: Found ${data.length} interventions');
        _interventions = data
            .map((e) => Intervention.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching tech interventions: $e');
      _errorMessage = 'Erreur récupération interventions: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> startIntervention(int interventionId) async {
    try {
      final response = await _apiClient.dio.patch('/interventions/$interventionId/demarrer');
      if (response.statusCode == 200) {
        final index = _interventions.indexWhere((i) => i.id == interventionId);
        if (index != -1) {
          _interventions[index] = Intervention.fromJson(response.data);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error starting intervention: $e');
      rethrow;
    }
  }

  Future<void> addChecklistItem(int interventionId, String description) async {
    try {
      final response = await _apiClient.dio.post(
        '/interventions/$interventionId/checklist',
        data: {'description': description},
      );
      if (response.statusCode == 200) {
        final index = _interventions.indexWhere((i) => i.id == interventionId);
        if (index != -1) {
           await fetchTechnicianInterventions(_interventions[index].technicien?.id ?? 0); 
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error adding checklist item: $e');
    }
  }

  Future<bool> toggleChecklistItem(int itemId, int interventionId) async {
    try {
      final response = await _apiClient.dio.patch('/interventions/checklist/$itemId');
      if (response.statusCode == 200) {
         final index = _interventions.indexWhere((i) => i.id == interventionId);
         if (index != -1) {
            // Refresh to get updated state
            await fetchTechnicianInterventions(_interventions[index].technicien?.id ?? 0);
         }
         return true;
      }
    } catch (e) {
      print('Error toggling checklist item: $e');
    }
    return false;
  }

  DashboardStats? _dashboardStats;
  DashboardStats? get dashboardStats => _dashboardStats;

  Future<void> fetchDashboardStats() async {
    try {
      final response = await _apiClient.dio.get('/stats/kpis');
      if (response.statusCode == 200) {
        _dashboardStats = DashboardStats.fromJson(response.data);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching dashboard stats: $e');
    }
  }

  Future<void> finishIntervention(int interventionId, String report, double? cout) async {
    try {
      final response = await _apiClient.dio.patch(
        '/interventions/$interventionId/cloturer',
        data: {
          'compteRendu': report,
          'cout': cout
        },
      );
      if (response.statusCode == 200) {
         final index = _interventions.indexWhere((i) => i.id == interventionId);
        if (index != -1) {
          _interventions[index] = Intervention.fromJson(response.data);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error finishing intervention: $e');
      rethrow;
    }
  }
  
  Future<List<Intervention>> fetchInterventionsByEquipement(int equipementId) async {
    try {
      final response = await _apiClient.dio.get('/interventions', queryParameters: {'equipementId': equipementId});
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => Intervention.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching equipment history: $e');
      return [];
    }
  }

  Future<List<Intervention>> fetchInterventionsByDateRange(DateTime start, DateTime end, {int? techId}) async {
    try {
      final queryParams = {
        'start': start.toIso8601String().split('.')[0], // Remove microseconds
        'end': end.toIso8601String().split('.')[0],
      };
      if (techId != null) {
        queryParams['technicienId'] = techId.toString();
      }

      final response = await _apiClient.dio.get(
        '/interventions/planning',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => Intervention.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching planning: $e');
      return [];
    }
  }

  Timer? _pollingTimer;
  Set<int> _knownInterventionIds = {};

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void startPolling({int? techId}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _pollInterventions(techId);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> _pollInterventions(int? techId) async {
    try {
      List<Intervention> fetched = [];
      if (techId != null) {
        final response = await _apiClient.dio.get('/interventions/technicien/$techId');
        if (response.statusCode == 200) {
          fetched = (response.data as List).map((e) => Intervention.fromJson(e)).toList();
        }
      } else {
        final response = await _apiClient.dio.get('/interventions');
        if (response.statusCode == 200) {
          fetched = (response.data as List).map((e) => Intervention.fromJson(e)).toList();
        }
        // Also fetch stats for manager
        await fetchDashboardStats();
      }

      if (fetched.isNotEmpty) {
        bool hasNew = false;
        // Initialize known IDs if empty (first run)
        if (_knownInterventionIds.isEmpty) {
           _knownInterventionIds = fetched.map((i) => i.id).toSet();
        } else {
           for (var i in fetched) {
             if (!_knownInterventionIds.contains(i.id)) {
               hasNew = true;
               break;
             }
           }
           _knownInterventionIds = fetched.map((i) => i.id).toSet();
        }

        _interventions = fetched;
        notifyListeners();

        if (hasNew) {
           scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text("Nouvelles interventions disponibles !"),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Polling error: $e');
    }
  }
}
