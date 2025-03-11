import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FFM {
  static csvExport(final String data) async {
    final directory =
        Directory("/storage/emulated/0/Documents/cashbook-exports.csv");
    // const platform = MethodChannel("com.emxhive.spy/csv-share");

    String path = p.join(directory.path);
    File file = File(path);
    file.writeAsString(data);
    // try {
    //   await platform
    //       .invokeMethod("shareCSV", <String, String>{"path": path}).then((v) {
    //     print(v);
    //   });
    // } on PlatformException catch (e) {
    //   print(e);
    // }
  }
}
