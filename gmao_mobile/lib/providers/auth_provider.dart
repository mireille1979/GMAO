import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return false;

    final token = prefs.getString('token');
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      print('DEBUG: Auto-login with token: $token');
      // Ensure specific token is used (though interceptor handles it usually)
      _apiClient.dio.options.headers['Authorization'] = 'Bearer $token';
      
      final response = await _apiClient.dio.get('/users/me');
      print('DEBUG: /users/me response: ${response.data}');
      
      if (response.statusCode == 200) {
        final userData = response.data;
        if (userData['equipe'] != null) {
           print('DEBUG: User has equipe: ${userData['equipe']}');
        } else {
           print('DEBUG: User has NO equipe in JSON');
        }

        _user = User.fromJson(userData);
        
        // Re-inject token if missing in User object (it's usually not in /users/me response)
        _user = User(
               id: _user!.id,
               email: _user!.email,
               firstName: _user!.firstName,
               lastName: _user!.lastName,
               role: _user!.role,
               isActive: _user!.isActive,
               token: token,
               poste: _user!.poste,
               equipe: _user!.equipe,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Auto-login failed: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post('/auth/authenticate', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        
        // Fetch full user profile to get equipe and other details
          // Fetch full user profile to get equipe and other details
        try {
          _apiClient.dio.options.headers['Authorization'] = 'Bearer $token';

          final profileResponse = await _apiClient.dio.get('/users/me');
          print('DEBUG: login /users/me response: ${profileResponse.data}');
          
          if (profileResponse.statusCode == 200) {
             _user = User.fromJson(profileResponse.data);
             // Ensure token is preserved in User object if not returned by /users/me
             _user = User(
               id: _user!.id,
               email: _user!.email,
               firstName: _user!.firstName,
               lastName: _user!.lastName,
               role: _user!.role,
               isActive: _user!.isActive,
               token: token,
               poste: _user!.poste,
               equipe: _user!.equipe,
             );
          } else {
             // Fallback if status != 200
             _user = User(
              id: data['id'],
              email: email,
              firstName: data['firstName'],
              lastName: data['lastName'],
              role: Role.values.firstWhere((e) => e.toString() == 'Role.${data['role']}'),
              token: token,
            );
          }
        } catch (e) {
          print('Error fetching profile after login: $e');
           // Fallback on error
           _user = User(
            id: data['id'],
            email: email,
            firstName: data['firstName'],
            lastName: data['lastName'],
            role: Role.values.firstWhere((e) => e.toString() == 'Role.${data['role']}'),
            token: token,
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required Role role,
    int? posteId,
    String? telephone,
    String? specialite,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post('/auth/register', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': role.toString().split('.').last,
        'posteId': posteId,
        'telephone': telephone,
        'specialite': specialite,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // Fetch full user profile
        try {
           _apiClient.dio.options.headers['Authorization'] = 'Bearer $token';
           final profileResponse = await _apiClient.dio.get('/users/me');
           if (profileResponse.statusCode == 200) {
             _user = User.fromJson(profileResponse.data);
              // Ensure token is preserved
             _user = User(
               id: _user!.id,
               email: _user!.email,
               firstName: _user!.firstName,
               lastName: _user!.lastName,
               role: _user!.role,
               isActive: _user!.isActive,
               token: token,
               poste: _user!.poste,
               equipe: _user!.equipe,
               telephone: _user!.telephone,
               specialite: _user!.specialite,
               disponible: _user!.disponible,
             );
           } else {
             // Fallback
             _user = User(
              id: data['id'],
              email: email,
              firstName: data['firstName'],
              lastName: data['lastName'],
              role: Role.values.firstWhere((e) => e.toString() == 'Role.${data['role']}'),
              token: token,
            );
           }
        } catch (e) {
          print('Error fetching profile after register: $e');
          _user = User(
            id: data['id'],
            email: email,
            firstName: data['firstName'],
            lastName: data['lastName'],
            role: Role.values.firstWhere((e) => e.toString() == 'Role.${data['role']}'),
            token: token,
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Registration error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post('/auth/forgot-password', data: {'email': email});
      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      print('Forgot Password error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post('/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      print('Reset Password error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword, String confirmationPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.patch('/users/me/password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmationPassword': confirmationPassword,
      });
      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      print('Change Password error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(String firstName, String lastName) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.put('/users/me', data: {
        'firstName': firstName,
        'lastName': lastName,
      });

      if (response.statusCode == 200) {
        // Update local user data
        if (_user != null) {
          _user = User(
            email: _user!.email,
            firstName: firstName,
            lastName: lastName,
            role: _user!.role,
            token: _user!.token,
          );
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Update Profile error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
