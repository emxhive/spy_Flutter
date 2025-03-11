import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spy/helpers/firestore_helpers.dart';

///FireStore Base
mixin FSB {
  final String pmInfo = "pmstate/mx-spy";
  final String pmIcons = "pmicons/mx-spy";
}

class Write with FSB {
  xrate(num nr) async {
    final data = {
      'generalProps': {"rate": nr}
    };
    await FirebaseFirestore.instance
        .doc(pmInfo)
        .set(data, SetOptions(merge: true));
  }

  updatePM(data) async {
    await FirebaseFirestore.instance
        .doc(pmInfo)
        .set(data, SetOptions(merge: true))
        .then((value) {
      PMD().refreshData();
    });
  }

  newPM() {}

  deletePM() {}

  ///END OF NOTEWORTHY LASS FIELD

  static final Write _single = Write._internal();

  factory Write() {
    return _single;
  }

  Write._internal();
}
