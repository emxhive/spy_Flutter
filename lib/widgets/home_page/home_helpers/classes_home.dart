import 'package:flutter/material.dart';
import '../../../helpers/firestore_helpers.dart';
import '../../general/general_enums.dart';
import '../../general/general_functions.dart';

//Payment Method Class Functions for the table PMView Widget thingy
///we'll be able to pass the object/Map into the constructor and be able to get
/// the properties.
/// Like [PMO(map).balance]
/// Each payment method has it's own instance
class PMC {
  PMB pmb = PMB();

  PMC(pmMap, this.key) {
    id = pmMap["id"];
    balance = pmMap["balance"];
    frozen = pmMap["frozen"];
    isUsd = pmMap["isUsd"];
    ispm = pmMap["ispm"];
    percentFee = pmMap["percentFee"];
    rateDiff = pmMap["rateDiff"];
    spend = pmMap["spend"];
    symbol = pmMap["symbol"];

    initFxns();
    PMD().pmcList(key!, this);
  }

  Map<String, dynamic> toMap() {
    var pmMap = <String, dynamic>{};
    pmMap["balance"] = balance;
    pmMap["id"] = id;

    pmMap["frozen"] = frozen;
    pmMap["isUsd"] = isUsd;
    pmMap["ispm"] = ispm;
    pmMap["percentFee"] = percentFee;
    pmMap["rateDiff"] = rateDiff;
    pmMap["spend"] = spend;
    pmMap["symbol"] = symbol;
    pmMap["name"] = key;
    pmMap["date"] = date.millisecondsSinceEpoch;

    return pmMap;
  }

  String? key;
  String id = '';
  num balance = 0;
  num frozen = 0;
  bool isUsd = false;
  bool ispm = true;
  num percentFee = 0;
  num rateDiff = 0;
  num spend = 0;
  String symbol = "";
  DateTime date = DateTime.now();

  num fee = 0;
  num availableEq = 0;
  num equivalent = 0;
  num available = 0;

  void initFxns() {
    potFee();
    availBalance();
    equiv();
  }

  void update(bal, frz) {
    balance = bal;
    frozen = frz;
    initFxns();
    PMB().calcBalances();
  }

  ///Returns the Potential Fee
  void potFee() {
    if (percentFee > 0) {
      fee = xp(percentFee, balance, 0);
    }
  }

  ///Returns available usable Balance
  void availBalance() {
    available = balance - frozen - fee;
  }

  ///Returns the equivalent of the [available] field for current instance of [PMC]
  void equiv() {
    var rate = pmb.xrate + rateDiff;
    if (isUsd) {
      availableEq = available * rate;
      equivalent = (balance - frozen) * rate;
    } else {
      equivalent = (balance - frozen) / rate;
      availableEq = available / rate;
    }
  }
}

///Temporary payment method class, for updating PMD frm MUOs
class TPMC {
  TPMC(String key) {
    PMD pmd = PMD();
    frozen = pmd.pmcList(key)?.frozen ?? 0;
    balance = pmd.pmcList(key)?.balance ?? 0;
  }

  num frozen = 0;
  num balance = 0;
}

///Balance Widget Pairs
class BWP {
  PMD pmd = PMD();

  BWP({required this.main, required this.approx}) {
    signIt();
  }

  //main Balance
  final num main;

  //The balance beneath --approximate balance
  final num approx;

  String mainSign = "";
  String approxSign = "";

  void signIt() {
    switch (PMB().currentCz) {
      case Cz.ngn:
        mainSign = pmd.ngSign;
        approxSign = pmd.usSign;
        break;
      default:
        approxSign = pmd.ngSign;
        mainSign = pmd.usSign;
    }
  }
}

///Dialog Context Tracker
class DCT {
  static final DCT _single = DCT._internal();

  factory DCT() {
    return _single;
  }

  final Map<int, BuildContext> _context = {};

  nw(context) {
    _context.putIfAbsent(context.hashCode, () {
      return context;
    });
  }

  BuildContext get context {
    var ct = _context.values.last;
    while (_context.length > 1) {
      if (ct.mounted) {
        return ct;
      } else {
        _context.remove(ct.hashCode);
        ct = _context.values.last;
      }
    }

    return ct;
  }

  tidy() {
    if (!_context.values.last.mounted) {
      _context.remove(_context.values.last.hashCode);
    }
  }

  DCT._internal();
}

class UTS with ChangeNotifier {
  static final UTS _single = UTS._internal();

  factory UTS() {
    return _single;
  }

  UTS._internal();

  UpdateOption _uts = UpdateOption.manual;

  UpdateOption get opt => _uts;

  nw(UpdateOption opt) {
    _uts = opt;
    // notifyListeners();
  }
}
