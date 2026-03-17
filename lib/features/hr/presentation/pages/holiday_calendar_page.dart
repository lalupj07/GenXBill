import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/hr/data/models/holiday_model.dart';
import 'package:genx_bill/features/hr/providers/hr_providers.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';

class HolidayCalendarPage extends ConsumerStatefulWidget {
  const HolidayCalendarPage({super.key});

  @override
  ConsumerState<HolidayCalendarPage> createState() =>
      _HolidayCalendarPageState();
}

class _HolidayCalendarPageState extends ConsumerState<HolidayCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final holidays = ref.watch(upcomingHolidaysProvider);
    final allHolidays = ref.watch(holidayRepositoryProvider).getAllHolidays();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holiday Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHolidayDialog(context),
          ),
        ],
      ),
      body: ThemeBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCalendarHeader(),
              const SizedBox(height: 16),
              _buildCalendarGrid(allHolidays),
              const SizedBox(height: 24),
              const Text(
                'Upcoming Holidays',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: holidays.length,
                itemBuilder: (context, index) {
                  final holiday = holidays[index];
                  return _buildHolidayTile(holiday);
                },
              ),
              if (holidays.isEmpty)
                const Center(child: Text('No upcoming holidays')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(_focusedDay),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _focusedDay =
                      DateTime(_focusedDay.year, _focusedDay.month - 1);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _focusedDay =
                      DateTime(_focusedDay.year, _focusedDay.month + 1);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(List<Holiday> holidays) {
    final daysInMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_focusedDay.year, _focusedDay.month, 1).weekday;

    // Adjust for Monday start (Flutter's DateTime.weekday: 1 = Mon, 7 = Sun)
    final offset = firstDayOfMonth - 1;

    return Column(
      children: [
        // Weekday labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((d) => Text(d,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.4, // Make cells shorter to fit screen
          ),
          itemCount: 42, // 6 weeks
          itemBuilder: (context, index) {
            final dayNumber = index - offset + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final date =
                DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
            final holiday = holidays.firstWhere(
              (h) =>
                  h.date.year == date.year &&
                  h.date.month == date.month &&
                  h.date.day == date.day,
              orElse: () => Holiday(
                  id: '', name: '', date: date, type: HolidayType.public),
            );

            final isHoliday = holiday.id.isNotEmpty;
            final isSelected = _selectedDay?.day == date.day &&
                _selectedDay?.month == date.month &&
                _selectedDay?.year == date.year;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = date;
                });
                if (isHoliday) {
                  _showHolidayDetails(holiday);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.3)
                      : isHoliday
                          ? Colors.orange.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : isHoliday
                            ? Colors.orange
                            : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    dayNumber.toString(),
                    style: TextStyle(
                      color: isHoliday ? Colors.orange : Colors.white,
                      fontWeight:
                          isHoliday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHolidayTile(Holiday holiday) {
    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.festival, color: Colors.orange),
        ),
        title: Text(holiday.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('dd MMM yyyy').format(holiday.date)),
        trailing: Text(holiday.typeName,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        onTap: () => _showHolidayDetails(holiday),
      ),
    ).animate().fadeIn().slideX();
  }

  void _showAddHolidayDialog(BuildContext context) {
    final nameController = TextEditingController();
    HolidayType type = HolidayType.public;
    DateTime date = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Holiday'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Holiday Name'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Date: ${DateFormat('dd MMMM yyyy').format(date)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => date = picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HolidayType>(
                initialValue: type,
                items: HolidayType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (val) => setDialogState(() => type = val!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final holiday = Holiday.create(
                    name: nameController.text,
                    date: date,
                    type: type,
                  );
                  await ref.read(holidayRepositoryProvider).addHoliday(holiday);
                  if (context.mounted) Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHolidayDetails(Holiday holiday) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(holiday.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('dd MMMM yyyy').format(holiday.date)}'),
            const SizedBox(height: 8),
            Text('Type: ${holiday.typeName}'),
            if (holiday.description != null) ...[
              const SizedBox(height: 8),
              Text('Description: ${holiday.description}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref
                  .read(holidayRepositoryProvider)
                  .deleteHoliday(holiday.id);
              if (context.mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }
}
