import 'package:intl/intl.dart';

String formattedDate(DateTime dateTime) {
  final now = DateTime.now();
  DateFormat dateFormat;
  final timeFormat = DateFormat('ha');

  if (dateTime.year == now.year) {
    dateFormat = DateFormat('MMM dd'); // Format without year
  } else {
    dateFormat = DateFormat('MMM dd, yyyy'); // Format with year
  }
  final formattedDate = dateFormat.format(dateTime);
  final formattedTime = timeFormat.format(dateTime);

  return '$formattedDate at $formattedTime';
}
