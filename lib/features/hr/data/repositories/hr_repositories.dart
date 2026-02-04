import 'package:hive_flutter/hive_flutter.dart';
import '../models/overtime_model.dart';
import '../models/bonus_model.dart';
import '../models/holiday_model.dart';

class OvertimeRepository {
  static const String _boxName = 'overtime';

  Box<Overtime> get box => Hive.box<Overtime>(_boxName);

  Future<void> addOvertime(Overtime overtime) async {
    await box.put(overtime.id, overtime);
  }

  Overtime? getOvertime(String id) => box.get(id);

  List<Overtime> getOvertimeByEmployee(String employeeId) {
    return box.values.where((ot) => ot.employeeId == employeeId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Overtime> getPendingOvertime() {
    return box.values
        .where((ot) => ot.status == OvertimeStatus.pending)
        .toList();
  }

  Future<void> updateOvertime(Overtime overtime) async {
    await box.put(overtime.id, overtime);
  }

  Future<void> approveOvertime(String id, String approvedBy) async {
    final overtime = getOvertime(id);
    if (overtime != null) {
      await updateOvertime(overtime.approve(approvedBy));
    }
  }

  Future<void> deleteOvertime(String id) async {
    await box.delete(id);
  }

  double getTotalOvertimeAmount(String employeeId, int year, int month) {
    return box.values
        .where(
          (ot) =>
              ot.employeeId == employeeId &&
              ot.status == OvertimeStatus.approved &&
              ot.date.year == year &&
              ot.date.month == month,
        )
        .fold(0.0, (sum, ot) => sum + ot.amount);
  }

  Future<void> clearAll() async {
    await box.clear();
  }
}

class BonusRepository {
  static const String _boxName = 'bonuses';

  Box<Bonus> get box => Hive.box<Bonus>(_boxName);

  Future<void> addBonus(Bonus bonus) async {
    await box.put(bonus.id, bonus);
  }

  Bonus? getBonus(String id) => box.get(id);

  List<Bonus> getBonusesByEmployee(String employeeId) {
    return box.values.where((bonus) => bonus.employeeId == employeeId).toList()
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
  }

  List<Bonus> getPendingBonuses() {
    return box.values
        .where((bonus) => bonus.status == BonusStatus.pending)
        .toList();
  }

  Future<void> updateBonus(Bonus bonus) async {
    await box.put(bonus.id, bonus);
  }

  Future<void> approveBonus(String id, String approvedBy) async {
    final bonus = getBonus(id);
    if (bonus != null) {
      await updateBonus(bonus.approve(approvedBy));
    }
  }

  Future<void> markBonusAsPaid(String id) async {
    final bonus = getBonus(id);
    if (bonus != null) {
      await updateBonus(bonus.markAsPaid());
    }
  }

  Future<void> deleteBonus(String id) async {
    await box.delete(id);
  }

  double getTotalBonusAmount(String employeeId, int year) {
    return box.values
        .where(
          (bonus) =>
              bonus.employeeId == employeeId &&
              bonus.status == BonusStatus.paid &&
              bonus.month.year == year,
        )
        .fold(0.0, (sum, bonus) => sum + bonus.amount);
  }

  Future<void> clearAll() async {
    await box.clear();
  }
}

class HolidayRepository {
  static const String _boxName = 'holidays';

  Box<Holiday> get box => Hive.box<Holiday>(_boxName);

  Future<void> addHoliday(Holiday holiday) async {
    await box.put(holiday.id, holiday);
  }

  Holiday? getHoliday(String id) => box.get(id);

  List<Holiday> getAllHolidays() {
    return box.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Holiday> getHolidaysByYear(int year) {
    return box.values.where((holiday) => holiday.date.year == year).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Holiday> getUpcomingHolidays() {
    final now = DateTime.now();
    return box.values.where((holiday) => holiday.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  bool isHoliday(DateTime date) {
    return box.values.any(
      (holiday) =>
          holiday.date.year == date.year &&
          holiday.date.month == date.month &&
          holiday.date.day == date.day,
    );
  }

  Future<void> updateHoliday(Holiday holiday) async {
    await box.put(holiday.id, holiday);
  }

  Future<void> deleteHoliday(String id) async {
    await box.delete(id);
  }

  Future<void> clearAll() async {
    await box.clear();
  }
}
