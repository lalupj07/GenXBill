import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_theme.dart';
import 'package:genx_bill/features/invoices/data/repositories/invoice_theme_repository.dart';

/// Repository provider
final invoiceThemeRepositoryProvider = Provider<InvoiceThemeRepository>((ref) {
  return InvoiceThemeRepository();
});

/// All themes provider
final allThemesProvider = Provider<List<InvoiceTheme>>((ref) {
  final repository = ref.watch(invoiceThemeRepositoryProvider);
  return repository.getAllThemes();
});

/// Active theme provider
final activeThemeProvider = StateProvider<InvoiceTheme>((ref) {
  final repository = ref.watch(invoiceThemeRepositoryProvider);
  return repository.getActiveTheme();
});

/// Theme selection notifier
class ThemeNotifier extends StateNotifier<InvoiceTheme> {
  final InvoiceThemeRepository _repository;

  ThemeNotifier(this._repository) : super(_repository.getActiveTheme());

  Future<void> setTheme(InvoiceTheme theme) async {
    await _repository.setActiveTheme(theme.id);
    state = theme;
  }

  Future<void> saveCustomTheme(InvoiceTheme theme) async {
    await _repository.saveTheme(theme);
    state = theme;
  }

  Future<void> deleteTheme(String id) async {
    await _repository.deleteTheme(id);
    // Reset to first available theme
    state = _repository.getActiveTheme();
  }

  void refresh() {
    state = _repository.getActiveTheme();
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, InvoiceTheme>((ref) {
  final repository = ref.watch(invoiceThemeRepositoryProvider);
  return ThemeNotifier(repository);
});
