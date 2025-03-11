import 'package:spy/extensions/primitive_ext.dart';

extension XList<E> on List<E> {
  ///removes the first, adds one at the end--Length remains unchanged, Oldest leaves tho
  void rep(E value) {
    insert(length, value);
    removeAt(0);
  }
}

extension XDate on DateTime {
  String get dayId => [
        year,
        month.toString().padLeft(2, "0"),
        day.toString().padLeft(2, "0")
      ].join("-");

  bool get isToday {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day) == this;
  }

  String get time12 {
    DateTime now = DateTime.now();
    (String, String) v = now.hour > 12
        ? ("PM", (now.hour - 12).dateWorthy)
        : ("AM", now.hour.dateWorthy);
    return "${v.$2}:${now.minute.dateWorthy} ${v.$1}";
  }

  ///Date Cashbook format 29/12/1999
  String get dateCb {
    var now = DateTime.now();
    return "${now.day.dateWorthy}/${now.month.dateWorthy}/${now.year}";
  }
}
