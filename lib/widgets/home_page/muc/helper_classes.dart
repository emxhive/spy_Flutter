import 'package:flutter/material.dart';
import '../../general/general_enums.dart';

///ManualUpdates Objects
class MUO {
  final ManualUpdateOption mode;
  final DateTime date = DateTime.now();
  final String type;
  final num value;
  final String pmName;

  MUO(this.pmName,
      {required this.mode, required this.type, required this.value}) {
    MUM().updateProperty(MUProps.muList, key: hashCode, value: this);
  }
}

// Manual Updates --- Mother Objects
class MUM with ChangeNotifier {
  String _selectedWallet = "airtm";
  ManualUpdateOption _updateSelection = ManualUpdateOption.include;
  TextEditingController? _balController;
  TextEditingController? _frozenController;
  String _includeMode = TET.debit.name;
  final Map<int, MUO> _muoList = <int, MUO>{};
  int lastTime = DateTime.now().millisecondsSinceEpoch;

  Map<int, MUO> get muoList => _muoList;

  void clearList() {
    _muoList.clear();
  }

  recordTime() {
    lastTime = DateTime.now().millisecondsSinceEpoch;
  }

  bool notGhost() {
    return (DateTime.now().millisecondsSinceEpoch - lastTime) > 5000;
  }

  ///Assign values to TextControllers properties
  initTC() {
    _frozenController = TextEditingController();
    _balController = TextEditingController();
  }

  clearTC() {
    _frozenController!.clear();
    _balController!.clear();
  }

  disposeTC() {
    _frozenController?.dispose();
    _balController?.dispose();
  }

  getProperty(MUProps prop, {isList = false}) {
    task(ref) {
      if (isList) {
        return ref.values.toList();
      }
      return ref;
    }

    switch (prop) {
      case MUProps.sw:
        return task(_selectedWallet);
      case MUProps.us:
        return task(_updateSelection);
      case MUProps.im:
        return task(_includeMode);

      case MUProps.bCtrl:
        return task(_balController);

      case MUProps.fCtrl:
        return task(_frozenController);

      case MUProps.muList:
        return task(_muoList);
    }
  }

  removeLC(key, {all = false}) {
    if (all) {
      muoList.clear();
      disposeTC();
      return;
    }
    muoList.remove(key);
    notifyListeners();
    recordTime();
  }

  ///Mainly for updating Strings and stuff
  setProperty(MUProps prop, dynamic value) {
    switch (prop) {
      case MUProps.sw:
        _selectedWallet = value;
        break;
      case MUProps.us:
        _updateSelection = value;
        break;
      case MUProps.im:
        _includeMode = value;
        break;
      default:
        null;
    }
    notifyListeners();
  }

  ///Mainly for updating Lists
  updateProperty(MUProps prop, {int? key, value}) {
    task(ref) {
      if (key != null) {
        ref[key] = value;
      } else {
        ref.add(value);
      }
    }

    switch (prop) {
      case MUProps.muList:
        task(_muoList);
        break;
      default:
        null;
    }
    notifyListeners();
    recordTime();
  }

  static final MUM _single = MUM._internal();

  factory MUM() {
    return _single;
  }

  MUM._internal();
}

enum MUProps {
  sw,
  us,
  im,
  bCtrl,
  fCtrl,
  muList,
}
