import 'package:cloud_firestore/cloud_firestore.dart';
 import 'package:spy/widgets/track_page/track_helpers/classes_track.dart';

class TFS {
  final String _track = "track/mx-spy";

  ///get last payment method state [PMDC]
  getLastPMS() async {
    var map = await FirebaseFirestore.instance
            .doc(_track)
            .get()
            .then((value) => value.data()) ??
        {};

    return map.isNotEmpty ? PMDC.fromMap(map) : PMDC();
  }

  updatePMS(PMDC pmdc) async {
    bool success = false;
    await FirebaseFirestore.instance
        .doc(_track)
        .set(pmdc.toMap())
        .then((value) => success = true);

    return success;
  }

  ///END OF NOTEWORTHY CLASS FIELD
  static final TFS _single = TFS._internal();

  factory TFS() {
    return _single;
  }

  TFS._internal();
}
