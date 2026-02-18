import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/equipement.dart';
import '../models/batiment.dart';

class EquipementProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Equipement> _equipements = [];
  bool _isLoading = false;

  List<Equipement> get equipements => _equipements;
  bool get isLoading => _isLoading;

  Future<void> fetchEquipementsByBatiment(int batimentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/equipements/batiment/$batimentId');
      if (response.statusCode == 200) {
        _equipements = (response.data as List)
            .map((e) => Equipement.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching equipments for batiment $batimentId: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllEquipements() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/equipements');
      if (response.statusCode == 200) {
        _equipements = (response.data as List)
            .map((e) => Equipement.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching all equipments: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createEquipement(String nom, TypeEquipement type, EtatEquipement etat, int batimentId, {int? zoneId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final Map<String, dynamic> data = {
        'nom': nom,
        'type': type.toString().split('.').last,
        'etat': etat.toString().split('.').last,
        'batiment': {'id': batimentId},
      };
      if (zoneId != null) {
        data['zone'] = {'id': zoneId};
      }

      final response = await _apiClient.dio.post('/equipements', data: data);

      if (response.statusCode == 200) {
        _equipements.add(Equipement.fromJson(response.data));
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error creating equipement: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateEquipement(int id, String nom, TypeEquipement type, EtatEquipement etat, int batimentId, {int? zoneId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final Map<String, dynamic> data = {
        'nom': nom,
        'type': type.toString().split('.').last,
        'etat': etat.toString().split('.').last,
        'batiment': {'id': batimentId},
      };
      if (zoneId != null) {
        data['zone'] = {'id': zoneId};
      } else {
        data['zone'] = null;
      }

      final response = await _apiClient.dio.put('/equipements/$id', data: data);

      if (response.statusCode == 200) {
        final index = _equipements.indexWhere((e) => e.id == id);
        if (index != -1) {
          _equipements[index] = Equipement.fromJson(response.data);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error updating equipement: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteEquipement(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiClient.dio.delete('/equipements/$id');
      _equipements.removeWhere((e) => e.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting equipement: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
