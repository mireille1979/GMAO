import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/intervention.dart';

class DemandeProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Intervention> _mesDemandes = [];
  List<Intervention> _allDemandes = [];
  bool _isLoading = false;
  String? _error;

  List<Intervention> get mesDemandes => _mesDemandes;
  List<Intervention> get allDemandes => _allDemandes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// CLIENT: Fetch my own demandes
  Future<void> fetchMesDemandes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/demandes/mes-demandes');
      if (response.statusCode == 200) {
        _mesDemandes = (response.data as List)
            .map((e) => Intervention.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des demandes: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// CLIENT: Create a new demande
  Future<bool> createDemande({
    required String titre,
    required String description,
    required String priorite,
    int? batimentId,
    int? equipementId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = <String, dynamic>{
        'titre': titre,
        'description': description,
        'priorite': priorite,
      };
      if (batimentId != null) {
        data['batiment'] = {'id': batimentId};
      }
      if (equipementId != null) {
        data['equipement'] = {'id': equipementId};
      }
      final response = await _apiClient.dio.post('/demandes', data: data);
      if (response.statusCode == 200) {
        await fetchMesDemandes();
        return true;
      }
    } catch (e) {
      _error = 'Erreur lors de la création: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// MANAGER: Fetch all demandes
  Future<void> fetchAllDemandes({bool enAttenteOnly = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get(
        '/demandes',
        queryParameters: {'enAttenteOnly': enAttenteOnly},
      );
      if (response.statusCode == 200) {
        _allDemandes = (response.data as List)
            .map((e) => Intervention.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = 'Erreur lors du chargement: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// MANAGER: Accept a demande
  Future<bool> accepterDemande(int demandeId, {int? technicienId, String? datePrevue}) async {
    try {
      final data = <String, dynamic>{};
      if (technicienId != null) data['technicienId'] = technicienId;
      if (datePrevue != null) data['datePrevue'] = datePrevue;
      final response = await _apiClient.dio.put('/demandes/$demandeId/accepter', data: data);
      if (response.statusCode == 200) {
        await fetchAllDemandes();
        return true;
      }
    } catch (e) {
      _error = 'Erreur lors de l\'acceptation: $e';
    }
    notifyListeners();
    return false;
  }

  /// MANAGER: Refuse a demande
  Future<bool> refuserDemande(int demandeId) async {
    try {
      final response = await _apiClient.dio.put('/demandes/$demandeId/refuser');
      if (response.statusCode == 200) {
        await fetchAllDemandes();
        return true;
      }
    } catch (e) {
      _error = 'Erreur lors du refus: $e';
    }
    notifyListeners();
    return false;
  }
}
