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
}
