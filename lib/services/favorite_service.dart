// lib/services/favorite_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/meal.dart';
import 'auth_service.dart';

class FavoriteService {
  static const String _boxNamePrefix = 'favorites_';

  static Future<Box<Meal>> _getBox() async {
    final currentUser = await AuthService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    final boxName = '$_boxNamePrefix$currentUser';
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Meal>(boxName);
    }
    return Hive.box<Meal>(boxName);
  }

  /// Tambahkan ke favorit
  static Future<void> addFavorite(Meal meal) async {
    final box = await _getBox();
    await box.put(meal.idMeal, meal);
  }

  /// Hapus dari favorit
  static Future<void> removeFavorite(String idMeal) async {
    final box = await _getBox();
    await box.delete(idMeal);
  }

  /// Cek apakah sudah difavoritkan
  static Future<bool> isFavorite(String idMeal) async {
    final box = await _getBox();
    return box.containsKey(idMeal);
  }

  /// Ambil semua favorit
  static Future<List<Meal>> getAllFavorites() async {
    final box = await _getBox();
    return box.values.toList();
  }

  /// Toggle favorit
  static Future<bool> toggleFavorite(Meal meal) async {
    final isFav = await isFavorite(meal.idMeal);
    if (isFav) {
      await removeFavorite(meal.idMeal);
      return false;
    } else {
      await addFavorite(meal);
      return true;
    }
  }
}
