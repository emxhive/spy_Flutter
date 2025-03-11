import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spy/extensions/primitive_ext.dart';
import 'package:spy/helpers/firestore_helpers.dart';
import 'package:spy/widgets/general/widgets.dart';
import '../general/general_enums.dart';
import '../general/widget_functions.dart';
import 'home_helpers/classes_home.dart';
import 'muc/records_manual_updates.dart';

class BalanceW extends StatefulWidget {
  const BalanceW({super.key});

  @override
  State<BalanceW> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<BalanceW> {
  final PMB pmb = PMB();

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 2,
                      child: ListenableBuilder(
                          listenable: pmb,
                          builder: (context, child) {
                            BWP bwp = pmb.balanceWidgetPairs();
                            Cz selection = pmb.currentCz;

                            return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Available Balance",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Colors.black45),
                                  ),
                                  //--
                                  // --------------------------------------------------------------BALANCES

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      BWText([
                                        TextSpan(
                                            text: bwp.mainSign,
                                            style: GoogleFonts.inter(
                                                fontSize: 19)),
                                        TextSpan(
                                            text: bwp.main.format(),
                                            style: GoogleFonts.poppins(
                                                fontSize: 24,
                                                letterSpacing: 0.5))
                                      ]),
                                      CurrencySelector(
                                          onChanged: pmb.changeCurrency,
                                          selection: selection)
                                    ],
                                  ),

                                  BWText(
                                    [
                                      TextSpan(
                                        text:
                                            "≈ ${bwp.approxSign}${bwp.approx.format()}",
                                      ),
                                      WidgetSpan(child: SizedBox(width: 5)),
                                      TextSpan(text: "@${pmb.xrate}")
                                    ],
                                    style: GoogleFonts.inter(
                                        fontSize: 12, color: Colors.black26),
                                  ),
                                ]);
                          })),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            showBottomDialog(
                                context: context,
                                content: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 13),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Select Update Option",
                                            style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                BorderedTextButton(
                                                  Text("CSV Bulk Update"),
                                                  null,
                                                  onPress: () {
                                                    UTS().nw(UpdateOption.csv);
                                                    closeDialog();
                                                  },
                                                ),
                                                BorderedTextButton(onPress: () {
                                                  DCT().tidy();
                                                  UTS().nw(UpdateOption.manual);
                                                  MaterialPageRoute route =
                                                      nwRoutes(context,
                                                          UpdateTypeSelector());
                                                  Navigator.push(
                                                      context, route);
                                                }, Text("Manual Update"), null)
                                              ])
                                        ])));
                          },
                          onLongPress: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  TextEditingController controller =
                                      TextEditingController();

                                  return AlertDialog(
                                    titleTextStyle: GoogleFonts.poppins(
                                        fontSize: 18, color: Colors.black54),
                                    title: Text("Enter new rate"),
                                    content: TextField(
                                      textAlign: TextAlign.center,
                                      maxLength: 4,
                                      keyboardType: TextInputType.number,
                                      controller: controller,
                                    ),
                                    actions: [
                                      FilledButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            if (controller.text.isNotEmpty) {
                                              pmb.updateRate(
                                                  num.parse(controller.text));
                                            }
                                          },
                                          child: Text("Record"))
                                    ],
                                  );
                                });
                          },
                          child: const Text("Update"))
                    ],
                  ))
                ])));
  }
}

class CurrencySelector extends StatelessWidget {
  const CurrencySelector(
      {super.key, required this.onChanged, required this.selection});

  final ValueChanged<Cz?> onChanged;
  final Cz selection;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: DropdownButton(
            style: GoogleFonts.interTight(
                textStyle:
                    DefaultTextStyle.of(context).style.copyWith(fontSize: 12)),
            underline: SizedBox(),
            padding: EdgeInsets.only(top: 9, left: 2),
            isDense: true,
            items: (Cz.values
                .map((obj) => DropdownMenuItem(
                    value: obj, child: Text(obj.name.toUpperCase())))
                .toList()),
            value: selection,
            onChanged: onChanged));
  }
}

class UpdateTypeSelector extends StatelessWidget {
  const UpdateTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final UpdateOption opt = UTS().opt;
    switch (opt) {
      case UpdateOption.manual:
        return ManualUpdatePage();
      case UpdateOption.csv:
        return Container();
    }
  }

// @override
// State<StatefulWidget> createState() => UpdateTypeSelectorState();
}
