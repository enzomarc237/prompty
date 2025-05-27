import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/prompt.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._internal();

  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'prompty.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE prompts (
        id TEXT PRIMARY KEY,
        originalText TEXT NOT NULL,
        professionalVersion TEXT,
        creativeVersion TEXT,
        technicalVersion TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        tags TEXT NOT NULL DEFAULT '[]',
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_prompts_created_at ON prompts(createdAt DESC);
    ''');

    await db.execute('''
      CREATE INDEX idx_prompts_favorite ON prompts(isFavorite);
    ''');
  }

  Future<void> insertPrompt(Prompt prompt) async {
    final db = await database;
    await db.insert(
      'prompts',
      {
        'id': prompt.id,
        'originalText': prompt.originalText,
        'professionalVersion': prompt.professionalVersion,
        'creativeVersion': prompt.creativeVersion,
        'technicalVersion': prompt.technicalVersion,
        'createdAt': prompt.createdAt.millisecondsSinceEpoch,
        'updatedAt': prompt.updatedAt?.millisecondsSinceEpoch,
        'isFavorite': prompt.isFavorite ? 1 : 0,
        'tags': jsonEncode(prompt.tags),
        'category': prompt.category,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePrompt(Prompt prompt) async {
    final db = await database;
    await db.update(
      'prompts',
      {
        'originalText': prompt.originalText,
        'professionalVersion': prompt.professionalVersion,
        'creativeVersion': prompt.creativeVersion,
        'technicalVersion': prompt.technicalVersion,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'isFavorite': prompt.isFavorite ? 1 : 0,
        'tags': jsonEncode(prompt.tags),
        'category': prompt.category,
      },
      where: 'id = ?',
      whereArgs: [prompt.id],
    );
  }

  Future<void> deletePrompt(String id) async {
    final db = await database;
    await db.delete(
      'prompts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Prompt>> getAllPrompts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prompts',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) => _mapToPrompt(maps[i]));
  }

  Future<List<Prompt>> getFavoritePrompts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prompts',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) => _mapToPrompt(maps[i]));
  }

  Future<List<Prompt>> searchPrompts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prompts',
      where: 'originalText LIKE ? OR professionalVersion LIKE ? OR creativeVersion LIKE ? OR technicalVersion LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) => _mapToPrompt(maps[i]));
  }

  Prompt _mapToPrompt(Map<String, dynamic> map) {
    return Prompt(
      id: map['id'],
      originalText: map['originalText'],
      professionalVersion: map['professionalVersion'],
      creativeVersion: map['creativeVersion'],
      technicalVersion: map['technicalVersion'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      isFavorite: map['isFavorite'] == 1,
      tags: List<String>.from(jsonDecode(map['tags'] ?? '[]')),
      category: map['category'],
    );
  }
}