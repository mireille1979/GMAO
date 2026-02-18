import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/users');
      if (response.statusCode == 200) {
        _users = (response.data as List)
            .map((e) => User.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> validateUser(int id) async {
    try {
      final response = await _apiClient.dio.patch('/users/$id/validate');
      if (response.statusCode == 200) {
        // Update local list
        final index = _users.indexWhere((u) => u.id == id);
        if (index != -1) {
          // Re-fetch or manually update? Manually update is faster
          // Ideally backend returns updated user
          _users[index] = User.fromJson(response.data);
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      print('Error validating user: $e');
    }
    return false;
  }

  Future<bool> deleteUser(int id) async {
    try {
      final response = await _apiClient.dio.delete('/users/$id');
      if (response.statusCode == 204) {
        _users.removeWhere((u) => u.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
    return false;
  }
  List<User> _technicians = [];
  List<User> get technicians => _technicians;

  Future<void> fetchTechnicians() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/users/technicians');
      if (response.statusCode == 200) {
        _technicians = (response.data as List)
            .map((e) => User.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching technicians: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
