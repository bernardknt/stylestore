import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/basket_items.dart';
import '../../utilities/constants/font_constants.dart';
import '../../utilities/constants/user_constants.dart';

class CalendarPageOld extends StatefulWidget {
  static String id = 'CalendarPage';

  const CalendarPageOld({Key? key}) : super(key: key);

  @override
  State<CalendarPageOld> createState() => _CalendarPageOldState();
}

class _CalendarPageOldState extends State<CalendarPageOld> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  var uuid = Uuid();

  void defaultsInitiation() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        kOrderId,
        'OL${_selectedDay.day}' +
            '${uuid.v1().split("-")[0]}' +
            '${uuid.v4().split("-")[0]}' +
            '${_selectedDay.month}');
  }

  @override
  void initState() {
    super.initState();
    defaultsInitiation();
  }

  @override
  Widget build(BuildContext context) {
    var styleDataDisplay = Provider.of<StyleProvider>(context);
    var styleData = Provider.of<StyleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPureWhiteColor,
        title: const Text('Appointment Date & Time', style: kHeadingTextStyle),
      ),
      body: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        headerStyle: const HeaderStyle(formatButtonVisible: false),

        // Customization for blackout dates (if needed)
        availableCalendarFormats: const { // Restrict to month view only
          CalendarFormat.month: 'Month',
        },
        //... Other styling options

        // Blackout Date Functionality
        // disabledDaysOfWeek: _convertBlackoutDatesToDaysOfWeek(styleDataDisplay.convertedCalendarBlackouts),

        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            defaultsInitiation(); // Update Order ID
          });

          // Price update logic
          styleData.setBookingPrice(styleDataDisplay.totalPrice);
        },
      ),
    );
  }

  // Assuming convertedCalendarBlackouts is a list of DateTime objects.
  List<int> _convertBlackoutDatesToDaysOfWeek(List<DateTime> blackouts) {
    return blackouts.map((date) => date.weekday).toSet().toList();
  }
}


