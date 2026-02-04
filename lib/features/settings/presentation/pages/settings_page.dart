import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:genx_bill/core/models/user_role.dart';
import 'package:genx_bill/core/services/logger_service.dart';
import 'package:intl/intl.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_template.dart';
import 'package:genx_bill/l10n/app_localizations.dart';

import 'package:genx_bill/core/widgets/main_layout.dart';
import 'package:genx_bill/core/services/demo_data_service.dart';
import 'package:genx_bill/features/settings/presentation/widgets/change_passcode_dialog.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        ref.read(navigationProvider.notifier).state = 0;
                      },
                      tooltip: AppLocalizations.of(context)!.dashboard,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.settings,
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Text(
                  'Configure your application preferences',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -0.1),
            const SizedBox(height: 24),
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(
                    icon: const Icon(Icons.business),
                    text: AppLocalizations.of(context)!.company),
                Tab(
                    icon: const Icon(Icons.receipt),
                    text: AppLocalizations.of(context)!.invoices),
                Tab(
                    icon: const Icon(Icons.account_balance),
                    text: AppLocalizations.of(context)!.banking),
                Tab(
                    icon: const Icon(Icons.palette),
                    text: AppLocalizations.of(context)!.appearance),
                Tab(
                    icon: const Icon(Icons.security),
                    text: AppLocalizations.of(context)!.security),
                Tab(
                    icon: const Icon(Icons.email_outlined),
                    text: AppLocalizations.of(context)!.email),
                const Tab(
                    icon: Icon(Icons.info_outline), text: 'License & About'),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CompanySettingsTab(),
                  InvoiceSettingsTab(),
                  BankingSettingsTab(),
                  AppearanceSettingsTab(),
                  SecuritySettingsTab(),
                  EmailSettingsTab(),
                  AboutSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Company Settings Tab
class CompanySettingsTab extends ConsumerStatefulWidget {
  const CompanySettingsTab({super.key});

  @override
  ConsumerState<CompanySettingsTab> createState() => _CompanySettingsTabState();
}

class _CompanySettingsTabState extends ConsumerState<CompanySettingsTab> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _taxIdController;
  late TextEditingController _taxRateController;
  late TextEditingController _logoController;
  late TextEditingController _signatureController;
  late TextEditingController _stampController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _nameController = TextEditingController(text: settings.companyName);
    _addressController = TextEditingController(text: settings.companyAddress);
    _phoneController = TextEditingController(text: settings.companyPhone);
    _emailController = TextEditingController(text: settings.companyEmail);
    _websiteController =
        TextEditingController(text: settings.companyWebsite ?? '');
    _taxIdController = TextEditingController(text: settings.taxId ?? '');
    _taxRateController = TextEditingController(
        text: (settings.taxRate * 100).toStringAsFixed(0));
    _logoController = TextEditingController(text: settings.companyLogo ?? '');
    _signatureController =
        TextEditingController(text: settings.companySignature ?? '');
    _stampController = TextEditingController(text: settings.companyStamp ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _taxIdController.dispose();
    _taxRateController.dispose();
    _logoController.dispose();
    _signatureController.dispose();
    _stampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.companyInformation,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Company Name *',
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _logoController,
              decoration: const InputDecoration(
                labelText: 'Company Logo Path (Local path or URL)',
                prefixIcon: Icon(Icons.image),
                helperText: 'Absolute path to image file (e.g. C:/logo.png)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _signatureController,
              decoration: const InputDecoration(
                labelText: 'Digital Signature Path',
                prefixIcon: Icon(Icons.gesture),
                helperText: 'Absolute path to signature image',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stampController,
              decoration: const InputDecoration(
                labelText: 'Company Stamp Path',
                prefixIcon: Icon(Icons.approval),
                helperText: 'Absolute path to stamp image',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website (Optional)',
                prefixIcon: Icon(Icons.language),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),
            const Text(
              'Tax Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _taxIdController,
              decoration: const InputDecoration(
                labelText: 'Tax ID / GST Number (Optional)',
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _taxRateController,
              decoration: const InputDecoration(
                labelText: 'Default Tax Rate (%)',
                prefixIcon: Icon(Icons.percent),
                helperText: 'Enter tax rate as percentage (e.g., 10 for 10%)',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Save Company Settings'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms),
    );
  }

  void _saveSettings() async {
    final taxRate = double.tryParse(_taxRateController.text) ?? 10.0;

    await ref.read(settingsProvider.notifier).updateCompanyInfo(
          companyName: _nameController.text,
          companyAddress: _addressController.text,
          companyPhone: _phoneController.text,
          companyEmail: _emailController.text,
          companyWebsite:
              _websiteController.text.isEmpty ? null : _websiteController.text,
          companyLogo:
              _logoController.text.isEmpty ? null : _logoController.text,
          companySignature: _signatureController.text.isEmpty
              ? null
              : _signatureController.text,
          companyStamp:
              _stampController.text.isEmpty ? null : _stampController.text,
        );

    await ref.read(settingsProvider.notifier).updateTaxSettings(
          taxId: _taxIdController.text.isEmpty ? null : _taxIdController.text,
          taxRate: taxRate / 100,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company settings saved successfully!')),
      );
    }
  }
}

// Invoice Settings Tab
class InvoiceSettingsTab extends ConsumerStatefulWidget {
  const InvoiceSettingsTab({super.key});

  @override
  ConsumerState<InvoiceSettingsTab> createState() => _InvoiceSettingsTabState();
}

class _InvoiceSettingsTabState extends ConsumerState<InvoiceSettingsTab> {
  late TextEditingController _prefixController;
  late TextEditingController _startNumberController;
  String _selectedPaymentTerms = 'Net 30';
  InvoiceTemplate _selectedTemplate = InvoiceTemplate.modern;

  final List<String> _paymentTermsOptions = [
    'Due on Receipt',
    'Net 7',
    'Net 15',
    'Net 30',
    'Net 45',
    'Net 60',
    'Net 90',
  ];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _prefixController = TextEditingController(text: settings.invoicePrefix);
    _startNumberController =
        TextEditingController(text: settings.invoiceStartNumber.toString());
    _selectedPaymentTerms = settings.defaultPaymentTerms;
    _selectedTemplate = settings.defaultTemplate;
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _startNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Numbering',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _prefixController,
              decoration: const InputDecoration(
                labelText: 'Invoice Prefix',
                prefixIcon: Icon(Icons.tag),
                helperText: 'e.g., INV-, BILL-, etc.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _startNumberController,
              decoration: const InputDecoration(
                labelText: 'Starting Number',
                prefixIcon: Icon(Icons.numbers),
                helperText: 'Next invoice will use this number',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Preview: ${_prefixController.text}${_startNumberController.text}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Payment Terms',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _selectedPaymentTerms,
              decoration: const InputDecoration(
                labelText: 'Default Payment Terms',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: _paymentTermsOptions.map((term) {
                return DropdownMenuItem(value: term, child: Text(term));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPaymentTerms = value);
                }
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'PDF Template',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<InvoiceTemplate>(
              initialValue: _selectedTemplate,
              decoration: const InputDecoration(
                labelText: 'Default Template',
                prefixIcon: Icon(Icons.description),
              ),
              items: InvoiceTemplate.values.map((template) {
                return DropdownMenuItem(
                  value: template,
                  child: Text(template.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedTemplate = value);
                }
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Save Invoice Settings'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms),
    );
  }

  void _saveSettings() async {
    final startNumber = int.tryParse(_startNumberController.text) ?? 1000;

    await ref.read(settingsProvider.notifier).updateInvoiceSettings(
          invoicePrefix: _prefixController.text,
          invoiceStartNumber: startNumber,
          defaultPaymentTerms: _selectedPaymentTerms,
          defaultTemplate: _selectedTemplate,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice settings saved successfully!')),
      );
    }
  }
}

// Banking Settings Tab
class BankingSettingsTab extends ConsumerStatefulWidget {
  const BankingSettingsTab({super.key});

  @override
  ConsumerState<BankingSettingsTab> createState() => _BankingSettingsTabState();
}

class _BankingSettingsTabState extends ConsumerState<BankingSettingsTab> {
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _routingNumberController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _bankNameController = TextEditingController(text: settings.bankName ?? '');
    _accountNumberController =
        TextEditingController(text: settings.bankAccountNumber ?? '');
    _routingNumberController =
        TextEditingController(text: settings.bankRoutingNumber ?? '');
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bank Account Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your bank details to include payment instructions on invoices',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _bankNameController,
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                prefixIcon: Icon(Icons.account_balance),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                labelText: 'Account Number',
                prefixIcon: Icon(Icons.credit_card),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _routingNumberController,
              decoration: const InputDecoration(
                labelText: 'Routing Number / IFSC Code',
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Save Banking Settings'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms),
    );
  }

  void _saveSettings() async {
    await ref.read(settingsProvider.notifier).updateBankSettings(
          bankName: _bankNameController.text.isEmpty
              ? null
              : _bankNameController.text,
          bankAccountNumber: _accountNumberController.text.isEmpty
              ? null
              : _accountNumberController.text,
          bankRoutingNumber: _routingNumberController.text.isEmpty
              ? null
              : _routingNumberController.text,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banking settings saved successfully!')),
      );
    }
  }
}

// Appearance Settings Tab
class AppearanceSettingsTab extends ConsumerWidget {
  const AppearanceSettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final List<String> currencies = [
      'INR',
      'USD',
      'EUR',
      'GBP',
      'JPY',
      'CAD',
      'AUD',
      'AED'
    ];
    final List<String> languages = [
      'English',
      'Hindi',
      'Spanish',
      'French',
      'German',
      'Chinese',
      'Japanese',
      'Russian',
      'Arabic',
      'Portuguese'
    ];

    return SingleChildScrollView(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme & Appearance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: settings.themeMode,
              decoration: const InputDecoration(
                labelText: 'Theme Mode',
                prefixIcon: Icon(Icons.brightness_medium),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'system', child: Text('System Default')),
                DropdownMenuItem(value: 'light', child: Text('Light Mode')),
                DropdownMenuItem(value: 'dark', child: Text('Dark Mode')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateAppearanceSettings(themeMode: value);
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Regional Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: settings.currency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    items: currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateAppearanceSettings(currency: value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: languages.contains(settings.language)
                        ? settings.language
                        : 'English',
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      prefixIcon: Icon(Icons.language),
                    ),
                    items: languages
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateAppearanceSettings(language: value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Accent Color'),
              subtitle: const Text('Purple (Default)'),
              trailing: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms),
    );
  }
}

// Security Settings Tab
class SecuritySettingsTab extends ConsumerWidget {
  const SecuritySettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final logsList = ref.watch(loggerServiceProvider).getLogs();

    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'App Security',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Passcode Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'App Passcode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            settings.passcode != null
                                ? 'Passcode is set (${settings.passcode!.length} digits)'
                                : 'Using default passcode (1234)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => const ChangePasscodeDialog(),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Change'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Access Control',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                initialValue: settings.currentUserRole,
                decoration: const InputDecoration(
                  labelText: 'Current Session Role',
                  prefixIcon: Icon(Icons.person_pin),
                  helperText:
                      'Switching roles restricts UI features (Simulation)',
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).updateSecuritySettings(
                          currentUserRole: value,
                        );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Activity Logs',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(loggerServiceProvider).clearLogs(),
                      icon: const Icon(Icons.delete_sweep, size: 18),
                      label: const Text('Clear Logs'),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: logsList.isEmpty
                      ? const Center(child: Text('No activity logs yet.'))
                      : ListView.separated(
                          itemCount: logsList.length,
                          separatorBuilder: (context, index) =>
                              const Divider(color: Colors.white10),
                          itemBuilder: (context, index) {
                            final log = logsList[index];
                            return ListTile(
                              leading: Icon(
                                _getLogIcon(log.action),
                                color: _getLogColor(log.action),
                                size: 20,
                              ),
                              title: Text(log.action,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              subtitle: Text(
                                '${log.details}\n${DateFormat('dd MMM yyyy, hh:mm a').format(log.timestamp)}',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  log.userRole.name,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                // --- DEMO DATA SECTION ---
                const Text(
                  'Developer Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _loadDemoData(context, ref),
                  icon: const Icon(Icons.download_for_offline),
                  label: const Text('Load Demo Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  void _loadDemoData(BuildContext context, WidgetRef ref) {
    DemoDataService(ref).populateDemoData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo Data Loaded Successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  IconData _getLogIcon(String action) {
    if (action.contains('Invoic')) return Icons.receipt;
    if (action.contains('Product')) return Icons.inventory;
    if (action.contains('Settings')) return Icons.settings;
    if (action.contains('Client')) return Icons.person;
    return Icons.info_outline;
  }

  Color _getLogColor(String action) {
    if (action.contains('Add')) return Colors.green;
    if (action.contains('Edit')) return Colors.blue;
    if (action.contains('Delete')) return Colors.redAccent;
    return Colors.white70;
  }
}

// Email Settings Tab
class EmailSettingsTab extends ConsumerStatefulWidget {
  const EmailSettingsTab({super.key});

  @override
  ConsumerState<EmailSettingsTab> createState() => _EmailSettingsTabState();
}

class _EmailSettingsTabState extends ConsumerState<EmailSettingsTab> {
  late TextEditingController _serverController;
  late TextEditingController _portController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _serverController = TextEditingController(text: settings.smtpServer ?? '');
    _portController =
        TextEditingController(text: (settings.smtpPort ?? 587).toString());
    _usernameController =
        TextEditingController(text: settings.smtpUsername ?? '');
    _passwordController =
        TextEditingController(text: settings.smtpPassword ?? '');
  }

  @override
  void dispose() {
    _serverController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveEmailSettings() async {
    final port = int.tryParse(_portController.text) ?? 587;

    final updated = ref.read(settingsProvider).copyWith(
          smtpServer:
              _serverController.text.isEmpty ? null : _serverController.text,
          smtpPort: port,
          smtpUsername: _usernameController.text.isEmpty
              ? null
              : _usernameController.text,
          smtpPassword: _passwordController.text.isEmpty
              ? null
              : _passwordController.text,
        );

    await ref.read(settingsProvider.notifier).updateSettings(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email settings saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SMTP Email Configuration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your SMTP server to send payslips and reports via email',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _serverController,
              decoration: const InputDecoration(
                labelText: 'SMTP Server',
                prefixIcon: Icon(Icons.dns),
                hintText: 'e.g., smtp.gmail.com',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'SMTP Port',
                prefixIcon: Icon(Icons.numbers),
                hintText: 'e.g., 587 or 465',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'SMTP Username / Email',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'SMTP Password / App Password',
                prefixIcon: Icon(Icons.vpn_key),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveEmailSettings,
                icon: const Icon(Icons.save),
                label: const Text('Save Email Settings'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For Gmail, use an "App Password" if you have 2FA enabled.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms),
    );
  }
}

class AboutSettingsTab extends StatelessWidget {
  const AboutSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.flash_on, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'GenXis Innovations',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                _buildAboutRow(Icons.business, 'Company', 'GenXis Innovations'),
                _buildAboutRow(
                    Icons.location_on, 'Location', 'Kottayam, Kerala, India'),
                _buildAboutRow(
                    Icons.language, 'Website', 'www.genxisinnovation.in'),
                _buildAboutRow(
                    Icons.email, 'Support', 'genxisinnovation@outlook.com'),
                const SizedBox(height: 32),
                const Text(
                  'Licensed under Apache License 2.0',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'GenXBill',
                      applicationVersion: '1.0.0',
                      applicationLegalese: 'Copyright 2025 GenXis Innovations',
                    );
                  },
                  icon: const Icon(Icons.description),
                  label: const Text('View Full Licenses'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '© 2025 GenXis Innovations. All rights reserved.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 40),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildAboutRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
