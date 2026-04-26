import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/event_model.dart';
import 'mongodb_service.dart';

class ApiService {
  static const String baseUrl = 'https://eco-sevaks-backend.onrender.com/api';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      _headers['cookie'] = (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    // Clear stale cookies before login
    _headers.remove('cookie');
    _headers.remove('Cookie');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        updateCookie(response);
        final dynamic data = jsonDecode(response.body);
        
        // Handle both {"user": {...}} and direct user object
        if (data is Map<String, dynamic>) {
          if (data.containsKey('user')) {
            return data['user'] as Map<String, dynamic>;
          }
          return data;
        }
        throw Exception('Invalid response format from server');
      } else {
        // Robust error handling for non-JSON responses
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Login failed (${response.statusCode})');
        } catch (_) {
          throw Exception('Login failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection error: $e');
    }
  }

  Future<void> register(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Registration failed');
    }
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return AppUser.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error getting current user: $e');
    }
    return null;
  }

  Future<void> logout() async {
    await http.post(Uri.parse('$baseUrl/auth/logout'), headers: _headers);
    _headers.remove('cookie');
  }

  Future<List<AppEvent>> getAllEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events'), headers: _headers);
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => AppEvent.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching events from API: $e');
      return [];
    }
  }

  Future<AppEvent?> getEventById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events/$id'), headers: _headers);
      if (response.statusCode == 200) {
        return AppEvent.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching event $id from API: $e');
    }
    return null;
  }

  Future<void> joinEvent(String eventId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events/$eventId/join'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to join event');
    }
  }

  Future<void> leaveEvent(String eventId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/events/$eventId/leave'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to leave event');
    }
  }

  Future<List<AppEvent>> getJoinedEvents(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/events/user/$userId/joined'), headers: _headers);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => AppEvent.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<AppEvent>> getCreatedEvents(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/events/created/$userId'), headers: _headers);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => AppEvent.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> deleteEvent(String eventId) async {
    final response = await http.delete(Uri.parse('$baseUrl/events/$eventId'), headers: _headers);
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to delete event');
    }
  }

  Future<void> createEvent(Map<String, dynamic> eventData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: _headers,
      body: jsonEncode(eventData),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to create event');
    }
  }

  Future<List<AppEvent>> getPendingEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events/pending'), headers: _headers);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => AppEvent.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<AppEvent>> getRestrictedEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events/restricted'), headers: _headers);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => AppEvent.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> handleApproval(String eventId, bool isApproved) async {
    final endpoint = isApproved ? 'approve' : 'reject';
    final response = await http.put(Uri.parse('$baseUrl/events/$eventId/$endpoint'), headers: _headers);
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update event status');
    }
  }

  Future<void> restrictEvent(String eventId, bool isRestricted, String reason) async {
    final response = await http.put(
      Uri.parse('$baseUrl/events/$eventId/restrict'),
      headers: _headers,
      body: jsonEncode({'isRestricted': isRestricted, 'reason': reason}),
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to restrict event');
    }
  }
}
