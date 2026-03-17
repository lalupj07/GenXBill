import 'package:hive/hive.dart';

part 'invoice_template.g.dart';

@HiveType(typeId: 9)
enum InvoiceTemplate {
  @HiveField(0)
  modern,
  @HiveField(1)
  classic,
  @HiveField(2)
  minimal,
  @HiveField(3)
  bold,
  @HiveField(4)
  gst,
  @HiveField(5)
  creative,
  @HiveField(6)
  professional,
  @HiveField(7)
  executive,
  @HiveField(8)
  corporate,
  @HiveField(9)
  elegant,
  @HiveField(10)
  standard,
  @HiveField(11)
  enterprise,
  @HiveField(12)
  compact,
  @HiveField(13)
  detailed,
  @HiveField(14)
  retail,
  @HiveField(15)
  service,
}
