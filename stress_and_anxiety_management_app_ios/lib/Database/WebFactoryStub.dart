import 'package:sqflite/sqflite.dart';

/// Native builds open the database through sqflite's own factory.
DatabaseFactory? webDatabaseFactory() => null;
