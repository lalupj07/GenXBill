import 'package:hive/hive.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_theme.dart';

/// Repository for managing invoice themes
class InvoiceThemeRepository {
  static const String _boxName = 'invoice_themes';

  Box<InvoiceTheme> get _box => Hive.box<InvoiceTheme>(_boxName);

  /// Get all themes
  List<InvoiceTheme> getAllThemes() {
    return _box.values.toList();
  }

  /// Get theme by ID
  InvoiceTheme? getThemeById(String id) {
    return _box.values.firstWhere(
      (theme) => theme.id == id,
      orElse: () => InvoiceTheme.predefinedThemes.first,
    );
  }

  /// Get active theme (first one or default)
  InvoiceTheme getActiveTheme() {
    if (_box.isEmpty) {
      // Initialize with predefined themes
      initializePredefinedThemes();
    }
    return _box.values.firstOrNull ?? InvoiceTheme.predefinedThemes.first;
  }

  /// Save theme
  Future<void> saveTheme(InvoiceTheme theme) async {
    await _box.put(theme.id, theme);
  }

  /// Delete theme
  Future<void> deleteTheme(String id) async {
    await _box.delete(id);
  }

  /// Set active theme (move to first position)
  Future<void> setActiveTheme(String themeId) async {
    final theme = getThemeById(themeId);
    if (theme != null) {
      // Remove and re-add to make it first
      await _box.delete(themeId);
      await _box.put(themeId, theme);
    }
  }

  /// Initialize with predefined themes
  Future<void> initializePredefinedThemes() async {
    if (_box.isEmpty) {
      for (var theme in InvoiceTheme.predefinedThemes) {
        await _box.put(theme.id, theme);
      }
    }
  }

  /// Clear all themes
  Future<void> clearAll() async {
    await _box.clear();
  }
}
