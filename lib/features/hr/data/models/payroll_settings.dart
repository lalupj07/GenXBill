import 'package:hive/hive.dart';

part 'payroll_settings.g.dart';

@HiveType(typeId: 55)
class PayrollSettings {
  @HiveField(0)
  final double pfPercentage;

  @HiveField(1)
  final double esiPercentage;

  @HiveField(2)
  final double tdsPercentage; // Tax Deduction at Source

  @HiveField(3)
  final double professionalTax;

  @HiveField(4)
  final bool enablePF;

  @HiveField(5)
  final bool enableESI;

  // Bank Details
  @HiveField(6)
  final String? bankName;

  @HiveField(7)
  final String? accountNumber;

  @HiveField(8)
  final String? ifscCode;

  PayrollSettings({
    this.pfPercentage = 12.0,
    this.esiPercentage = 0.75,
    this.tdsPercentage = 0.0,
    this.professionalTax = 0.0,
    this.enablePF = false,
    this.enableESI = false,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
  });

  PayrollSettings copyWith({
    double? pfPercentage,
    double? esiPercentage,
    double? tdsPercentage,
    double? professionalTax,
    bool? enablePF,
    bool? enableESI,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
  }) {
    return PayrollSettings(
      pfPercentage: pfPercentage ?? this.pfPercentage,
      esiPercentage: esiPercentage ?? this.esiPercentage,
      tdsPercentage: tdsPercentage ?? this.tdsPercentage,
      professionalTax: professionalTax ?? this.professionalTax,
      enablePF: enablePF ?? this.enablePF,
      enableESI: enableESI ?? this.enableESI,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
    );
  }
}
