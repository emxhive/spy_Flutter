import 'package:flutter/material.dart';
import 'package:spy/widgets/general/widgets.dart';
import '../home_page/home_helpers/classes_home.dart';

///Bottom Dialog Thingy
Future<Object?> showBottomDialog({required context, required Widget content}) {
  return showGeneralDialog(
    pageBuilder: (BuildContext context, a1, a2) {
      return Container();
    },
    transitionDuration: Duration(milliseconds: 300),
    barrierDismissible: true,
    barrierLabel: "",
    context: context,
    transitionBuilder: (context, a1, a2, child) => SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(a1),
        child: BottomDialog(child: content)),
  ).then((v) => DCT().tidy());
}

///Close Dialog
void closeDialog() {
  Navigator.pop(DCT().context);
  DCT().tidy();
}


void navPop() {
  Navigator.pop(DCT().context);
  Navigator.pop(DCT().context);
  DCT().tidy();

}

MaterialPageRoute nwRoutes(BuildContext context, Widget widget) {
  return MaterialPageRoute(builder: (context) => widget);
}

Future showFullDialog({required context, child}) {
  DCT().nw(context);
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return child;
      }).then((v) => DCT().tidy());
}
