import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager extends ChangeNotifier {
  FavoritesManager(this._prefs);

  static const _kFavoritePostIds = 'favorite_post_ids';

  final SharedPreferences _prefs;

  Set<String> get favoritePostIds => (_prefs.getStringList(_kFavoritePostIds) ?? const []).toSet();

  Future<void> addFavorite(int postId) => _save(favoritePostIds..add(postId.toString()));

  Future<void> removeFavorite(int postId) => _save(favoritePostIds..remove(postId.toString()));

  bool isFavorite(int postId) => favoritePostIds.contains(postId.toString());

  Future<void> _save(Set<String> ids) async {
    await _prefs.setStringList(_kFavoritePostIds, ids.toList());
    notifyListeners();
  }
}
