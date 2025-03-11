extension XString on String {
  String toTitleCase([int? maxLength]) {
    return replaceFirst(this[0], this[0].toUpperCase()).substring(0, maxLength);
  }

  num extractNum() {
    return num.parse(
        RegExp(r'[0-9.]').allMatches(this).map((e) => e[0]).join(""));
  }

  ///Same functionality as [num.format]
  String formatAmt() {
    String txt = this;

    var txtArr = txt.split(".");
    if (txtArr.length == 1) {
      txtArr.add("00");
    }
    var tx = txtArr[0];
    if (txt.length > 3) {
      var reg = RegExp(r'(?<=\d)\d{3}($|(?=,))');
      var arr = (txt.length / 3).toString().split(".");
      var index = num.parse(arr[0]);
      if (arr.length == 1) {
        index--;
      }

      for (var i = 0; i < index; i++) {
        tx = tx.replaceFirstMapped(reg, (m) => ",${m[0]}");
      }
      return "$tx.${txtArr[1]}";
    } else {
      return txt;
    }
  }

  DateTime toDate() {
    return DateTime.parse(toString());
  }
}

extension XNum on num {
  String toDp({int? dp}) {
    return this == 0 ? '0' : toStringAsFixed(dp ?? 2);
  }

  num fixed() {
    return (this * 100).ceil() / 100;
  }

  ///[ab] calls num.abs() on the number before formatting

  String format({int? dp = 2, bool shorten = false, ab = false}) {
    String txt;

    if (dp != null) {
      txt = toDp(dp: dp);
    } else {
      txt = toString();
    }
    if (this == 0) {
      txt = '0';
    } else {
      var txtArr = txt.split(".");
      if (txtArr.length == 1) {
        txtArr.add("00");
      }
      var tx = txtArr[0];
      if (txt.length > 3) {
        var reg = RegExp(r'(?<=\d)\d{3}($|(?=,))');
        var arr = (txt.length / 3).toString().split(".");
        var index = num.parse(arr[0]);
        if (arr.length == 1) {
          index--;
        }

        for (var i = 0; i < index; i++) {
          tx = tx.replaceFirstMapped(reg, (m) => ",${m[0]}");
        }
        txt = "$tx.${txtArr[1]}";
      }
    }

    return ab ? txt.replaceFirst("-", '') : txt;
  }
}

extension Xint on int {
  String get dateWorthy => toString().padLeft(2, '0');
}

extension Xbool on bool {
  int compareTo(bool b) {
    if (this == b) {
      return 0;
    } else {
      return b ? -1 : 1;
    }
  }
}
