import 'package:intl/intl.dart';

String formattedDate(DateTime dateTime) {
  DateTime now = DateTime.now();
  DateFormat dateFormat;
  DateFormat timeFormat = DateFormat('ha');

  if (dateTime.year == now.year) {
    dateFormat = DateFormat('MMM dd'); // Format without year
  } else {
    dateFormat = DateFormat('MMM dd, yyyy'); // Format with year
  }
  String formattedDate = dateFormat.format(dateTime);
  String formattedTime = timeFormat.format(dateTime);

  return '$formattedDate at $formattedTime';
}
