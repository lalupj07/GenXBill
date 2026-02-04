import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/hr/providers/hr_providers.dart';
import 'package:genx_bill/features/hr/data/models/attendance_model.dart';
import 'package:genx_bill/features/hr/data/models/employee_model.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:genx_bill/core/services/csv_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Watch relevant providers
    // We assume getTodayAttendance is what we want for "today",
    // but if we select a date, we need to filter by that date.
    // The repository has getAttendanceByDateRange or similar.
    // Since we don't have a provider for "attendance by date" yet, we may need to compute it.
    // Or just fetch all and filter (easiest for small datasets).

    final attendanceRepo = ref.watch(attendanceRepositoryProvider);
    // Fetch all for now and filter. In production, use meaningful queries.
    final allAttendance = attendanceRepo.getAllAttendance();

    final filteredAttendance = allAttendance.where((att) {
      return att.date.year == _selectedDate.year &&
          att.date.month == _selectedDate.month &&
          att.date.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      body: ThemeBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, filteredAttendance),
              _buildDateSelector(),
              Expanded(
                child: filteredAttendance.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAttendance.length,
                        itemBuilder: (context, index) {
                          return _buildAttendanceCard(
                              filteredAttendance[index], index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAttendanceDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Check-in'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Attendance> attendanceList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              const Text(
                'Attendance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            tooltip: 'Export CSV',
            onPressed: () => _exportCsv(attendanceList),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white.withValues(alpha: 0.05),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          Expanded(
            child: Center(
              child: TextButton.icon(
                icon: const Icon(Icons.calendar_today,
                    color: Colors.white, size: 16),
                label: Text(
                  DateFormat.yMMMEd().format(_selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _selectedDate.year == DateTime.now().year &&
                    _selectedDate.month == DateTime.now().month &&
                    _selectedDate.day == DateTime.now().day
                ? null
                : () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy,
              size: 64, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'No attendance records for this date',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance attendance, int index) {
    // We need employee name. With only employeeId, we might need to fetch employee.
    // Riverpod can help here ideally, but for now we might show ID or helper.

    final employees = ref.read(allEmployeesProvider);
    HREmployee? employee;
    try {
      employee = employees.firstWhere((e) => e.id == attendance.employeeId);
    } catch (_) {}

    final employeeName =
        employee != null ? employee.name : 'Emp ID: ${attendance.employeeId}';

    Color statusColor;
    switch (attendance.status) {
      case AttendanceStatus.present:
        statusColor = Colors.green;
        break;
      case AttendanceStatus.absent:
        statusColor = Colors.red;
        break;
      case AttendanceStatus.halfDay:
        statusColor = Colors.orange;
        break;
      case AttendanceStatus.leave:
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.5),
            child: Text(
              employeeName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  employeeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '${attendance.checkIn != null ? DateFormat('HH:mm').format(attendance.checkIn!) : '--:--'} - ${attendance.checkOut != null ? DateFormat('HH:mm').format(attendance.checkOut!) : '--:--'}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        attendance.status.name.toUpperCase(),
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (attendance.workHours > 0)
                Text(
                  '${attendance.workHours.toStringAsFixed(1)} hrs',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              if (attendance.isLateArrival)
                const Text(
                  'LATE',
                  style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX();
  }

  Future<void> _exportCsv(List<Attendance> data) async {
    final settings = ref.read(settingsProvider);
    final csvService = ref.read(csvServiceProvider);

    final csvData = csvService.generateAttendanceCsv(data, settings);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/GenXBill/Reports';
    await Directory(path).create(recursive: true);
    final file = File(
        '$path/Attendance_${DateFormat('yyyy-MM-dd').format(_selectedDate)}.csv');
    await file.writeAsString(csvData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${file.path}')),
      );
    }
  }

  void _showAddAttendanceDialog(BuildContext context) {
    // Placeholder for manual addition
    final employees = ref.read(allEmployeesProvider);
    String? selectedEmployeeId =
        employees.isNotEmpty ? employees.first.id : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title:
            const Text('Add Check-in', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedEmployeeId,
              dropdownColor: const Color(0xFF2D2A5D),
              style: const TextStyle(color: Colors.white),
              items: employees.map((e) {
                return DropdownMenuItem(
                  value: e.id,
                  child: Text(e.name),
                );
              }).toList(),
              onChanged: (val) => selectedEmployeeId = val,
              decoration: const InputDecoration(
                labelText: 'Employee',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30)),
              ),
            ),
            // Date/Time pickers could go here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logic to add attendance
              if (selectedEmployeeId != null) {
                final repo = ref.read(attendanceRepositoryProvider);
                repo.checkIn(selectedEmployeeId!, DateTime.now());
                setState(() {}); // refresh
                Navigator.pop(context);
              }
            },
            child: const Text('Check In Now'),
          ),
        ],
      ),
    );
  }
}

// GlassContainer definition to match project usage if wrapper needed,
// but assuming package 'glassmorphism' provides `GlassmorphicContainer` or similar.
// The code in ProductsPage used `GlassContainer`. It might be a custom widget wrapper or from a package.
// Let's check ProductsPage imports. It imports 'package:genx_bill/core/theme/app_theme.dart'
// and doesn't seem to define GlassContainer unless it's in a package or valid widget.
// Actually, `glassmorphism` package provides `GlassmorphicContainer`.
// `ProductsPage` code I read earlier uses `GlassContainer`.
// I will check if `GlassContainer` is defined in the codebase, e.g. in `lib/core/widgets`?
// Or maybe I am remembering `glass_kit`.
// `pubspec` has `glassmorphism: ^3.0.0`.
// `ProductsPage` import list:
// ...
// import 'package:glassmorphism/glassmorphism.dart'; (NOT seen in view_file output! Wait.)

// Let's re-examine ProductsPage view_file output.
// Line 24: import 'package:glassmorphism/glassmorphism.dart';
// Wait, I see Line 24 is `import 'package:glassmorphism/glassmorphism.dart';` in `pubspec`.
// In `ProductsPage.dart` view:
// Line 24 in file is just `Widget build...`
// Imports are Lines 1-12. No `glassmorphism` import.
// BUT Line 181 uses `GlassContainer`.
// Maybe it's a custom widget?
