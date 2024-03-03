


import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/constants/font_constants.dart';
class EditInvoiceCalendarPage extends StatefulWidget {
  static String id = 'EditInvoiceCalendarPage';

  const EditInvoiceCalendarPage({Key? key}) : super(key: key);

  @override
  State<EditInvoiceCalendarPage> createState() => _EditInvoiceCalendarPageState();
}

class _EditInvoiceCalendarPageState extends State<EditInvoiceCalendarPage> {



  DateTime date = DateTime.now();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override

  Widget build(BuildContext context) {
    var styleDataDisplay = Provider.of<StyleProvider>(context);
    var styleData = Provider.of<StyleProvider>(context, listen: false);
    // var styleData = Provider.of<StyleProvider>(context,listen:false);
    return Scaffold(
        appBar: AppBar(backgroundColor: kPureWhiteColor ,
          title: const Text('Enter Invoice Date',style: kHeadingTextStyle,),
          centerTitle: true,

        ),

        body: Container()
        // SfCalendar(
        //   showDatePickerButton: true,
        //   // minDate: DateTime.now(),
        //   todayHighlightColor: kBlueDarkColorOld,
        //   todayTextStyle: kNormalTextStyleWhiteButtons,
        //
        //   onTap: (value){
        //
        //     Provider.of<StyleProvider>(context, listen: false).setInvoicedTimeDate(value.date);
        //     Navigator.pop(context);
        //
        //
        //   },
        //   view: CalendarView.month,
        //   initialSelectedDate: Provider.of<StyleProvider>(context).invoicedDate,
        //   cellBorderColor: kBackgroundGreyColor,
        //   backgroundColor: kBackgroundGreyColor,
        //   selectionDecoration: BoxDecoration(
        //     borderRadius: BorderRadius.all(Radius.circular(8)),
        //     color: Colors.pink.withOpacity(0.5),
        //     border:
        //     Border.all(color: kGreyLightThemeColor,
        //         //const Color.fromARGB(255, 68, 140, 255),
        //         width: 2),
        //   ),
        //   // blackoutDates:
        //   // styleDataDisplay.convertedCalendarBlackouts,
        //
        //   // blackoutDatesTextStyle: kNormalTextStyleDatesUnavailable,
        //   //
        // )
    );
  }
}

