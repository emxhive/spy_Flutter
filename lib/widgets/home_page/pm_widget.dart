import 'package:flutter/material.dart';
import 'package:spy/extensions/primitive_ext.dart';
import 'package:spy/widgets/general/widgets.dart';
import 'package:spy/widgets/track_page/track_helpers/classes_track.dart';
import '../../helpers/firestore_helpers.dart';
import 'home_helpers/classes_home.dart';

class PMWState extends State<PMW> {
  PMD pmd = PMD();

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(children: [
      DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            color: Colors.white,
          ),
          child: ControlSection()),
      SizedBox(height: 2),
      Expanded(
          child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                color: Colors.white,
              ),
              child: ListenableBuilder(
                  listenable: pmd,
                  builder: (context, child) => ListView.separated(
                        separatorBuilder: (context, index) =>
                            Divider(color: Colors.grey[100]),
                        itemBuilder: (context, index) {
                          var key = pmd.pmKeys[index];
                          PMC pmc = pmd.pmcList(key)!;
                          bool showFee = pmc.fee > 0;
                          bool showFrozen = pmc.frozen > 0;
                          bool showTotal = pmc.available != pmc.balance;

                          var row = Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 15,
                                    backgroundImage:
                                        NetworkImage(pmd.pmLogos(key)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PMWText(pmc.id,
                                          isTitle: true, isLight: false),
                                      if (showFee) const PMWText("Fee"),
                                      if (showFrozen)
                                        const PMWText("Unavailable"),
                                      if (showTotal) const PMWText("Total")
                                    ],
                                  )),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      PMWText(pmc.available.toDp(),
                                          isLight: false, isAmount: true),
                                      if (showFee)
                                        PMWText(pmc.fee.toDp(), isAmount: true),
                                      if (showFrozen)
                                        PMWText(pmc.frozen.toDp(),
                                            isAmount: true),
                                      if (showTotal)
                                        PMWText(
                                          pmc.balance.toDp(),
                                          isAmount: true,
                                        )
                                    ],
                                  ))
                                ],
                              ));

                          if (index == 0) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [const SizedBox(height: 10), row],
                            );
                          } else if (index == pmd.pmKeys.length - 1) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [row, const SizedBox(height: 10)],
                            );
                          } else {
                            return row;
                          }
                        },
                        itemCount: pmd.pmKeys.length,
                      ))))
    ]));
  }
}

class PMW extends StatefulWidget {
  const PMW({super.key});

  @override
  State<StatefulWidget> createState() => PMWState();
}

class ControlSection extends StatelessWidget {
  const ControlSection({super.key});

  ///calls [TDM.record] ONCE everytime the app loads first time.
  Future<Null> f() {
    return Future.delayed(Duration(seconds: 1), () => TDM().record());
  }

  @override
  Widget build(BuildContext context) {
    if (PMD().firstRecord) f();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
            onPressed: () {
              TDM().record();
            },
            icon: Icon(Icons.task_alt_outlined, size: 20)),
        IconButton(
            onPressed: PMD().export,
            icon: Icon(
              Icons.cloud_download_outlined,
              size: 20,
            )),
        SizedBox(width: 14)
      ],
    );
  }
}
