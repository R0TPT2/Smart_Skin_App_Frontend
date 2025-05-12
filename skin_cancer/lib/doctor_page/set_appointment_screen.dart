import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SetAppointmentScreen extends StatefulWidget {
  const SetAppointmentScreen({super.key});

  @override
  _SetAppointmentScreenState createState() => _SetAppointmentScreenState();
}

class _SetAppointmentScreenState extends State<SetAppointmentScreen> {
  // Selected Date and Time
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Calendar Controller
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  // Function to Show Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Appointment', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[700], size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Picker
            Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700], // Update text color
              ),
            ),
            SizedBox(height: 8),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDay = focusedDay; // Update the focused day
                });
              },
              selectedDayPredicate: (DateTime day) {
                return isSameDay(_selectedDate, day);
              },
              onFormatChanged: (CalendarFormat format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, date, _) {
                  return Container(
                    margin: const EdgeInsets.all(4.0), // Add spacing around the cell
                    decoration: BoxDecoration(
                      color: Colors.blue[700], // Highlight selected date
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.blue[700]), // Style weekdays
                weekendStyle: TextStyle(color: Colors.red), // Style weekends
              ),
            ),
            SizedBox(height: 20),

            // Time Picker
            Text(
              'Select Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700], // Update text color
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () => _selectTime(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[700]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _selectedTime == null
                        ? 'Select Time'
                        : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')} ${_selectedTime!.period.name.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),

            // Confirmation Text
            Text(
              _selectedDate != null && _selectedTime != null
                  ? 'Are you sure you want to set the appointment for:\n\n'
                      '- Date: ${_selectedDate?.toLocal().toString().split(' ')[0]}\n'
                      '- Time: ${_selectedTime?.format(context)}'
                  : 'Please select a date and time to confirm.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),

            // Confirm Button
            ElevatedButton(
              onPressed: () {
                if (_selectedDate == null || _selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select both date and time.')),
                  );
                } else {
                  // Confirm Logic Here
                  print('Selected Date: $_selectedDate');
                  print('Selected Time: $_selectedTime');
                  Navigator.pop(context); // Navigate back after confirmation
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700], // Change button color to blue[700]
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 108),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Confirm Appointment',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}