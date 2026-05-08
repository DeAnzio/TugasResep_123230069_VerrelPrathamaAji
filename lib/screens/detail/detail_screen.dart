// lib/screens/detail/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/meal.dart';
import '../../services/api_service.dart';
import '../../services/favorite_service.dart';
import '../../theme.dart';

class DetailScreen extends StatefulWidget {
  final String mealId;

  const DetailScreen({super.key, required this.mealId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Meal? _meal;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final meal = await ApiService.fetchMealById(widget.mealId);
      if (mounted) {
        final isFav = meal != null
            ? await FavoriteService.isFavorite(meal.idMeal)
            : false;
        setState(() {
          _meal = meal;
          _isLoading = false;
          _isFavorite = isFav;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat detail resep.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_meal == null) return;
    final result = await FavoriteService.toggleFavorite(_meal!);
    setState(() => _isFavorite = result);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? '${_meal!.strMeal} ditambahkan ke favorit ❤️'
                : '${_meal!.strMeal} dihapus dari favorit',
          ),
          backgroundColor:
              result ? AppTheme.primary : AppTheme.textSecondary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: 16),
            Text('Memuat detail resep...',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    if (_error != null || _meal == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Resep tidak ditemukan',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _fetchDetail, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    final meal = _meal!;

    return CustomScrollView(
      slivers: [
        // App bar with image
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppTheme.surface,
          foregroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: Colors.white),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: _toggleFavorite,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(_isFavorite),
                      color: _isFavorite ? Colors.red : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl: meal.strMealThumb,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(
                color: AppTheme.primaryLight,
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              ),
              errorWidget: (ctx, url, err) => Container(
                color: AppTheme.primaryLight,
                child: const Icon(Icons.restaurant,
                    color: AppTheme.primary, size: 64),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Meta
              Container(
                color: AppTheme.surface,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.strMeal,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (meal.strCategory != null) ...[
                          _MetaChip(
                            icon: Icons.category_outlined,
                            label: meal.strCategory!,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (meal.strArea != null)
                          _MetaChip(
                            icon: Icons.place_outlined,
                            label: meal.strArea!,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Favorite button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                        ),
                        label: Text(
                          _isFavorite
                              ? 'Hapus dari Favorit'
                              : 'Tambah ke Favorit',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFavorite
                              ? Colors.red.shade400
                              : AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Ingredients
              if (meal.ingredients.isNotEmpty) ...[
                Container(
                  color: AppTheme.surface,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle(
                          icon: Icons.shopping_basket_outlined,
                          title: 'Bahan-Bahan'),
                      const SizedBox(height: 14),
                      ...List.generate(meal.ingredients.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  meal.ingredients[i],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                meal.measures.length > i
                                    ? meal.measures[i]
                                    : '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Instructions
              if (meal.strInstructions != null &&
                  meal.strInstructions!.isNotEmpty) ...[
                Container(
                  color: AppTheme.surface,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle(
                          icon: Icons.menu_book_outlined,
                          title: 'Cara Memasak'),
                      const SizedBox(height: 14),
                      Text(
                        meal.strInstructions!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
