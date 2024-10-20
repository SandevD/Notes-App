import 'package:my_simple_note/models/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _notesTableName = "notes";
  final String _notesIdColumnName = "id";
  final String _notesContentColumnName = "content";
  final String _notesStatusColumnName = "status";

  DatabaseService._constructor();

  Future<Database> get database async {
    if(_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase()  async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version){
        db.execute(''' 
          CREATE TABLE $_notesTableName (
            $_notesIdColumnName INTEGER PRIMARY KEY,
            $_notesContentColumnName TEXT NOT NULL,
            $_notesStatusColumnName INTEGER NOT NULL
          )
        ''');
      }
    );
    return database;
  }

  void addNotes(
    String content,
  ) async {
    final db = await database;
    await db.insert(
      _notesTableName,
      {
        _notesContentColumnName: content,
        _notesStatusColumnName: 0,
      },
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final data = await db.query(
      _notesTableName,
      orderBy: 'id DESC',
    );
    List<Note> notes = data
        .map(
            (e) =>Note(
                id: e["id"] as int,
                status: e["status"] as int,
                content: e["content"] as String,
            ),
        )
        .toList();
    return notes;
  }

  Future<void> deleteDatabase(String databasePath) async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    await deleteDatabase(databasePath);
  }


  void updateNotes(
      int id,
      String content,
      ) async {
    final db = await database;
    await db.update(
      _notesTableName,
      {
        _notesContentColumnName: content,
        _notesStatusColumnName: 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}