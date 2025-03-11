import 'classes_track.dart';

/// Track Data Results
class TDR {
  TDR(this.dayId, {required this.ec, required this.pnl, required this.pmdc});

  String dayId;
  final EC ec;
  final PLC pnl;
  PMDC pmdc = PMDC();
}
