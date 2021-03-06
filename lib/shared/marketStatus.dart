bool isMarketOpen() {
  DateTime now = DateTime.now();
  DateTime todayStart = DateTime(now.year, now.month, now.day);
  DateTime todayMarketStart = DateTime(now.year, now.month, now.day, 09, 15);
  DateTime todayMarketEnd = DateTime(now.year, now.month, now.day, 15, 30);

  // during holiday
  List<DateTime> holidays = [
    DateTime(2021, 1, 26),
    DateTime(2021, 3, 11),
    DateTime(2021, 3, 29),
    DateTime(2021, 4, 02),
    DateTime(2021, 4, 14),
    DateTime(2021, 4, 21),
    DateTime(2021, 5, 13),
    DateTime(2021, 7, 21),
    DateTime(2021, 8, 19),
    DateTime(2021, 9, 10),
    DateTime(2021, 10, 15),
    DateTime(2021, 11, 04),
    DateTime(2021, 11, 05),
    DateTime(2021, 11, 19),
  ];

  if (holidays.indexOf(todayStart) != -1) {
    return false;
  }

  // during weekend
  if ([DateTime.saturday, DateTime.sunday].indexOf(now.weekday) != -1) {
    return false;
  }

  // market time 9:00 am - 4:00 pm
  if (now.isBefore(todayMarketStart) || now.isAfter(todayMarketEnd)) {
    return false;
  }

  return true;
}
