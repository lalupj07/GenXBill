import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:genx_bill/features/invoices/presentation/pages/invoices_page.dart';
import 'package:genx_bill/features/clients/presentation/pages/clients_page.dart';
import 'package:genx_bill/features/orders/presentation/pages/orders_page.dart';
import 'package:genx_bill/features/products/presentation/pages/products_page.dart';
import 'package:genx_bill/features/hr/presentation/pages/employees_page.dart';
import 'package:genx_bill/features/hr/presentation/pages/hr_dashboard_page.dart';
import 'package:genx_bill/features/inventory/presentation/pages/inventory_dashboard_page.dart';
import 'package:genx_bill/features/expenses/presentation/pages/expenses_page.dart';
import 'package:genx_bill/features/reports/presentation/pages/reports_page.dart';
import 'package:genx_bill/features/analytics/presentation/pages/analytics_dashboard_page.dart';
import 'package:genx_bill/features/settings/presentation/pages/settings_page.dart';
import 'package:genx_bill/core/providers/navigation_provider.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'dart:io';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final settings = ref.watch(settingsProvider);

    final pages = [
      const DashboardPage(),
      const InvoicesPage(),
      const ClientsPage(),
      const OrdersPage(),
      const ProductsPage(),
      const EmployeesPage(),
      const HRDashboardPage(),
      const InventoryDashboardPage(),
      const ExpensesPage(),
      const ReportsPage(),
      const AnalyticsDashboardPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: ThemeBackground(
        child: Row(
          children: [
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: NavigationRail(
                    backgroundColor: Colors.transparent,
                    selectedIndex: currentIndex,
                    onDestinationSelected: (index) {
                      ref.read(navigationProvider.notifier).state = index;
                    },
                    labelType: NavigationRailLabelType.all,
                    leading: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            image: settings.companyLogo != null &&
                                    settings.companyLogo!.isNotEmpty
                                ? DecorationImage(
                                    image:
                                        FileImage(File(settings.companyLogo!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: settings.companyLogo == null ||
                                  settings.companyLogo!.isEmpty
                              ? const Icon(
                                  Icons.bolt,
                                  color: AppTheme.primaryColor,
                                )
                              : null,
                        ).animate().scale(delay: 200.ms),
                        const SizedBox(height: 24),
                      ],
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.grid_view_outlined),
                        selectedIcon: Icon(Icons.grid_view_rounded),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.description_outlined),
                        selectedIcon: Icon(Icons.description),
                        label: Text('Invoices'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.people_outline),
                        selectedIcon: Icon(Icons.people),
                        label: Text('Customers'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.shopping_cart_outlined),
                        selectedIcon: Icon(Icons.shopping_cart),
                        label: Text('Orders'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.inventory_2_outlined),
                        selectedIcon: Icon(Icons.inventory_2),
                        label: Text('Products'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.badge_outlined),
                        selectedIcon: Icon(Icons.badge),
                        label: Text('Employees'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.calendar_month_outlined),
                        selectedIcon: Icon(Icons.calendar_month),
                        label: Text('HR & Attendance'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.inventory_outlined),
                        selectedIcon: Icon(Icons.inventory),
                        label: Text('Inventory'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.receipt_long_outlined),
                        selectedIcon: Icon(Icons.receipt_long),
                        label: Text('Expenses'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.assessment_outlined),
                        selectedIcon: Icon(Icons.assessment),
                        label: Text('Reports'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.analytics_outlined),
                        selectedIcon: Icon(Icons.analytics),
                        label: Text('Analytics'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: Text('Settings'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: pages[currentIndex],
            ),
          ],
        ),
      ),
    );
  }
}
