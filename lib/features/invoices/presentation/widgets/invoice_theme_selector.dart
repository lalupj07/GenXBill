import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_theme.dart';
import 'package:genx_bill/features/invoices/presentation/providers/invoice_theme_provider.dart';

class InvoiceThemeSelector extends ConsumerWidget {
  const InvoiceThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final allThemes = ref.watch(allThemesProvider);

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.palette, color: AppTheme.primaryColor, size: 28),
              SizedBox(width: 12),
              Text(
                'Invoice Themes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a professional theme for your invoices',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Theme Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: allThemes.length,
            itemBuilder: (context, index) {
              final theme = allThemes[index];
              final isSelected = theme.id == currentTheme.id;

              return _ThemeCard(
                theme: theme,
                isSelected: isSelected,
                onTap: () {
                  ref.read(themeNotifierProvider.notifier).setTheme(theme);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Theme changed to ${theme.name}'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 24),

          // Current Theme Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Theme',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentTheme.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final InvoiceTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Theme Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getThemeColor().withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getThemeIcon(),
                color: _getThemeColor(),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),

            // Theme Name
            Text(
              theme.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            // Selected Indicator
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getThemeColor() {
    switch (theme.style) {
      case InvoiceTemplateStyle.modern:
        return Colors.blue;
      case InvoiceTemplateStyle.classic:
        return Colors.brown;
      case InvoiceTemplateStyle.minimal:
        return Colors.grey;
      case InvoiceTemplateStyle.corporate:
        return Colors.indigo;
      case InvoiceTemplateStyle.colorful:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  IconData _getThemeIcon() {
    switch (theme.style) {
      case InvoiceTemplateStyle.modern:
        return Icons.auto_awesome;
      case InvoiceTemplateStyle.classic:
        return Icons.business_center;
      case InvoiceTemplateStyle.minimal:
        return Icons.minimize;
      case InvoiceTemplateStyle.corporate:
        return Icons.corporate_fare;
      case InvoiceTemplateStyle.colorful:
        return Icons.color_lens;
      default:
        return Icons.description;
    }
  }
}
