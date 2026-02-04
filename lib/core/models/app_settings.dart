import '../../features/invoices/data/models/invoice_template.dart';
import 'user_role.dart';
import 'package:hive/hive.dart';

class AppSettings extends HiveObject {
  String companyName;
  String companyAddress;
  String companyPhone;
  String companyEmail;
  String? companyWebsite;
  String? companyLogo; // Base64 encoded image or file path
  String? taxId;
  double taxRate;
  String invoicePrefix;
  int invoiceStartNumber;
  String defaultPaymentTerms;
  String? bankName;
  String? bankAccountNumber;
  String? bankRoutingNumber;
  String currency;
  String language;
  String themeMode; // 'light', 'dark', 'system'
  String? emailSignature;
  String? companySignature; // File path for digital signature
  String? companyStamp; // File path for digital stamp
  InvoiceTemplate defaultTemplate;
  UserRole currentUserRole;
  String? passcode; // 4-digit passcode for app lock
  String? smtpServer;
  int? smtpPort;
  String? smtpUsername;
  String? smtpPassword;

  AppSettings({
    this.companyName = 'GenXis Inc',
    this.companyAddress = '',
    this.companyPhone = '',
    this.companyEmail = '',
    this.companyWebsite,
    this.companyLogo,
    this.taxId,
    this.taxRate = 0.10,
    this.invoicePrefix = 'INV-',
    this.invoiceStartNumber = 1000,
    this.defaultPaymentTerms = 'Net 30',
    this.bankName,
    this.bankAccountNumber,
    this.bankRoutingNumber,
    this.currency = 'INR',
    this.language = 'English',
    this.themeMode = 'dark',
    this.emailSignature,
    this.companySignature,
    this.companyStamp,
    this.defaultTemplate = InvoiceTemplate.modern,
    this.currentUserRole = UserRole.admin,
    this.passcode,
    this.smtpServer,
    this.smtpPort = 587,
    this.smtpUsername,
    this.smtpPassword,
  });

  AppSettings copyWith({
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    String? companyWebsite,
    String? companyLogo,
    String? taxId,
    double? taxRate,
    String? invoicePrefix,
    int? invoiceStartNumber,
    String? defaultPaymentTerms,
    String? bankName,
    String? bankAccountNumber,
    String? bankRoutingNumber,
    String? currency,
    String? language,
    String? themeMode,
    String? emailSignature,
    String? companySignature,
    String? companyStamp,
    InvoiceTemplate? defaultTemplate,
    UserRole? currentUserRole,
    String? passcode,
    String? smtpServer,
    int? smtpPort,
    String? smtpUsername,
    String? smtpPassword,
  }) {
    return AppSettings(
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      companyEmail: companyEmail ?? this.companyEmail,
      companyWebsite: companyWebsite ?? this.companyWebsite,
      companyLogo: companyLogo ?? this.companyLogo,
      taxId: taxId ?? this.taxId,
      taxRate: taxRate ?? this.taxRate,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      invoiceStartNumber: invoiceStartNumber ?? this.invoiceStartNumber,
      defaultPaymentTerms: defaultPaymentTerms ?? this.defaultPaymentTerms,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankRoutingNumber: bankRoutingNumber ?? this.bankRoutingNumber,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      emailSignature: emailSignature ?? this.emailSignature,
      companySignature: companySignature ?? this.companySignature,
      companyStamp: companyStamp ?? this.companyStamp,
      defaultTemplate: defaultTemplate ?? this.defaultTemplate,
      currentUserRole: currentUserRole ?? this.currentUserRole,
      passcode: passcode ?? this.passcode,
      smtpServer: smtpServer ?? this.smtpServer,
      smtpPort: smtpPort ?? this.smtpPort,
      smtpUsername: smtpUsername ?? this.smtpUsername,
      smtpPassword: smtpPassword ?? this.smtpPassword,
    );
  }
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 4;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      companyName: fields[0] as String? ?? 'GenXis Inc',
      companyAddress: fields[1] as String? ?? '',
      companyPhone: fields[2] as String? ?? '',
      companyEmail: fields[3] as String? ?? '',
      companyWebsite: fields[4] as String?,
      companyLogo: fields[5] as String?,
      taxId: fields[6] as String?,
      taxRate: fields[7] as double? ?? 0.10,
      invoicePrefix: fields[8] as String? ?? 'INV-',
      invoiceStartNumber: fields[9] as int? ?? 1000,
      defaultPaymentTerms: fields[10] as String? ?? 'Net 30',
      bankName: fields[11] as String?,
      bankAccountNumber: fields[12] as String?,
      bankRoutingNumber: fields[13] as String?,
      currency: fields[14] as String? ?? 'INR',
      language: fields[15] as String? ?? 'English',
      themeMode: fields[16] as String? ?? 'dark',
      emailSignature: fields[17] as String?,
      defaultTemplate: fields[18] as InvoiceTemplate? ?? InvoiceTemplate.modern,
      companySignature: fields.containsKey(19) ? fields[19] as String? : null,
      companyStamp: fields.containsKey(20) ? fields[20] as String? : null,
      currentUserRole:
          fields.containsKey(21) ? fields[21] as UserRole : UserRole.admin,
      passcode: fields.containsKey(22) ? fields[22] as String? : null,
      smtpServer: fields.containsKey(23) ? fields[23] as String? : null,
      smtpPort: fields.containsKey(24) ? fields[24] as int? : 587,
      smtpUsername: fields.containsKey(25) ? fields[25] as String? : null,
      smtpPassword: fields.containsKey(26) ? fields[26] as String? : null,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(27)
      ..writeByte(0)
      ..write(obj.companyName)
      ..writeByte(1)
      ..write(obj.companyAddress)
      ..writeByte(2)
      ..write(obj.companyPhone)
      ..writeByte(3)
      ..write(obj.companyEmail)
      ..writeByte(4)
      ..write(obj.companyWebsite)
      ..writeByte(5)
      ..write(obj.companyLogo)
      ..writeByte(6)
      ..write(obj.taxId)
      ..writeByte(7)
      ..write(obj.taxRate)
      ..writeByte(8)
      ..write(obj.invoicePrefix)
      ..writeByte(9)
      ..write(obj.invoiceStartNumber)
      ..writeByte(10)
      ..write(obj.defaultPaymentTerms)
      ..writeByte(11)
      ..write(obj.bankName)
      ..writeByte(12)
      ..write(obj.bankAccountNumber)
      ..writeByte(13)
      ..write(obj.bankRoutingNumber)
      ..writeByte(14)
      ..write(obj.currency)
      ..writeByte(15)
      ..write(obj.language)
      ..writeByte(16)
      ..write(obj.themeMode)
      ..writeByte(17)
      ..write(obj.emailSignature)
      ..writeByte(18)
      ..write(obj.defaultTemplate)
      ..writeByte(19)
      ..write(obj.companySignature)
      ..writeByte(20)
      ..write(obj.companyStamp)
      ..writeByte(21)
      ..write(obj.currentUserRole)
      ..writeByte(22)
      ..write(obj.passcode)
      ..writeByte(23)
      ..write(obj.smtpServer)
      ..writeByte(24)
      ..write(obj.smtpPort)
      ..writeByte(25)
      ..write(obj.smtpUsername)
      ..writeByte(26)
      ..write(obj.smtpPassword);
  }
}
