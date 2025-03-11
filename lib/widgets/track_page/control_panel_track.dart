import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spy/extensions/reference_ext.dart';
import 'package:spy/widgets/general/widgets.dart';
import 'package:spy/widgets/track_page/track_helpers/classes_track.dart';
import 'package:spy/widgets/track_page/track_helpers/enums_track.dart';

class ControlSectionDT extends StatelessWidget {
  const ControlSectionDT({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Column(
        children: [
          SegmentedButtonWidget(),
          SizedBox(height: 15),
          EraSelector()
        ],
      ),
    );
  }
}

class SegmentedButtonWidget extends StatefulWidget {
  const SegmentedButtonWidget({super.key});

  @override
  State<StatefulWidget> createState() => SegmentState();
}

class SegmentState extends State<SegmentedButtonWidget> {
  Periods? selection = TDC().mainEraSelection;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12, width: 1),
            borderRadius: BorderRadius.circular(26)),
        child: SegmentedButton(
            style: SegmentedButton.styleFrom(
              side: BorderSide(color: Colors.transparent),
              padding: EdgeInsets.all(15),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity:
                  VisualDensity(horizontal: VisualDensity.maximumDensity),
            ),
            showSelectedIcon: false,
            emptySelectionAllowed: true,
            onSelectionChanged: (select) => setState(() {
                  selection = select.firstOrNull;
                  TDC().mainEra(selection);
                }),
            segments: Periods.values
                .map((period) => ButtonSegment(
                    value: period,
                    label: SBW(
                        25,
                        Text(
                          period.name,
                        ))))
                .toList(),
            selected: {selection}));
  }
}

class EraSelector extends StatefulWidget {
  const EraSelector({super.key});

  @override
  State<StatefulWidget> createState() => EraState();
}

class EraState extends State<EraSelector> {
  TDM tdm = TDM();
  TCM tcm = TCM();
  TDC tdc = TDC();
  late final TextEditingController startCtrl;
  late final TextEditingController endCtrl;
  String dayId = DateTime.now().dayId;

  @override
  void initState() {
    super.initState();
    startCtrl = TextEditingController(text: tdc.eraStart);
    endCtrl = TextEditingController(text: tdc.eraEnd);
  }

  @override
  void dispose() {
    super.dispose();
    startCtrl.dispose();
    endCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DatePickerRange(
              pickerManager: tdc.selectEra,
              endController: endCtrl,
              startController: startCtrl),
          SizedBox(width: 10),
          ListenableBuilder(
              listenable: tcm,
              builder: (c, w) => OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: Colors.black12, width: 0.8),
                    shape: CircleBorder(),
                  ),
                  onPressed: tcm.changeDc,
                  child: Text(
                    tcm.dc,
                    style: GoogleFonts.inter(
                        fontSize: 19, fontWeight: FontWeight.w500),
                  )))
        ]);
  }
}
