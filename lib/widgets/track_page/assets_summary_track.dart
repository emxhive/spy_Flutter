import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spy/extensions/primitive_ext.dart';
import 'package:spy/extensions/reference_ext.dart';
import 'package:spy/helpers/firestore_helpers.dart';
import 'package:spy/widgets/track_page/track_helpers/classes_track.dart';
import 'package:spy/widgets/track_page/track_helpers/classes_track_two.dart';

class SummaryWidget extends StatefulWidget {
  const SummaryWidget({super.key});

  @override
  State<StatefulWidget> createState() => SummaryState();
}

class SummaryState extends State<SummaryWidget> {
  final TDM tdm = TDM();
  final TCM tcm = TCM();
  String dayId = DateTime.now().dayId;
  TextStyle title = GoogleFonts.poppins(
      fontWeight: FontWeight.w700, color: Colors.black38, fontSize: 15);
  TextStyle gain = GoogleFonts.interTight(
      fontSize: 15, fontWeight: FontWeight.w700, color: Colors.green);
  TextStyle loss = GoogleFonts.interTight(
      fontSize: 15, fontWeight: FontWeight.w700, color: Colors.red);

  gainCheck(num no, [bool inverse = false]) {
    bool status = no <= 0;

    if (inverse) {
      status = !status;
    }
    return status ? loss : gain;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: tdm,
        builder: (c, t) {
          num pnl = 0;
          num ec = 0;
          num assets = tdm.tdrList.lastOrNull?.pmdc.usBal ?? PMB().netUsBal;
          for (final TDR(ec: e, pnl: p) in tdm.tdrList) {
            pnl += tcm.zUS ? p.us : p.ng;
            ec += tcm.zUS ? e.us : e.ng;
          }

          pnl += ec;
          return Row(
            children: [
              SBx(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("ASSETS", style: title),
                  Text(
                    assets.format(ab: true),
                    style: gainCheck(assets),
                  )
                ],
              )),
              SizedBox(width: 10),
              SBx(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "PNL",
                    style: title,
                  ),
                  Text(
                    pnl.format(ab: true),
                    style: gainCheck(pnl),
                  )
                ],
              )),
              SizedBox(width: 10),
              SBx(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "SPEND",
                    style: title,
                  ),
                  Text(
                    ec.format(ab: true),
                    style: gainCheck(ec, true),
                  )
                ],
              ))
            ],
          );
        });
  }
}

///Summary Box
class SBx extends StatelessWidget {
  const SBx({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.all(13),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12, width: 0.6),
                borderRadius: BorderRadius.circular(10)),
            child: child));
  }
}
