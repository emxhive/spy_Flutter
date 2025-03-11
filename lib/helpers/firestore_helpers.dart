import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spy/extensions/primitive_ext.dart';
import 'package:spy/extensions/reference_ext.dart';
import 'package:spy/helpers/firestore_write.dart';
import '../widgets/home_page/home_helpers/classes_home.dart';
import '../widgets/home_page/muc/helper_classes.dart';
import '../widgets/track_page/track_helpers/classes_track.dart';
import '../widgets/general/general_enums.dart';
import 'file_manager.dart';

///Payment Method Data class
///
/// This fetches the data from firestore and creates variables to store the important ones like 'pmstate' and 'pmicons'
/// as [pmData] and [pmLogos] respectively.
/// The goal is to avoid calling the database and running unnecessary functions repeatedly
class PMD with ChangeNotifier, FSB {
  final TD td = TD();
  final String usSign = "\$";
  final String ngSign = "₦";

  bool firstRecord = true;

  final Map<String, dynamic> _pmData = <String, dynamic>{};
  final Map<String, dynamic> _pmLogos = <String, dynamic>{};
  final Map<String, PMC> _pmcList = <String, PMC>{};

  Iterable<PMC> get pmcValues => _pmcList.values;

  pmData(String key, [dynamic value]) {
    if (value != null) {
      _pmData[key] = value;
    } else {
      return _pmData[key];
    }
  }

  pmLogos(String key, [dynamic value]) {
    if (value != null) {
      _pmLogos[key] = value;
    } else {
      return _pmLogos[key];
    }
  }

  pmcList(String key, [PMC? value]) {
    if (value != null) {
      _pmcList[key] = value;
    } else {
      return _pmcList[key];
    }
  }

  export() {
    DateTime now = DateTime.now();
    num r = PMB().xrate;
    String result = "Date, Time, Remark, Category, Mode, In, Out \n";
    for (final PMC(
          rateDiff: diff,
          id: id,
          available: av,
          equivalent: eq,
          isUsd: zUs
        ) in _pmcList.values) {
      if (av > 0) {
        result +=
            "${now.dateCb}, ${now.time12}, ${zUs ? '\$$av@${r + diff} ' : ''}, Existing, ${id.replaceFirst(RegExp('[0-9]'), '')}, ${zUs ? eq : av}, \n ";
      }
    }

    FFM.csvExport(result);
  }

  var _pmKeys = [];

  sortKeys() {
    _pmKeys.sort((a, b) {
      PMC ap = _pmcList[b]!;
      PMC bp = _pmcList[a]!;

      int first = (ap.available > 0).compareTo(bp.available > 0);

      int second = ap.isUsd.compareTo(bp.isUsd);

      int third = (ap.isUsd ? ap.available : ap.availableEq)
          .compareTo((bp.isUsd ? bp.available : bp.availableEq));

      ////////////FOR THE SECOND : START/////////
      Cz cz = PMB().currentCz;
      if (cz case Cz.ngn) {
        second = -second;
      } else if (cz case Cz.unn) {
        second = 0;
      }
      //////////FOR THE SECOND : END /////////////

      return first == 0 ? (second == 0 ? third : second) : first;

      // second == 0 ? third : second;
    });
  }

  get pmKeys => _pmKeys.toList();

  ///Idea is to notify both [PMB] and [PMC] classes and even rearrange the payment methods
  void rebuild() {
    sortKeys();
    notifyListeners();
    PMB().notifyListeners();
  }

  void refreshData() {
    init().then((value) => {
          if (value) {PMB().notifyListeners(), notifyListeners()}
        });
  }

  ///Though inconspicuous [TDM.record] is called here at the end in [PMC.update]
  void localUpdate(Iterable<MUO> muoList) {
    Map<String, TPMC> list = {};
    TDM tdm = TDM();

    for (var muo in muoList) {
      list.putIfAbsent(muo.pmName, () => TPMC(muo.pmName));
      var pm = list[muo.pmName];

      ///Propagate Expenses
      propExp(int i) {
        String id = muo.date.dayId;
        EC ec = tdm.tdr(id, true)!.ec;
        ec.join(_pmcList[muo.pmName]!, i, muo.value);
      }

      switch (muo.mode) {
        case ManualUpdateOption.include:
          switch (muo.type) {
            case "expCredit":
              pm?.balance += muo.value;
              propExp(0);
              break;
            case "expDebit":
              pm?.balance -= muo.value;
              propExp(1);
              break;
            case "credit":
              pm?.balance += muo.value;
              break;
            case "debit":
              pm?.balance -= muo.value;
              break;
          }
        case ManualUpdateOption.replace:
          if (muo.type.toLowerCase().contains("mia")) {
            pm?.frozen = muo.value;
          } else {
            pm?.balance = muo.value;
          }
          break;
      }
    }

    Map<String, dynamic> fsMap = <String, dynamic>{};
    list.forEach((String key, tmp) {
      fsMap[key] = {"frozen": tmp.frozen, "balance": tmp.balance};
      _pmcList[key]?.update(tmp.balance, tmp.frozen);
    });
    Write().updatePM(fsMap);
  }

  Future<bool> init() async {
    var dataTemps =
        await FirebaseFirestore.instance.doc(pmInfo).get().then((value) {
      return value.data()!;
    });

    var logoTemps =
        await FirebaseFirestore.instance.doc(pmIcons).get().then((value) {
      return value.data()!;
    });

    return Future.delayed(const Duration(seconds: 1), () {
      if (logoTemps.isNotEmpty && dataTemps.isNotEmpty) {
        _pmData.clear();
        _pmData.addAll(dataTemps);
        PMB().xrate = dataTemps["generalProps"]["rate"];
        _pmLogos.clear();
        _pmLogos.addAll(logoTemps);

        _prepForWidgets();
        PMB().calcBalances();
        sortKeys();

        return true;
      } else {
        return false;
      }
    });
  }

  ///Prepares the [PMC] Instance List right at init stage, as well as they Key List
  void _prepForWidgets() {
    _pmKeys = _pmData.keys.toList();
    _pmKeys.remove("generalProps");
    for (String key in _pmKeys) {
      PMC(_pmData[key], key);
    }
  }

  ///Calculates the balances,

  ///END OF VARIABLE CLASS FIELD

  static final PMD _single = PMD._internal();

  factory PMD() {
    return _single;
  }

  PMD._internal();
}

///Payment Method Net Balances Manager
class PMB with ChangeNotifier {
  num xrate = 1700;
  num _usBal = 0;
  num _ngBal = 0;
  num _netUsBal = 0;
  num _netNgBal = 0;

  num _gUsBal = 0;
  num _gNgBal = 0;
  num _grossUsBal = 0;
  num _grossNgBal = 0;

  num get grossUsBal => _grossUsBal;

  num get grossNgBal => _grossNgBal;

  num get usBal => _usBal;

  num get ngBal => _ngBal;

  num get netNgBal => _netNgBal;

  num get netUsBal => _netUsBal;

  Cz currentCz = Cz.unn;

  changeCurrency(Cz? cz) {
    PMD pmd = PMD();
    currentCz = cz ?? Cz.unn;
    pmd.sortKeys();
    pmd.notifyListeners();
    notifyListeners();
  }

  void calcBalances() {
    _usBal = 0;
    _netNgBal = 0;
    _ngBal = 0;
    _netUsBal = 0;

    _gUsBal = 0;
    _gNgBal = 0;
    _grossUsBal = 0;
    _grossNgBal = 0;

    for (var pmc in PMD().pmcValues) {
      pmc.initFxns();
      if (pmc.isUsd) {
        _usBal += pmc.available;
        _netNgBal += pmc.availableEq;
        _gUsBal += (pmc.balance - pmc.frozen);
        _grossNgBal += pmc.equivalent;
      } else {
        _ngBal += pmc.available;
        _netUsBal += pmc.availableEq;
        _gNgBal += (pmc.balance - pmc.frozen);
        _grossUsBal += pmc.equivalent;
      }
    }
    _netUsBal += usBal;
    _netNgBal += ngBal;
    _grossNgBal += _gNgBal;
    _grossUsBal += _gUsBal;

    PMD().td.init();
    if (!PMD().firstRecord) {
      TDM().record();
    }
  }

  BWP balanceWidgetPairs() {
    switch (currentCz) {
      case Cz.ngn:
        return BWP(main: ngBal, approx: ngBal / xrate);
      case Cz.usd:
        return BWP(main: usBal, approx: xrate * usBal);
      default:
        return BWP(main: netUsBal, approx: netNgBal);
    }
  }

  updateRate(num nr) {
    if (nr > 100) {
      xrate = nr;
      calcBalances();
      notifyListeners();
      Write().xrate(nr);
    }
  }

  ///END OF NOTEWORTHY CLASS FIELD

  static final PMB _single = PMB._internal();

  factory PMB() {
    return _single;
  }

  PMB._internal();
}
