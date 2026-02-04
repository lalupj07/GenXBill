import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:genx_bill/features/invoices/presentation/pages/invoices_page.dart';
import 'package:genx_bill/features/clients/presentation/pages/clients_page.dart';
import 'package:genx_bill/features/expenses/presentation/pages/expenses_page.dart';
import 'package:genx_bill/features/settings/presentation/pages/settings_page.dart';
import 'package:genx_bill/features/reports/presentation/pages/reports_page.dart';
import 'package:genx_bill/features/products/presentation/pages/products_page.dart';
import 'package:genx_bill/features/employees/presentation/pages/employees_page.dart';
import 'package:genx_bill/features/hr/presentation/pages/hr_dashboard_page.dart';
import 'package:genx_bill/features/inventory/presentation/pages/inventory_dashboard_page.dart';

final navigationProvider = StateProvider<int>((ref) => 0);

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    final pages = [
      const DashboardPage(),
      const InvoicesPage(),
      const ClientsPage(),
      const ProductsPage(),
      const EmployeesPage(),
      const HRDashboardPage(),
      const InventoryDashboardPage(),
      const ExpensesPage(),
      const ReportsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: ThemeBackground(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  NavigationRail(
                    backgroundColor: Colors.transparent,
                    selectedIndex: currentIndex,
                    onDestinationSelected: (index) {
                      ref.read(navigationProvider.notifier).state = index;
                    },
                    labelType: NavigationRailLabelType.all,
                    leading: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                      child: const CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        radius: 20,
                        child: Icon(Icons.flash_on, color: Colors.white),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .scaleXY(
                              end: 1.1,
                              duration: 1000.ms,
                              curve: Curves.easeInOut)
                          .shimmer(
                              delay: 500.ms,
                              duration: 1500.ms,
                              color: Colors.white54)
                          .elevation(end: 8),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.receipt_long_outlined),
                        selectedIcon: Icon(Icons.receipt_long),
                        label: Text('Invoices'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.people_outline),
                        selectedIcon: Icon(Icons.people),
                        label: Text('Customers'),
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
                        icon: Icon(Icons.inventory_2_outlined),
                        selectedIcon: Icon(Icons.inventory_2),
                        label: Text('Inventory'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.account_balance_wallet_outlined),
                        selectedIcon: Icon(Icons.account_balance_wallet),
                        label: Text('Expenses'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.analytics_outlined),
                        selectedIcon: Icon(Icons.analytics),
                        label: Text('Reports'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: Text('Settings'),
                      ),
                    ],
                  ),
                  const VerticalDivider(
                      thickness: 1, width: 1, color: Colors.white10),
                  Expanded(
                    child: pages[currentIndex],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
