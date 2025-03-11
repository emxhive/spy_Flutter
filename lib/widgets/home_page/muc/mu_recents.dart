import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spy/extensions/primitive_ext.dart';
import 'package:spy/helpers/firestore_helpers.dart';
import 'package:spy/widgets/general/widgets.dart';
import '../../general/general_enums.dart';
import '../../track_page/track_helpers/classes_track.dart';
import 'helper_classes.dart';

class RecentChanges extends StatefulWidget {
  const RecentChanges({super.key});

  @override
  State<StatefulWidget> createState() => _RCState();
}

class _RCState extends State<RecentChanges> {
  late final ScrollController _scrollController;

  ///scrolls to end after each element is added to the ListView
  Future<void> _afterBuild() async => await Future.delayed(Duration.zero, () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  final MUM mum = MUM();
  final TDM tdm = TDM();
  TextStyle lightText = GoogleFonts.poppins(
      color: Colors.black38, fontSize: 12, fontWeight: FontWeight.w400);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.black38, width: 0.3))),
                child: Text(
                  "Recent Changes",
                  style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black54),
                ),
              ),
              Expanded(
                  child: ListenableBuilder(
                      listenable: mum,
                      builder: (context, child) {
                        _afterBuild();
                        final rwData =
                            mum.getProperty(MUProps.muList, isList: true);
                        return ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(vertical: 13),
                            itemCount: rwData.length,
                            itemBuilder: (context, index) {
                              MUO muo = rwData[index];

                              return Padding(
                                  padding: EdgeInsets.all(3),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: IconButton(
                                              onPressed: () {
                                                mum.removeLC(muo.hashCode);
                                              },
                                              icon: Icon(Icons
                                                  .delete_forever_outlined),
                                              color: Colors.black45)),
                                      Expanded(
                                        flex: 1,
                                        child: Text((index + 1).toString()),
                                      ),
                                      Expanded(
                                          flex: 3,
                                          child: Wrap(
                                            direction: Axis.vertical,
                                            children: [
                                              PMWText(
                                                muo.pmName,
                                                isTitle: true,
                                                isLight: false,
                                                max: 11,
                                                style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
                                              ),
                                              Text(
                                                DateFormat.jms()
                                                    .format(muo.date),
                                                style: lightText,
                                              ),
                                            ],
                                          )),
                                      Expanded(
                                          flex: 2,
                                          child: Wrap(
                                            direction: Axis.vertical,
                                            children: [
                                              Text(muo.type.toTitleCase(), style: GoogleFonts.poppins(fontSize: 13), ),
                                              Text(muo.mode.name.toTitleCase(),
                                                  style: lightText),
                                            ],
                                          )),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          muo.value.format(),
                                          style: GoogleFonts.interTight(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w300,
                                              letterSpacing: 0.5),
                                        ),
                                      ),
                                    ],
                                  ));
                            });
                      }))
            ])),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () {
                      if (tdm.allowRecord) {
                        tdm.allowRecord = false;
                        PMD pmd = PMD();
                        pmd.localUpdate(mum.muoList.values);
                        pmd.rebuild();
                        mum.clearList();
                        // navPop();
                        Navigator.pop(context);
                        Navigator.pop(context);
                        tdm.allowRecord = true;
                      }
                    },
                    child: Text("Close"))),
            SizedBox(
              width: 20,
            ),
            Expanded(
                child: FilledButton(
                    onPressed: () {
                      createMUO(String value, {type}) {
                        num val = value.extractNum();
                        if (value.toString().isNotEmpty) {
                          MUO(mum.getProperty(MUProps.sw),
                              mode: mum.getProperty(MUProps.us),
                              type: type ?? mum.getProperty(MUProps.im),
                              value: val);
                        } else {
                          throwError();
                        }
                      }

                      clearTextController(MUProps en) {
                        (mum.getProperty(en) as TextEditingController).clear();
                      }

                      var updateSelection = mum.getProperty(MUProps.us);
                      String bal = mum.getProperty(MUProps.bCtrl).text;
                      if (updateSelection == ManualUpdateOption.include) {
                        if (bal.isNotEmpty) {
                          createMUO(bal);
                          clearTextController(MUProps.bCtrl);
                        }
                      } else {
                        String frz = mum.getProperty(MUProps.fCtrl).text;

                        if (bal.isNotEmpty) {
                          createMUO(bal, type: "Balance");
                          clearTextController(MUProps.bCtrl);
                        }
                        if (frz.isNotEmpty) {
                          createMUO(frz, type: "MIA");
                          clearTextController(MUProps.fCtrl);
                        }
                      }
                    },
                    child: Text("Record")))
          ],
        ),
        SizedBox(
          height: 30,
        )
      ],
    );
  }

  void throwError() {}
}
