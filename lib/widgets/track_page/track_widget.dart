import 'package:flutter/material.dart';
import 'package:spy/widgets/track_page/assets_summary_track.dart';
import 'package:spy/widgets/track_page/datatable_view_track.dart';
import 'package:spy/widgets/track_page/control_panel_track.dart';

class TrackBase extends StatelessWidget {
  const TrackBase({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ControlSectionDT(),
            SizedBox(height: 30),
            SummaryWidget(),
            SizedBox(height: 30),
            TrackTable()
          ],
        ));
  }
}
