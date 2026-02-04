import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_settings.dart';
import '../models/user_role.dart';
import '../../features/invoices/data/models/invoice_template.dart';

final settingsBoxProvider = Provider<Box<AppSettings>>((ref) {
  return Hive.box<AppSettings>('settings');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  final box = ref.watch(settingsBoxProvider);
  return SettingsNotifier(box);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final Box<AppSettings> _box;

  SettingsNotifier(this._box) : super(_loadSettings(_box));

  static AppSettings _loadSettings(Box<AppSettings> box) {
    if (box.isEmpty) {
      final defaultSettings = AppSettings();
      box.put('app_settings', defaultSettings);
      return defaultSettings;
    }
    return box.get('app_settings')!;
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _box.put('app_settings', settings);
    state = settings;
  }

  Future<void> updateCompanyInfo({
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    String? companyWebsite,
    String? companyLogo,
    String? companySignature,
    String? companyStamp,
  }) async {
    final updated = state.copyWith(
      companyName: companyName,
      companyAddress: companyAddress,
      companyPhone: companyPhone,
      companyEmail: companyEmail,
      companyWebsite: companyWebsite,
      companyLogo: companyLogo,
      companySignature: companySignature,
      companyStamp: companyStamp,
    );
    await updateSettings(updated);
  }

  Future<void> updateTaxSettings({String? taxId, double? taxRate}) async {
    final updated = state.copyWith(
      taxId: taxId,
      taxRate: taxRate,
    );
    await updateSettings(updated);
  }

  Future<void> updateInvoiceSettings({
    String? invoicePrefix,
    int? invoiceStartNumber,
    String? defaultPaymentTerms,
    InvoiceTemplate? defaultTemplate,
    String? emailSignature,
  }) async {
    final updated = state.copyWith(
      invoicePrefix: invoicePrefix,
      invoiceStartNumber: invoiceStartNumber,
      defaultPaymentTerms: defaultPaymentTerms,
      defaultTemplate: defaultTemplate,
      emailSignature: emailSignature,
    );
    await updateSettings(updated);
  }

  Future<void> updateBankSettings({
    String? bankName,
    String? bankAccountNumber,
    String? bankRoutingNumber,
  }) async {
    final updated = state.copyWith(
      bankName: bankName,
      bankAccountNumber: bankAccountNumber,
      bankRoutingNumber: bankRoutingNumber,
    );
    await updateSettings(updated);
  }

  Future<void> updateAppearanceSettings({
    String? currency,
    String? language,
    String? themeMode,
  }) async {
    final updated = state.copyWith(
      currency: currency,
      language: language,
      themeMode: themeMode,
    );
    await updateSettings(updated);
  }

  Future<void> updateSecuritySettings({
    UserRole? currentUserRole,
    String? passcode,
  }) async {
    final updated = state.copyWith(
      currentUserRole: currentUserRole,
      passcode: passcode,
    );
    await updateSettings(updated);
  }
}
