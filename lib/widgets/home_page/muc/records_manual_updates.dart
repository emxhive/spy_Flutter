import 'package:flutter/material.dart';
import 'package:spy/helpers/firestore_helpers.dart';
import 'package:spy/widgets/general/general_classes.dart';
import 'package:spy/widgets/general/widgets.dart';
import '../../general/general_enums.dart';
import 'helper_classes.dart';
import 'mu_inputs.dart';
import 'mu_recents.dart';

class ManualUpdatePage extends StatelessWidget {
  const ManualUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  MUPSelectorView(),
                  Expanded(child: RecentChanges()),
                ],
              ),
            )));
  }
}

///MUP- Manual Update Page
class MUPSelectorView extends StatefulWidget {
  const MUPSelectorView({super.key});

  @override
  State<StatefulWidget> createState() => _MUPSVState();
}

///MUP- Manual Update Page
class _MUPSVState extends State<MUPSelectorView> {
  final MUM _mum = MUM();
  final PMD pmd = PMD();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height / 2.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Choose Update Mode"),
                ListenableBuilder(
                    listenable: _mum,
                    builder: (context, child) {
                      ManualUpdateOption updateSelection =
                          _mum.getProperty(MUProps.us);
                      return SegmentedButton(
                        segments: ManualUpdateOption.values
                            .map((obj) => ButtonSegment(
                                  value: obj,
                                  label: Text(obj.name),
                                ))
                            .toList(),
                        selected: <ManualUpdateOption>{updateSelection},
                        onSelectionChanged: (sel) {
                          _mum.setProperty(MUProps.us, sel.first);
                        },
                        showSelectedIcon: false,
                      );
                    })
              ],
            ),
            SizedBox(height: 30),
            ListenableBuilder(
                listenable: _mum,
                builder: (context, child) {
                  String selectedWallet = _mum.getProperty(MUProps.sw);

                  return MXInput(
                    selectedWallet,
                    isTop: false,
                    dropDownObjs: DDO({},
                        stateManager: (String wallet) =>
                            _mum.setProperty(MUProps.sw, wallet),
                        list: pmd.pmKeys,
                        searchHint: 'Search for wallet ...'),
                    prefixChildren: [
                      Icon(
                        Icons.account_balance_rounded,
                        color: Colors.black45,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Wallet",
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(color: Colors.black38),
                      )
                    ],
                  );
                }),
            SizedBox(height: 30),
            UpdateInputs()
          ],
        ));
  }
}

/////////////////////////////////CONTROL BUTTONS//////////////////////////////////////////////////////
