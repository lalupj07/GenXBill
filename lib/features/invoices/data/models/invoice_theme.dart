import 'package:hive/hive.dart';

part 'invoice_theme.g.dart';

/// Invoice theme for customizing invoice appearance
@HiveType(typeId: 80)
class InvoiceTheme extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final InvoiceTemplateStyle style;

  @HiveField(3)
  final String primaryColor; // Hex color

  @HiveField(4)
  final String secondaryColor; // Hex color

  @HiveField(5)
  final String accentColor; // Hex color

  @HiveField(6)
  final String fontFamily;

  @HiveField(7)
  final double headerFontSize;

  @HiveField(8)
  final double bodyFontSize;

  @HiveField(9)
  final bool showLogo;

  @HiveField(10)
  final bool showSignature;

  @HiveField(11)
  final bool showStamp;

  @HiveField(12)
  final bool showBorder;

  @HiveField(13)
  final String borderColor; // Hex color

  @HiveField(14)
  final double borderWidth;

  @HiveField(15)
  final bool showWatermark;

  @HiveField(16)
  final String? watermarkText;

  @HiveField(17)
  final DateTime createdAt;

  @HiveField(18)
  final bool isDefault;

  InvoiceTheme({
    required this.id,
    required this.name,
    required this.style,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.fontFamily,
    required this.headerFontSize,
    required this.bodyFontSize,
    required this.showLogo,
    required this.showSignature,
    required this.showStamp,
    required this.showBorder,
    required this.borderColor,
    required this.borderWidth,
    required this.showWatermark,
    this.watermarkText,
    required this.createdAt,
    this.isDefault = false,
  });

  InvoiceTheme copyWith({
    String? id,
    String? name,
    InvoiceTemplateStyle? style,
    String? primaryColor,
    String? secondaryColor,
    String? accentColor,
    String? fontFamily,
    double? headerFontSize,
    double? bodyFontSize,
    bool? showLogo,
    bool? showSignature,
    bool? showStamp,
    bool? showBorder,
    String? borderColor,
    double? borderWidth,
    bool? showWatermark,
    String? watermarkText,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return InvoiceTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      style: style ?? this.style,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      fontFamily: fontFamily ?? this.fontFamily,
      headerFontSize: headerFontSize ?? this.headerFontSize,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
      showLogo: showLogo ?? this.showLogo,
      showSignature: showSignature ?? this.showSignature,
      showStamp: showStamp ?? this.showStamp,
      showBorder: showBorder ?? this.showBorder,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      showWatermark: showWatermark ?? this.showWatermark,
      watermarkText: watermarkText ?? this.watermarkText,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Predefined themes
  static InvoiceTheme get modern => InvoiceTheme(
        id: 'modern',
        name: 'Modern',
        style: InvoiceTemplateStyle.modern,
        primaryColor: '#2196F3',
        secondaryColor: '#1976D2',
        accentColor: '#FFC107',
        fontFamily: 'Helvetica',
        headerFontSize: 24,
        bodyFontSize: 10,
        showLogo: true,
        showSignature: true,
        showStamp: true,
        showBorder: false,
        borderColor: '#000000',
        borderWidth: 1,
        showWatermark: false,
        createdAt: DateTime.now(),
        isDefault: true,
      );

  static InvoiceTheme get classic => InvoiceTheme(
        id: 'classic',
        name: 'Classic',
        style: InvoiceTemplateStyle.classic,
        primaryColor: '#000000',
        secondaryColor: '#424242',
        accentColor: '#757575',
        fontFamily: 'Times',
        headerFontSize: 22,
        bodyFontSize: 10,
        showLogo: true,
        showSignature: true,
        showStamp: true,
        showBorder: true,
        borderColor: '#000000',
        borderWidth: 2,
        showWatermark: false,
        createdAt: DateTime.now(),
      );

  static InvoiceTheme get minimal => InvoiceTheme(
        id: 'minimal',
        name: 'Minimal',
        style: InvoiceTemplateStyle.minimal,
        primaryColor: '#607D8B',
        secondaryColor: '#455A64',
        accentColor: '#90A4AE',
        fontFamily: 'Helvetica',
        headerFontSize: 20,
        bodyFontSize: 9,
        showLogo: true,
        showSignature: false,
        showStamp: false,
        showBorder: false,
        borderColor: '#000000',
        borderWidth: 1,
        showWatermark: false,
        createdAt: DateTime.now(),
      );

  static InvoiceTheme get corporate => InvoiceTheme(
        id: 'corporate',
        name: 'Corporate',
        style: InvoiceTemplateStyle.corporate,
        primaryColor: '#1A237E',
        secondaryColor: '#283593',
        accentColor: '#3F51B5',
        fontFamily: 'Helvetica',
        headerFontSize: 26,
        bodyFontSize: 10,
        showLogo: true,
        showSignature: true,
        showStamp: true,
        showBorder: true,
        borderColor: '#1A237E',
        borderWidth: 3,
        showWatermark: true,
        watermarkText: 'ORIGINAL',
        createdAt: DateTime.now(),
      );

  static InvoiceTheme get colorful => InvoiceTheme(
        id: 'colorful',
        name: 'Colorful',
        style: InvoiceTemplateStyle.colorful,
        primaryColor: '#E91E63',
        secondaryColor: '#9C27B0',
        accentColor: '#FF9800',
        fontFamily: 'Helvetica',
        headerFontSize: 24,
        bodyFontSize: 10,
        showLogo: true,
        showSignature: true,
        showStamp: true,
        showBorder: true,
        borderColor: '#E91E63',
        borderWidth: 2,
        showWatermark: false,
        createdAt: DateTime.now(),
      );

  static List<InvoiceTheme> get predefinedThemes => [
        modern,
        classic,
        minimal,
        corporate,
        colorful,
      ];
}

@HiveType(typeId: 81)
enum InvoiceTemplateStyle {
  @HiveField(0)
  modern,
  @HiveField(1)
  classic,
  @HiveField(2)
  minimal,
  @HiveField(3)
  corporate,
  @HiveField(4)
  colorful,
  @HiveField(5)
  custom,
}
