import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spy/extensions/primitive_ext.dart';
import 'package:spy/extensions/reference_ext.dart';
import 'package:spy/helpers/firestorage_helpers.dart';
import 'package:spy/widgets/track_page/track_helpers/classes_track.dart';
import 'package:sqflite/sqflite.dart';
import '../widgets/general/global_variables.dart';
import '../widgets/track_page/track_helpers/classes_track_two.dart';

class DB {
  Database? _trackDB;

  // ignore: unused_field
  Database? _historyDB;

  init() async {
    final String trackQuery =
        "CREATE TABLE track(id INTEGER PRIMARY KEY, expenses TEXT, income TEXT, xrate REAL, us REAL, ng REAL, nus REAL, nng REAL)";
    final String historyQuery =
        "CREATE TABLE history(date INTEGER PRIMARY KEY, balance REAL,frozen REAL, isUsd INTEGER, id TEXT)";

    _trackDB =
        await openDatabase(join(await getDatabasesPath(), "track_database.db"),
            onCreate: (db, version) {
      return db.execute(
        trackQuery,
      );
    }, version: 1);

    _historyDB = await openDatabase(
        join(await getDatabasesPath(), "history_database.db"),
        onCreate: (db, version) {
      return db.execute(
        historyQuery,
      );
    }, version: 1);
  }

  ///Get last 26 weeks worth or [range] List. The Strings in the range are dayIDs of the selected range from track page
  Future<Map<String, TDR>> getTrack([List<String>? range]) async {
    int start =
        DateTime.now().subtract(Duration(days: 183)).millisecondsSinceEpoch;
    int end = DateTime.now().millisecondsSinceEpoch;
    if (range != null) {
      start = range[0].toDate().millisecondsSinceEpoch;
      end = range[1].toDate().millisecondsSinceEpoch + 86399000;
    }

    final pref = await SharedPreferences.getInstance();

    int? res1 = pref.getInt(prStartKey);
    int? res2 = pref.getInt(prEndKey);
    if (res1 != start) {
      pref.setInt(prStartKey, start);
    }

    if (res2 != start) {
      pref.setInt(prEndKey, end);
    }
    String whereQuery = "id >=? AND id <=? ";

    var result = await _trackDB
        ?.query("track", where: whereQuery, whereArgs: [start, end]);

    return <String, TDR>{
      for (var map in result!)
        DateTime.fromMillisecondsSinceEpoch(map['id'] as int).dayId: TDR(
            DateTime.fromMillisecondsSinceEpoch(map['id'] as int).dayId,
            ec: EC().fromString(map['expenses'] as String),
            pnl: PLC().fromString(map['income'] as String),
            pmdc: PMDC.fromMap(map))
    };
  }

  addTrack(Map<String, dynamic> map) async {
    await _trackDB?.insert("track", map,
        conflictAlgorithm: ConflictAlgorithm.replace);

    FireStorage().storeT(_trackDB!.path);
  }

  ///Obtains the last record as this will be used to determine pnl for [TDM.balState]
  getLastTrack() async {
    var balState = [PMDC(), PMDC()];
    var result = await _trackDB?.rawQuery(
        "SELECT xrate,us,ng,nus,nng FROM track ORDER BY id DESC LIMIT 1");
    if (result != null && result.isNotEmpty) {
      balState.rep(PMDC.fromMap(result.first));
    }

    return balState;
  }

  ////////////////////////////////////////////
  //////////////////BACK UP & RESTORE -->> Basically local storage handlers
  ///////////////////////////////////////////

  restoreT() async {
    FireStorage().getT(_trackDB!.path);
  }

/////////////////////////////////////////////////////////
////HISTORY IMPLEMENTATIONS
//////////////////////////////////////////////////////

////None of your concern
  static final DB _single = DB._internal();

  DB._internal();

  factory DB() {
    return _single;
  }
}
