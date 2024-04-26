import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  //year
  String year = dateTime.year.toString();

  // month
  String month = dateTime.month.toString();

  // day
  String day = dateTime.day.toString();

  String hour = dateTime.hour.toString();

  String minute = dateTime.minute.toString();

  //formatted date
  String formattedData = '$year/$month/$day . $hour:$minute';

  return formattedData;
}
