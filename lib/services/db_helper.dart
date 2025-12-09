import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/report_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'ecopatrol_db.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        photoPath TEXT,
        latitude REAL,
        longitude REAL,
        status INTEGER,
        officerNotes TEXT,
        officerPhotoPath TEXT
      )
    ''');
  }


  Future<void> insertReport(ReportModel report) async {
    final db = await database;
    await db.insert('reports', report.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ReportModel>> getReports() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reports', orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return ReportModel.fromMap(maps[i]);
    });
  }

  Future<void> updateReport(ReportModel report) async {
    final db = await database;
    await db.update(
      'reports',
      report.toMap(),
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  Future<void> deleteReport(int id) async {
    final db = await database;
    await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}