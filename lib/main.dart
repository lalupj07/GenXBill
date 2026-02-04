import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/hr/data/models/payroll_settings.dart';
import 'package:genx_bill/features/hr/data/models/employee_document.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:genx_bill/features/clients/data/models/client_model.dart';
import 'package:genx_bill/core/models/app_settings.dart';
import 'package:genx_bill/features/payments/data/models/payment_model.dart';
import 'package:genx_bill/features/expenses/data/models/expense_model.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_template.dart';
import 'package:genx_bill/features/products/data/models/product_model.dart';
import 'package:genx_bill/features/employees/data/models/employee_model.dart';

import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:genx_bill/core/models/user_role.dart';
import 'package:genx_bill/core/models/activity_log.dart';
import 'package:genx_bill/features/products/data/models/warehouse_model.dart';
import 'package:genx_bill/features/products/data/models/stock_batch_model.dart';
import 'package:genx_bill/features/hr/data/models/salary_record.dart';
import 'package:genx_bill/core/models/digital_asset.dart';
import 'package:genx_bill/features/products/data/models/inventory_transaction.dart';

// HR Module imports
import 'package:genx_bill/features/hr/data/models/employee_model.dart' as hr;
import 'package:genx_bill/features/hr/data/models/attendance_model.dart';
import 'package:genx_bill/features/hr/data/models/leave_model.dart';
import 'package:genx_bill/features/hr/data/models/overtime_model.dart';
import 'package:genx_bill/features/hr/data/models/bonus_model.dart';
import 'package:genx_bill/features/hr/data/models/holiday_model.dart';
import 'package:genx_bill/features/hr/data/models/payslip_model.dart';
import 'package:genx_bill/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:genx_bill/l10n/app_localizations.dart';
import 'package:genx_bill/core/utils/locale_utils.dart';

// Inventory Module imports
import 'package:genx_bill/features/inventory/data/models/inventory_item_model.dart';
import 'package:genx_bill/features/inventory/data/models/stock_movement_model.dart';
import 'package:genx_bill/features/inventory/data/models/reorder_suggestion_model.dart';

void main() async {
  await Hive.initFlutter();

  // Clear conflicting boxes due to typeId changes in development
  try {
    await Hive.deleteBoxFromDisk('invoices');
    await Hive.deleteBoxFromDisk('clients');
    await Hive.deleteBoxFromDisk('settings');
    await Hive.deleteBoxFromDisk('payments');
    await Hive.deleteBoxFromDisk('expenses');
    await Hive.deleteBoxFromDisk('products');
    await Hive.deleteBoxFromDisk('employees');
    await Hive.deleteBoxFromDisk('activity_logs');
    await Hive.deleteBoxFromDisk('warehouses');
    await Hive.deleteBoxFromDisk('stock_batches');
    await Hive.deleteBoxFromDisk('salary_records');
    await Hive.deleteBoxFromDisk('digital_assets');
    await Hive.deleteBoxFromDisk('attendance');
    await Hive.deleteBoxFromDisk('leaves');
    await Hive.deleteBoxFromDisk('overtime');
    await Hive.deleteBoxFromDisk('bonuses');
    await Hive.deleteBoxFromDisk('holidays');
    await Hive.deleteBoxFromDisk('inventory_items');
    await Hive.deleteBoxFromDisk('stock_movements');
    await Hive.deleteBoxFromDisk('reorder_suggestions');
    await Hive.deleteBoxFromDisk('salary_records'); // Just in case
    await Hive.deleteBoxFromDisk('digital_assets');
    await Hive.deleteBoxFromDisk('attendance');
  } catch (e) {
    // ignore: avoid_print
    print('Error clearing boxes: $e');
  }

  Hive.registerAdapter(InvoiceAdapter());
  Hive.registerAdapter(InvoiceItemAdapter());
  Hive.registerAdapter(InvoiceStatusAdapter());
  Hive.registerAdapter(ClientAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(PaymentAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(ExpenseCategoryAdapter());
  Hive.registerAdapter(InvoiceTemplateAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(UserRoleAdapter());
  Hive.registerAdapter(ActivityLogAdapter());
  Hive.registerAdapter(WarehouseAdapter());
  Hive.registerAdapter(StockBatchAdapter());
  Hive.registerAdapter(SalaryRecordAdapter());
  Hive.registerAdapter(DigitalAssetAdapter());
  Hive.registerAdapter(InventoryTransactionAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());

  // HR Module Adapters
  Hive.registerAdapter(hr.EmployeeStatusAdapter());
  Hive.registerAdapter(hr.HREmployeeAdapter());
  Hive.registerAdapter(AttendanceAdapter());
  Hive.registerAdapter(AttendanceStatusAdapter());
  Hive.registerAdapter(LeaveAdapter());
  Hive.registerAdapter(LeaveTypeAdapter());
  Hive.registerAdapter(LeaveStatusAdapter());
  Hive.registerAdapter(OvertimeAdapter());
  Hive.registerAdapter(OvertimeStatusAdapter());
  Hive.registerAdapter(BonusAdapter());
  Hive.registerAdapter(BonusTypeAdapter());
  Hive.registerAdapter(BonusStatusAdapter());
  Hive.registerAdapter(HolidayAdapter());
  Hive.registerAdapter(HolidayTypeAdapter());
  Hive.registerAdapter(PayrollSettingsAdapter());
  Hive.registerAdapter(EmployeeDocumentAdapter());
  Hive.registerAdapter(DocumentTypeAdapter());
  Hive.registerAdapter(PayslipAdapter());
  Hive.registerAdapter(PayslipStatusAdapter());

  // Inventory Module Adapters
  Hive.registerAdapter(InventoryItemAdapter());
  Hive.registerAdapter(InventoryStatusAdapter());
  Hive.registerAdapter(StockMovementAdapter());
  Hive.registerAdapter(MovementTypeAdapter());
  Hive.registerAdapter(ReorderSuggestionAdapter());
  Hive.registerAdapter(SuggestionPriorityAdapter());
  Hive.registerAdapter(ReorderStatusAdapter());

  await Hive.openBox<Invoice>('invoices');
  await Hive.openBox<Client>('clients');
  await Hive.openBox<AppSettings>('settings');
  await Hive.openBox<Payment>('payments');
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<Product>('products');
  await Hive.openBox<Employee>('employees');
  await Hive.openBox<ActivityLog>('activity_logs');
  await Hive.openBox<Warehouse>('warehouses');
  await Hive.openBox<StockBatch>('stock_batches');
  await Hive.openBox<SalaryRecord>('salary_records');
  await Hive.openBox<DigitalAsset>('digital_assets');
  await Hive.openBox<InventoryTransaction>('inventory_transactions');

  // HR Module Boxes
  await Hive.openBox<hr.HREmployee>('hr_employees');
  await Hive.openBox<Attendance>('attendance');
  await Hive.openBox<Leave>('leaves');
  await Hive.openBox<Overtime>('overtime');
  await Hive.openBox<Bonus>('bonuses');
  await Hive.openBox<Holiday>('holidays');
  await Hive.openBox<Payslip>('payslips');

  // Inventory Module Boxes
  await Hive.openBox<InventoryItem>('inventory_items');
  await Hive.openBox<StockMovement>('stock_movements');
  await Hive.openBox<ReorderSuggestion>('reorder_suggestions');

  runApp(const ProviderScope(child: GenXBillApp()));
}

class GenXBillApp extends ConsumerWidget {
  const GenXBillApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    ThemeMode themeMode;
    switch (settings.themeMode) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return MaterialApp(
      title: 'GenXBill',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: LocaleUtils.getLocaleFromLanguage(settings.language),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
      home: const SplashPage(),
    );
  }
}
