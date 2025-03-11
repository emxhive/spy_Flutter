import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spy/extensions/primitive_ext.dart';
import 'package:spy/extensions/reference_ext.dart';
import 'package:spy/widgets/general/widgets.dart';
import 'package:spy/widgets/track_page/track_helpers/classes_track.dart';
import 'package:spy/widgets/track_page/track_helpers/classes_track_two.dart';
import 'package:spy/widgets/track_page/track_helpers/enums_track.dart';

class TrackTable extends StatefulWidget {
  const TrackTable({super.key});

  @override
  State<StatefulWidget> createState() => TableState();
}

class TableState extends State<TrackTable> {
  final TDM tdm = TDM();
  final TCM tcm = TCM();
  final TDC tdc = TDC();

  TextStyle gain = GoogleFonts.poppins(color: Colors.green);
  TextStyle loss = GoogleFonts.poppins(color: Colors.red);

  gainCheck(num no, [bool inverse = false]) {
    bool status = no <= 0;

    if (inverse) {
      status = !status;
    }
    return status ? loss : gain;
  }

  eraTextTop(DateTime date) {
    var now = DateTime.now();
    date = date.isAfter(now) ? now : date;

    switch (tdc.mainEraSelection) {
      case null:
        return DateFormat.E().format(date);
      case Periods.week:
        String id = date.dayId;
        var start = id.split("-");

        int x = int.parse(start[2]);
        String s = ((8 * (x - 1)) + 1).toString().padLeft(2, '0');
        String e = x == 4
            ? DateTime(int.parse(start[0]), int.parse(start[1]) + 1, 1)
                .subtract(Duration(days: 1))
                .day
                .toString()
            : (8 * x).toString().padLeft(2, '0');

        return "$s-$e";
      case Periods.month:
        return DateFormat.MMMM().format(date);
      case Periods.year:
        return DateFormat.y().format(date);
    }
  }

  String eraTextBottom(DateTime date) {
    var now = DateTime.now();
    date = date.isAfter(now) ? now : date;

    switch (tdc.mainEraSelection) {
      case Periods.week:
        return DateFormat.yMMM().format(date);
      default:
        return DateFormat.yMMMd().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12, width: 0.4),
                borderRadius: BorderRadius.circular(20)),
            child: tdm.tdrList.isNotEmpty
                ? SingleChildScrollView(
                    child: ListenableBuilder(
                        listenable: tdm,
                        builder: (c, t) {
                          return tdm.tdrList.isNotEmpty
                              ? DataTable(
                                  headingRowHeight: 45,
                                  dividerThickness: 0.1,
                                  columnSpacing: 15,
                                  clipBehavior: Clip.hardEdge,
                                  columns: ["ERA", "PNL", "EXP"]
                                      .map((el) => DataColumn(
                                          headingRowAlignment: el[2] == "A"
                                              ? MainAxisAlignment.start
                                              : MainAxisAlignment.center,
                                          label: Text(
                                            el,
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.black38,
                                                fontWeight: FontWeight.w700),
                                          )))
                                      .toList(),
                                  rows: tdm.tdrKeys.map((key) {
                                    final TDR tdr = tdm.tdr(key)!;
                                    num pnl = tcm.zUS ? tdr.pnl.us : tdr.pnl.ng;
                                    num ec = tcm.zUS ? tdr.ec.us : tdr.ec.ng;
                                    pnl += ec;

                                    DateTime date = key.toDate();
                                    return DataRow(cells: [
                                      DataCell(SBW(
                                          23,
                                          align: Alignment.centerLeft,
                                          Wrap(
                                            direction: Axis.vertical,
                                            children: [
                                              Text(eraTextTop(date)),
                                              Text(
                                                eraTextBottom(date),
                                                style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    color: Colors.black38,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              )
                                            ],
                                          ))),
                                      DataCell(SBW(
                                          25,
                                          Text(
                                            pnl.format(ab: true),
                                            style: gainCheck(pnl),
                                          ))),
                                      DataCell(SBW(
                                          27,
                                          Text(
                                            ec.format(ab: true),
                                            style: gainCheck(ec, true),
                                          ))),
                                    ]);
                                  }).toList(),
                                )
                              : Container();
                        }))
                : Container()));
  }
}
