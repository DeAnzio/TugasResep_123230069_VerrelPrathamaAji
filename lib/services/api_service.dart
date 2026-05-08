// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Ambil daftar resep berdasarkan karakter pertama nama (a-z)
  /// Digunakan untuk menampilkan banyak resep di Home
  static Future<List<Meal>> fetchMealsByLetter(String letter) async {
    final url = Uri.parse('$_baseUrl/search.php?f=$letter');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'];
      if (meals == null) return [];
      return (meals as List).map((m) => Meal.fromDetailJson(m)).toList();
    } else {
      throw Exception('Gagal memuat resep: ${response.statusCode}');
    }
  }

  /// Ambil daftar resep berdasarkan kategori
  static Future<List<Meal>> fetchMealsByCategory(String category) async {
    final url = Uri.parse('$_baseUrl/filter.php?c=$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'];
      if (meals == null) return [];
      return (meals as List).map((m) => Meal.fromListJson(m)).toList();
    } else {
      throw Exception('Gagal memuat resep: ${response.statusCode}');
    }
  }

  /// Ambil detail resep berdasarkan ID
  static Future<Meal?> fetchMealById(String id) async {
    final url = Uri.parse('$_baseUrl/lookup.php?i=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'];
      if (meals == null || meals.isEmpty) return null;
      return Meal.fromDetailJson(meals[0]);
    } else {
      throw Exception('Gagal memuat detail resep: ${response.statusCode}');
    }
  }

  /// Ambil semua kategori
  static Future<List<String>> fetchCategories() async {
    final url = Uri.parse('$_baseUrl/categories.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final categories = data['categories'] as List;
      return categories
          .map((c) => c['strCategory'].toString())
          .toList();
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }
}
