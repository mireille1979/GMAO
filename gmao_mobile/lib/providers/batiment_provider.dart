import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/batiment.dart';
import '../models/zone.dart';
import '../models/batiment_maintenance_stats.dart';

class BatimentProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Batiment> _batiments = [];
  bool _isLoading = false;

  List<Batiment> get batiments => _batiments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? _errorMessage;

  Future<void> fetchBatiments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/batiments');
      print('DEBUG: FetchBatiments response: ${response.statusCode}');
      if (response.statusCode == 200) {
        _batiments = (response.data as List)
            .map((e) => Batiment.fromJson(e))
            .toList();
        print('DEBUG: Loaded ${_batiments.length} batiments');
      }
    } catch (e) {
      print('Error fetching batiments: $e');
      _errorMessage = 'Erreur: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBatiment(String nom, String adresse, String description) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post('/batiments', data: {
        'nom': nom,
        'adresse': adresse,
        'description': description,
      });

      if (response.statusCode == 200) {
        _batiments.add(Batiment.fromJson(response.data));
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error creating batiment: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateBatiment(int id, String nom, String adresse, String description) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.put('/batiments/$id', data: {
        'nom': nom,
        'adresse': adresse,
        'description': description,
      });

      if (response.statusCode == 200) {
        final index = _batiments.indexWhere((b) => b.id == id);
        if (index != -1) {
          _batiments[index] = Batiment.fromJson(response.data);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error updating batiment: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteBatiment(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiClient.dio.delete('/batiments/$id');
      _batiments.removeWhere((b) => b.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting batiment: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // --- ZONES ---

  List<Zone> _zones = [];
  List<Zone> get zones => _zones;

  Future<void> fetchZones(int batimentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/zones/batiment/$batimentId');
      if (response.statusCode == 200) {
        _zones = (response.data as List).map((e) => Zone.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching zones: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createZone(int batimentId, String nom, String type) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post('/zones/batiment/$batimentId', data: {
        'nom': nom,
        'type': type,
      });

      if (response.statusCode == 200) {
        _zones.add(Zone.fromJson(response.data));
        
        // Update local batiment zones list as well
         final index = _batiments.indexWhere((b) => b.id == batimentId);
        if (index != -1) {
           // We might need to refresh the batiment or manually add the zone to it
           // For now, let's just refresh the zones list which is what the view uses
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error creating zone: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteZone(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiClient.dio.delete('/zones/$id');
      _zones.removeWhere((z) => z.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting zone: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // --- MAINTENANCE STATS ---

  List<BatimentMaintenanceStats> _maintenanceStats = [];
  List<BatimentMaintenanceStats> get maintenanceStats => _maintenanceStats;

  Future<void> fetchMaintenanceStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/batiments/maintenance-stats');
      if (response.statusCode == 200) {
        _maintenanceStats = (response.data as List)
            .map((e) => BatimentMaintenanceStats.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching maintenance stats: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
