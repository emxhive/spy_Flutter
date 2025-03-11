import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spy/extensions/primitive_ext.dart';
import 'package:spy/extensions/reference_ext.dart';
import 'package:spy/widgets/general/general_classes.dart';
import 'package:spy/widgets/general/widget_functions.dart';
import '../../helpers/firestore_helpers.dart';
import 'general_enums.dart';
import '../home_page/home_helpers/classes_home.dart';

class PMWText extends StatelessWidget {
  const PMWText(this.child,
      {super.key,
      this.isLight = true,
      this.isTitle = false,
      this.isAmount = false,
      this.style,
      this.max});

  final bool isLight;
  final TextStyle? style;
  final bool isTitle;
  final int? max;

  final String child;

  final bool isAmount;

  // final children;

  @override
  Widget build(BuildContext context) {
    String txt = child;
    String superscript = '';

    TextStyle normalText = style ??
        GoogleFonts.poppins(
            fontWeight: FontWeight.w300, fontSize: isAmount ? 15 : 14.2);

    TextStyle lightText = GoogleFonts.poppins(
        color: Colors.black26, fontSize: 11, fontWeight: FontWeight.w400);

    if (isTitle) {
      txt = child.toTitleCase(max);
      String? str = RegExp(r'(\d)').firstMatch(txt)?[0];
      if (str != null) {
        superscript = str;
        txt = txt.replaceFirst(superscript, '');
      }
    }

    return superscript.isEmpty
        ? Text(
            isAmount ? txt.formatAmt() : txt,
            style: isLight ? lightText : normalText,
          )
        : RichText(
            text: TextSpan(
                style:
                    TextStyle(color: DefaultTextStyle.of(context).style.color),
                children: [
                TextSpan(
                    text: txt,
                    style: style ??
                        normalText.copyWith(fontWeight: FontWeight.w600)),
                TextSpan(
                    text: superscript,
                    style: TextStyle(fontFeatures: [FontFeature.superscripts()])
                        .copyWith(color: style?.color)),
              ]));
  }
}

///Balance widget text
class BWText extends StatelessWidget {
  const BWText(this.widgetList, {super.key, this.style});

  final List<InlineSpan> widgetList;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(style: style, children: widgetList));
  }
}

class BottomDialog extends StatelessWidget {
  const BottomDialog({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    DCT().nw(context);
    return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        insetPadding: EdgeInsets.only(
            bottom: 0, top: MediaQuery.of(context).size.height * 1 / 3),
        alignment: Alignment.bottomCenter,
        child: child);
  }
}

class BorderedText extends StatelessWidget {
  const BorderedText(
    this.text,
    this.margin, {
    super.key,
  });

  final Widget text;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: margin ?? EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12, width: 0.5),
            borderRadius: BorderRadius.circular(10)),
        child: text);
  }
}

class BorderedTextButton extends StatelessWidget {
  const BorderedTextButton(this.text, this.margin,
      {super.key, required this.onPress});

  final Widget text;
  final EdgeInsets? margin;
  final GestureTapCallback onPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onPress,
      child: BorderedText(text, margin),
    );
  }
}

class IcoButton extends StatelessWidget {
  const IcoButton(
      {super.key,
      required this.icon,
      this.onPress,
      this.color,
      this.bgColor,
      this.size});

  final Icon icon;
  final VoidCallback? onPress;
  final Color? color;
  final Color? bgColor;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: ShapeDecoration(
          color: bgColor ?? Colors.purple, shape: CircleBorder()),
      child: IconButton(onPressed: onPress, icon: icon),
    );
  }
}

class BottomDropDown extends StatefulWidget {
  const BottomDropDown({
    super.key,
    required this.list,
    required this.manageState,
    this.logoList,
    required this.searchHint,
  });

  final List list;
  final Map<dynamic, dynamic>? logoList;
  final Function manageState;
  final String searchHint;

  @override
  State<StatefulWidget> createState() => _BDDState();
}

class _BDDState extends State<BottomDropDown> {
  var isInit = true;
  List list = [];
  String searchHint = "";
  List originList = [];
  Map<dynamic, dynamic>? logoList;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      searchHint = widget.searchHint;
      logoList = widget.logoList;
      list = widget.list;
      originList = widget.list;
      isInit = false;
    }
    return
        // alignment: Alignment.center,
        Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          onChanged: (value) {
            if (value.isNotEmpty) {
              var nwList = originList.where((el) =>
                  el.toLowerCase().toString().startsWith(value.toLowerCase()));

              var nwList2 = originList.where((el) =>
                  el.toLowerCase().toString().contains(value.toLowerCase()));

              setState(() {
                list = <dynamic>{...nwList, ...nwList2, ...list}.toList();
              });
            } else {
              setState(() {
                list = originList;
              });
            }
          },
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search_outlined,
                color: Colors.black45,
              ),
              suffixIcon: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  _controller.clear();
                  primaryFocus!.unfocus();
                },
                child: Icon(Icons.clear_outlined),
              ),
              labelText: searchHint),
        ),
        Flexible(
            child: ListView.builder(
                itemCount: list.length,
                padding: EdgeInsets.only(top: 15),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  String key = list[index];

                  return InkWell(
                      onTap: () {
                        closeDialog();
                        widget.manageState(key);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                            border: logoList != null
                                ? Border(
                                    bottom: BorderSide(
                                        width: 1, color: Colors.black12))
                                : null),
                        child: logoList != null
                            ? Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(PMD().pmLogos(key)),
                                    radius: 15,
                                  ),
                                  const SizedBox(width: 25),
                                  Text(key.toTitleCase())
                                ],
                              )
                            : BorderedTextButton(
                                Text(key.toTitleCase()), EdgeInsets.all(0),
                                onPress: () {
                                closeDialog();
                                widget.manageState(key);
                              }),
                      ));
                })),
        SizedBox(height: 10)
      ],
    );
  }
}

class MXInput extends StatelessWidget {
  const MXInput(this.label,
      {super.key,
      this.inputType = MXInputTypes.text,
      this.dropDownObjs,
      required this.prefixChildren,
      this.style,
      this.isTop = true,
      this.textController,
      this.formatter,
      this.keyboardType});

  final MXInputTypes inputType;

  final TextInputType? keyboardType;
  final DDO? dropDownObjs;
  final String label;
  final List<Widget> prefixChildren;
  final TextStyle? style;
  final bool isTop;
  final TextEditingController? textController;
  final List<TextInputFormatter>? formatter;

  @override
  Widget build(BuildContext context) {
    var txtField = TextField(
        keyboardType: keyboardType,
        maxLength: dropDownObjs == null ? 10 : null,
        controller: textController,
        inputFormatters: [if (formatter != null) ...formatter!],
        style: style ?? DefaultTextStyle.of(context).style,
        readOnly: dropDownObjs != null ? true : false,
        onTap: () {
          if (dropDownObjs != null) {
            showBottomDialog(
                context: context,
                content: BottomDropDown(
                  searchHint: dropDownObjs!.searchHint,
                  list: dropDownObjs!.list,
                  manageState: dropDownObjs!.stateManager,
                  logoList: dropDownObjs!.logoList,
                ));
          }
        },
        decoration: InputDecoration(
          hintText: dropDownObjs != null ? label.toTitleCase() : null,
          border: OutlineInputBorder(),
          prefixIcon: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.only(right: isTop ? 0 : 10),
              decoration: BoxDecoration(
                  border: isTop
                      ? null
                      : Border(
                          right: BorderSide(width: 1, color: Colors.black26))),
              child: isTop
                  ? prefixChildren[0]
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: prefixChildren,
                    )),
          suffixIcon: dropDownObjs != null
              ? Icon(Icons.keyboard_arrow_down_rounded)
              : null,
        ));
    return isTop
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(label), txtField],
          )
        : txtField;
  }
}

///Sized Box Width --- width is sized by percentage , pass numerator to [percentage] like pass 20 -->  for 20%
class SBW extends StatelessWidget {
  const SBW(this.percentage, this.child, {super.key, this.align});

  final Widget child;
  final num percentage;

  final AlignmentGeometry? align;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * (percentage / 100),
        child: Align(
          alignment: align ?? Alignment.center,
          child: child,
        ));
  }
}

class DatePickerRange extends StatelessWidget {
  const DatePickerRange(
      {super.key,
      this.decoration,
      required this.startController,
      required this.endController,
      required this.pickerManager});

  final Decoration? decoration;
  final TextEditingController startController;
  final TextEditingController endController;
  final Function pickerManager;

  Widget _textField(helperText, context, [isStart = true]) {
    TextEditingController controller =
        isStart ? startController : endController;

    return TextField(
      onTap: () => showDatePicker(
              helpText: helperText,
              initialDate: controller.text.toDate(),
              context: context,
              firstDate:
                  isStart ? DateTime(2024) : startController.text.toDate(),
              lastDate: DateTime.now())
          .then((value) {
        if (value != null) {
          String id = value.dayId;

          ///If a start date is picked after the current end, need to update the end likewise
          String? fakeEnd;
          if (id != controller.text) {
            if (isStart) {
              if (id.toDate().isAfter(endController.text.toDate())) {
                DateTime future = id.toDate().add(Duration(days: 61));
                DateTime now = DateTime.now();
                fakeEnd = future.isAfter(now) ? now.dayId : future.dayId;
                endController.text = fakeEnd;
              }
            }
            isStart
                ? pickerManager(start: id, end: fakeEnd)
                : pickerManager(end: id);
            controller.text = id;
          }
        }
      }),
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: Colors.black38,
      ),
      decoration: InputDecoration(border: InputBorder.none),
      readOnly: true,
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: DecoratedBox(
            decoration: decoration ??
                BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.black12, width: 0.7),
                    borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Expanded(child: _textField("CHOOSE START DATE", context)),
              Icon(
                Icons.arrow_right_alt_rounded,
                color: Colors.black54,
              ),
              Expanded(child: _textField("CHOOSE END DATE", context, false))
            ])));
  }
}
