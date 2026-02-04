import 'package:hive/hive.dart';

part 'employee_document.g.dart';

@HiveType(typeId: 56)
enum DocumentType {
  @HiveField(0)
  idProof, // Aadhar, PAN, Passport
  @HiveField(1)
  certificate, // Education
  @HiveField(2)
  contract, // Employment Contract
  @HiveField(3)
  other,
}

@HiveType(typeId: 57)
class EmployeeDocument {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DocumentType type;

  @HiveField(3)
  final String filePath; // Local path to file

  @HiveField(4)
  final DateTime uploadDate;

  @HiveField(5)
  final String? notes;

  EmployeeDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.filePath,
    required this.uploadDate,
    this.notes,
  });
}
