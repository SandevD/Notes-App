import 'package:my_simple_note/models/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _notesTableName = "notes";
  final String _notesIdColumnName = "id";
  final String _notesTitleColumnName = "title";
  final String _notesContentColumnName = "content";
  final String _notesStatusColumnName = "status";
  final String _createdAtColumnName = "created_at";
  final String _updatedAtColumnName = "updated_at";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        // Create the table
        await db.execute('''
        CREATE TABLE $_notesTableName (
          $_notesIdColumnName INTEGER PRIMARY KEY,
          $_notesTitleColumnName TEXT NOT NULL,
          $_notesContentColumnName TEXT NOT NULL,
          $_notesStatusColumnName INTEGER NOT NULL,
          $_createdAtColumnName TEXT NOT NULL,
          $_updatedAtColumnName TEXT NOT NULL
        )
      ''');

        // Insert initial dummy data
        final timestamp = DateTime.now().toIso8601String();
        await db.insert(_notesTableName, {
          _notesTitleColumnName: "Shopping List",
          _notesContentColumnName: "Milk, Bread, Eggs, Butter",
          _notesStatusColumnName: 0,
          _createdAtColumnName: timestamp,
          _updatedAtColumnName: timestamp,
        });
        await db.insert(_notesTableName, {
          _notesTitleColumnName: "Workout Plan",
          _notesContentColumnName: "Push-ups, Squats, Running",
          _notesStatusColumnName: 0,
          _createdAtColumnName: timestamp,
          _updatedAtColumnName: timestamp,
        });
        await db.insert(_notesTableName, {
          _notesTitleColumnName: "Meeting Notes",
          _notesContentColumnName: "Discuss Q4 targets and strategies",
          _notesStatusColumnName: 0,
          _createdAtColumnName: timestamp,
          _updatedAtColumnName: timestamp,
        });
        await db.insert(_notesTableName, {
          _notesTitleColumnName: "Books to Read",
          _notesContentColumnName: "Atomic Habits, 1984, Brave New World",
          _notesStatusColumnName: 0,
          _createdAtColumnName: timestamp,
          _updatedAtColumnName: timestamp,
        });
        await db.insert(_notesTableName, {
          _notesTitleColumnName: "Recipe",
          _notesContentColumnName: "2 cups of flour, 1 cup of sugar, ...",
          _notesStatusColumnName: 0,
          _createdAtColumnName: timestamp,
          _updatedAtColumnName: timestamp,
        });
      },
    );
    return database;
  }

  void addNotes(
    String title,
    String content,
  ) async {
    final db = await database;
    final timestamp = DateTime.now().toIso8601String();
    await db.insert(
      _notesTableName,
      {
        _notesTitleColumnName: title,
        _notesContentColumnName: content,
        _notesStatusColumnName: 0,
        _createdAtColumnName: timestamp,
        _updatedAtColumnName: timestamp,
      },
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final data = await db.query(
      _notesTableName,
      orderBy: '$_updatedAtColumnName DESC',
    );
    List<Note> notes = data
        .map(
          (e) => Note(
            id: e["id"] as int,
            status: e["status"] as int,
            title: e["title"] as String,
            content: e["content"] as String,
            createdAt: e[_createdAtColumnName] as String,
            updatedAt: e[_updatedAtColumnName] as String,
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
    String title,
    String content,
  ) async {
    final db = await database;
    final timestamp = DateTime.now().toIso8601String();
    await db.update(
      _notesTableName,
      {
        _notesTitleColumnName: title,
        _notesContentColumnName: content,
        _notesStatusColumnName: 0,
        _updatedAtColumnName: timestamp,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteNoteById(int id) async {
    final db = await database;
    await db.delete(
      _notesTableName,
      where: '$_notesIdColumnName = ?',
      whereArgs: [id],
    );
  }
}
