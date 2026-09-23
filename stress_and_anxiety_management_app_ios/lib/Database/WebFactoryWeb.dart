import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// sqlite compiled to WebAssembly, stored in the browser's IndexedDB. Needs
/// `web/sqlite3.wasm` and `web/sqflite_sw.js`, which
/// `dart run sqflite_common_ffi_web:setup` writes.
DatabaseFactory? webDatabaseFactory() => databaseFactoryFfiWeb;
