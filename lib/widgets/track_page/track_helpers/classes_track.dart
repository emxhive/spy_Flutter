import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spy/extensions/primitive_ext.dart';
import 'package:spy/extensions/reference_ext.dart';
import 'package:spy/helpers/firestore_helpers.dart';
import 'package:spy/helpers/sqflite_manager.dart';
import 'package:spy/widgets/general/global_variables.dart';
import 'package:spy/widgets/track_page/track_helpers/enums_track.dart';
import '../../home_page/home_helpers/classes_home.dart';
import 'classes_track_two.dart';

///Track Data Control Panel
class TDC with ChangeNotifier {
  Periods? mainEraSelection;

  mainEra(Periods? era) {
    TDM tdm = TDM();
    mainEraSelection = era;

    if (!_eraChanged) {
      eraChanged = true;
      tdm.copyToStore();
    }
    tdm.genByMainEra();
    tdm.notifyListeners();
  }

  bool _eraChanged = false;

  get eraChanged => _eraChanged;

  set eraChanged(v) {
    _eraChanged = v;
  }

  //Date controllers text
  String eraStart = DateTime.now().subtract(Duration(days: 183)).dayId;
  String eraEnd = DateTime.now().dayId;

  selectEra({String? start, String? end}) {
    if (start != null) eraStart = start;
    if (end != null) eraEnd = end;
    _eraChanged = true;
    TDM().genByEra();
  }

/////BORING STUFF
  static final TDC _single = TDC._internal();

  ///Track Data Control Panel
  factory TDC() {
    return _single;
  }

  TDC._internal();
}

///Track Data --- Mother Objects/Managers
class TDM with ChangeNotifier {
  final TDC _tdc = TDC();
  static final _td = PMD().td;

  bool _tempIsNotReal = false;
  bool allowRecord = true;
  bool _tempFirstRun = true;

  final List<PMDC> balState = _td.balState;
  final Map<String, TDR> _tdr = _td.tdr;

  Map<String, TDR> _tempTdr = {};
  Map<String, TDR> _storeTdr = {};

  Iterable<MapEntry<String, TDR>> _tdrCopy = [];

  Iterable<TDR> get tdrList => _tdc._eraChanged ? _tempTdr.values : _tdr.values;

  Iterable<String> get tdrKeys => _tdc._eraChanged ? _tempTdr.keys : _tdr.keys;

  ///[exclusive] if you're trying exclusively to fetch [_tdr] for update purposes like in [PMD.localUpdate]
  TDR? tdr(String id, [bool exclusive = false]) {
    if (exclusive) {
      if (!_tdr.containsKey(id) && id.toDate().isToday) {
        ///Strictly  for adding TDR for new days
        _tdr[id] = TDR(id, ec: EC(), pnl: PLC(), pmdc: PMDC());
      }
      return _tdr[id];
    }
    return _tdc._eraChanged ? _tempTdr[id] : _tdr[id];
  }

  genByEra() async {
    final prefs = await SharedPreferences.getInstance();
    int lastStart = prefs.getInt(prStartKey)!;
    int lastEnd = prefs.getInt(prEndKey)!;

    _tempTdr = {};

    if (lastStart != TDC().eraStart.toDate().millisecondsSinceEpoch ||
        lastEnd != TDC().eraEnd.toDate().millisecondsSinceEpoch) {
      await loadTrack([TDC().eraStart, TDC().eraEnd], true);
    }
  }

  copyToStore([entries]) {
    _storeTdr = Map.fromEntries(entries ?? _tdr.entries);
  }

  _notNull(cases) {
    if (_tempIsNotReal && _storeTdr.isNotEmpty) {
      _tempTdr = _storeTdr;
    }

    if (_tempFirstRun) {
      _tempTdr = _storeTdr;
      _tempFirstRun = false;
    }

    _tdrCopy = _tdc._eraChanged ? _tempTdr.entries : _tdr.entries;
    if (_storeTdr.isEmpty) {
      copyToStore(_tdrCopy);
    }

    var lMap = <String, TDR>{};

    for (final MapEntry(key: id, value: TDR(ec: ec, pnl: pnl, pmdc: pmdc))
        in _tdrCopy) {
      var arr = id.split("-");
      String date = "";

      switch (cases) {
        case Periods.year:
          date = "${arr[0]}-12-31";
          break;
        case Periods.month:
          date = "${arr[0]}-${arr[1]}-28";
          break;
        case Periods.week:
          String day = ((int.parse(arr[2]) / 8).truncate() + 1)
              .toString()
              .padLeft(2, '0');
          date = "${arr[0]}-${arr[1]}-$day";
          break;
      }
      if (lMap[date] == null) {
        TDR? last = lMap.values.lastOrNull;
        if (last != null) {
          last.pmdc = tdr(last.dayId)!.pmdc;
        }
        lMap[date] = TDR(id, ec: EC(), pnl: PLC(), pmdc: pmdc);
      }
      TDR? last = lMap.values.lastOrNull;
      if (last != null) {
        last.pmdc = tdr(last.dayId)!.pmdc;
      }

      TDR t = lMap[date]!;
      t.dayId = id;
      t.ec.combine(ec);
      t.pnl.combine(pnl);
    }

    TDR? last = lMap.values.lastOrNull;
    if (last != null) {
      last.pmdc = tdr(last.dayId)!.pmdc;
    }
    _tempTdr = lMap;
    _tempIsNotReal = true;
  }

  genByMainEra() {
    switch (_tdc.mainEraSelection) {
      case null:
        _tempTdr = _storeTdr;
        _storeTdr = {};
        break;
      default:
        _notNull(_tdc.mainEraSelection);
    }
  }

  loadTrack(List<String> range, [bool refresh = false]) async {
    _tempTdr = await DB().getTrack(range);
    if (refresh) notifyListeners();
  }

  pnl() {
    String id = DateTime.now().dayId;
    PLC plc = tdr(id, true)!.pnl;
    plc.join(balState.last.netUsBal - balState.first.netUsBal,
        balState.last.netNgBal - balState.first.netNgBal);
  }

  record() {
    final PMD pmd = PMD();

    if (pmd.firstRecord) {
      pmd.firstRecord = false;
    }
    balState.rep(PMDC());
    if ((balState.last.netUsBal - balState.first.netUsBal) != 0 ||
        (balState.last.netNgBal - balState.first.netNgBal) != 0) {
      var pmdc = balState.last;

      pnl();

      TDR tdrr = tdr(DateTime.now().dayId, true)!;
      tdrr.pmdc = pmdc;
      var map = pmdc.toMap();
      map.addAll({
        "expenses": tdrr.ec.toString(),
        "id": DateTime.now().millisecondsSinceEpoch,
        "income": tdrr.pnl.toString()
      });
      DB().addTrack(map);
    }
  }

  ////😪NOT YOUR CONCERN
  static final TDM _single = TDM._internal();

  factory TDM() {
    return _single;
  }

  TDM._internal();
}

///Simply for the initiation process
class TD {
  Map<String, TDR> tdr = {};
  List<PMDC> balState = [];
  static bool alreadyRan = false;

  init() async {
    if (!alreadyRan) {
      //////////////////////////
      //////////INIT TDR
      ////////////////////////////
      Map<String, TDR> list = await DB().getTrack();

      ///Day Id
      String did = DateTime.now().dayId;
      var resMap = <String, TDR>{
        did: TDR(did, ec: EC(), pnl: PLC(), pmdc: PMDC())
      };

      if (list.isNotEmpty) {
        resMap = list;
      }
      tdr = resMap;

      ///////////////////////////
      ////////////INIT balState
      ///////////////////////////

      var list1 = await DB().getLastTrack();
      balState = list1;
      alreadyRan = true;
    }
  }
}

///Track Currency Manager
class TCM with ChangeNotifier {
  ///Display currency
  bool _dcIndicator = true;

  get zUS => _dcIndicator;

  get dc => _dcIndicator ? PMD().usSign : PMD().ngSign;

  changeDc() {
    _dcIndicator = !_dcIndicator;
    notifyListeners();
    TDM().notifyListeners();
  }

  ////😪NOT YOUR CONCERN
  static final TCM _single = TCM._internal();

  factory TCM() {
    return _single;
  }

  TCM._internal();
}

///Payment method data class -- i don't remember but it stores the current state PM wise for TRACK DB
class PMDC {
  PMDC() {
    PMB pmb = PMB();
    xrate = pmb.xrate;
    // usBal = pmb.usBal;
    // ngBal = pmb.ngBal;
    usBal = pmb.netUsBal;
    ngBal = pmb.netNgBal;
    // netNgBal = pmb.netNgBal;
    // netUsBal = pmb.netUsBal;
    netNgBal = pmb.grossNgBal;
    netUsBal = pmb.grossUsBal;
  }

  late num xrate;
  late num usBal;

  late num ngBal;
  late num netUsBal;
  late num netNgBal;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["xrate"] = xrate;
    map["us"] = usBal;
    map["ng"] = ngBal;
    map["nus"] = netUsBal;
    map["nng"] = netNgBal;

    return map;
  }

  PMDC.fromMap(map) {
    xrate = map["xrate"];
    usBal = map["us"];
    ngBal = map["ng"];
    netUsBal = map["nus"];
    netNgBal = map["nng"];
  }
}

//Financial
mixin FM {
  num us = 0;
  num ng = 0;
  PMB pmb = PMB();

  @override
  String toString() {
    return [us, ng].join("_");
  }

  combine(fm) {
    us += fm.us;
    ng += fm.ng;
  }

  fromString(String fm) {
    List vals = fm.split("_");
    us = num.parse(vals[0]);
    ng = num.parse(vals[1]);

    return this;
  }
}

///Expenses Class
class EC with FM {
  mix(num usd, num ngn) {
    us += usd;
    ng += ngn;
  }

  join(PMC pm, dir, value) {
    pmb = PMB();
    num u;
    num n;

    if (pm.isUsd) {
      u = value;
      n = pmb.xrate * u;
    } else {
      n = value;
      u = n / pmb.xrate;
    }
    switch (dir) {
      case 0:
        us -= u;
        ng -= n;
        break;
      case 1:
        us += u;
        ng += n;
        break;
    }
  }
}

///PNL Class
class PLC with FM {
  join(num usd, num ngn) {
    us += usd;
    ng += ngn;
  }
}
