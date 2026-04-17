import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;

class DatabaseInit{
  ///
  /// SINGLETON
  ///
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await init();
    return _database!;
  }

  ///
  /// INIT FUNCTION - RETURNS DB OBCJET AND CREATE IT IF NOT EXIST
  ///
  Future<Database> init() async{
    try{

      final String databaseLocation = await getDatabasesPath();

      final String databasePath = join(databaseLocation, "database.db");
      
      return await openDatabase(
        databasePath,
        version: 1,
        onCreate: (Database db, int version) async{

          final String schema = await rootBundle.loadString('assets/schema.sql');
          
          final List<String> commands = schema.split(';');
          
          for (String command in commands) {
            if (command.trim().isNotEmpty){
              await db.execute(command);
            }
          }
          log("Database created succesfully");
        }
      );
    }
    catch(e){
      throw Exception(e);
    }
  }
}