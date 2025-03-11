import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spy/widgets/general/general_classes.dart';
import 'package:spy/widgets/general/widgets.dart';
import '../../general/general_enums.dart';
import 'helper_classes.dart';

class UpdateInputs extends StatefulWidget {
  const UpdateInputs({super.key});

  @override
  State<StatefulWidget> createState() => _IncludeInputState();
}

class _IncludeInputState extends State<UpdateInputs> {
  final MUM _mum = MUM();
  late TextEditingController _balController;
  late TextEditingController _frozenController;

  void _imStateManager(String option) {
    _mum.setProperty(MUProps.im, option);
  }

  @override
  void initState() {
    super.initState();
    _mum.initTC();
    _balController = _mum.getProperty(MUProps.bCtrl);
    _frozenController = _mum.getProperty(MUProps.fCtrl);
  }

  @override
  void dispose() {
    _mum.disposeTC();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: _mum,
        builder: (context, child) {
          ManualUpdateOption updateSelection = _mum.getProperty(MUProps.us);
          String includeMode = _mum.getProperty(MUProps.im);
          bool isAdd = updateSelection == ManualUpdateOption.include;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAdd) ...[
                MXInput(includeMode,
                    isTop: false,
                    dropDownObjs: DDO(null,
                        stateManager: _imStateManager,
                        list: TETU.values.map((e) => e.name).toList(),
                        searchHint: 'Search Update Mode ...'),
                    prefixChildren: [
                      Icon(Icons.playlist_add_check_rounded),
                      SizedBox(
                        width: 8,
                      ),
                      Text("Mode")
                    ]),
                SizedBox(
                  height: 30,
                )
              ],
              MXInput("Balance",
                  style: GoogleFonts.poppins(fontSize: 17),
                  keyboardType: TextInputType.number,
                  formatter: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    FilteringTextInputFormatter(RegExp("(\\.{2})|(,{2)"),
                        allow: false)
                  ],
                  textController: _balController,
                  prefixChildren: [
                    Icon(isAdd
                        ? Icons.add_rounded
                        : Icons.account_balance_wallet_rounded),
                  ]),
              if (!isAdd) ...[
                SizedBox(
                  height: 30,
                ),
                MXInput("Temporarily Unavailable",
                    keyboardType: TextInputType.number,
                    textController: _frozenController,
                    style: GoogleFonts.poppins(fontSize: 17),
                    prefixChildren: [Icon(Icons.lock_clock)])
              ]
            ],
          );
        });
  }
}
