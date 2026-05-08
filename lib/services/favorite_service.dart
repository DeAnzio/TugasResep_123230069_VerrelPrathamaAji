// lib/services/favorite_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/meal.dart';

class FavoriteService {
  static const String _boxName = 'favorites';

  static Box<Meal> get _box => Hive.box<Meal>(_boxName);

  /// Tambahkan ke favorit
  static Future<void> addFavorite(Meal meal) async {
    await _box.put(meal.idMeal, meal);
  }

  /// Hapus dari favorit
  static Future<void> removeFavorite(String idMeal) async {
    await _box.delete(idMeal);
  }

  /// Cek apakah sudah difavoritkan
  static bool isFavorite(String idMeal) {
    return _box.containsKey(idMeal);
  }

  /// Ambil semua favorit
  static List<Meal> getAllFavorites() {
    return _box.values.toList();
  }

  /// Toggle favorit
  static Future<bool> toggleFavorite(Meal meal) async {
    if (isFavorite(meal.idMeal)) {
      await removeFavorite(meal.idMeal);
      return false;
    } else {
      await addFavorite(meal);
      return true;
    }
  }
}
