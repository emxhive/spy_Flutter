import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FireStorage {
  final _ref = FirebaseStorage.instance.ref();
  Reference? _trackRef;

  storeT(String path) async {
    File file = File(path);

    await _trackRef!.putFile(file);
  }

  getT(String path) async {
    final data = (await _trackRef!.getData());
    File(path).writeAsBytes(data as List<int>);
  }

  /////////////
  //////NONE OF YOUR BUSINESS
  ///////////
  static final _single = FireStorage._internal();

  factory FireStorage() => _single;

  FireStorage._internal() {
    _trackRef = _ref.child("backups/track_database.db");
  }
}
