import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/activity_model.dart';
import '../models/coding_activity_model.dart';
import '../models/profile_model.dart';

class LocalDatabase {
  static Database? _database;
  static const String _dbName = 'mycsit.db';
  static const int _dbVersion = 1;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // Activities table
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        proofUrl TEXT,
        status TEXT NOT NULL,
        rejectionReason TEXT,
        approvedBy TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Coding activities table
    await db.execute('''
      CREATE TABLE coding_activities (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        platform TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        value INTEGER,
        contestName TEXT,
        difficulty TEXT,
        proofUrl TEXT,
        status TEXT NOT NULL,
        rejectionReason TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Profiles table
    await db.execute('''
      CREATE TABLE profiles(
        id TEXT PRIMARY KEY,
        userId TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        profilePhotoUrl TEXT,
        socialLinks TEXT NOT NULL,
        cgpa REAL,
        attendance REAL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_activities_userId ON activities(userId)');
    await db.execute('CREATE INDEX idx_activities_status ON activities(status)');
    await db.execute('CREATE INDEX idx_activities_date ON activities(date)');
    await db.execute('CREATE INDEX idx_coding_activities_userId ON coding_activities(userId)');
    await db.execute('CREATE INDEX idx_coding_activities_status ON coding_activities(status)');
    await db.execute('CREATE INDEX idx_profiles_userId ON profiles(userId)');
  }

  // Activity operations
  static Future<void> insertActivity(ActivityModel activity) async {
    final db = await database;
    await db.insert('activities', activity.toMap());
  }

  static Future<List<ActivityModel>> getActivities(String userId) async {
    final db = await database;
    final maps = await db.query(
      'activities',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => ActivityModel.fromMap(map)).toList();
  }

  static Future<List<ActivityModel>> getActivitiesByStatus(String userId, String status) async {
    final db = await database;
    final maps = await db.query(
      'activities',
      where: 'userId = ? AND status = ?',
      whereArgs: [userId, status],
      orderBy: 'date DESC',
    );
    return maps.map((map) => ActivityModel.fromMap(map)).toList();
  }

  static Future<void> updateActivity(ActivityModel activity) async {
    final db = await database;
    await db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  static Future<void> deleteActivity(String id) async {
    final db = await database;
    await db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Coding activity operations
  static Future<void> insertCodingActivity(CodingActivityModel activity) async {
    final db = await database;
    await db.insert('coding_activities', activity.toMap());
  }

  static Future<List<CodingActivityModel>> getCodingActivities(String userId) async {
    final db = await database;
    final maps = await db.query(
      'coding_activities',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => CodingActivityModel.fromMap(map)).toList();
  }

  static Future<List<CodingActivityModel>> getCodingActivitiesByStatus(String userId, String status) async {
    final db = await database;
    final maps = await db.query(
      'coding_activities',
      where: 'userId = ? AND status = ?',
      whereArgs: [userId, status],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => CodingActivityModel.fromMap(map)).toList();
  }

  static Future<void> updateCodingActivity(CodingActivityModel activity) async {
    final db = await database;
    await db.update(
      'coding_activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  static Future<void> deleteCodingActivity(String id) async {
    final db = await database;
    await db.delete(
      'coding_activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Profile operations
  static Future<void> insertProfile(ProfileModel profile) async {
    final db = await database;
    await db.insert(
      'profiles',
      {
        'id': profile.id,
        'userId': profile.userId,
        'name': profile.name,
        'profilePhotoUrl': profile.profilePhotoUrl,
        'socialLinks': jsonEncode(profile.socialLinks),
        'cgpa': profile.cgpa,
        'attendance': profile.attendance,
        'createdAt': profile.createdAt.toIso8601String(),
        'updatedAt': profile.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<ProfileModel?> getProfile(String userId) async {
    final db = await database;
    final maps = await db.query(
      'profiles',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ProfileModel.fromMap(maps.first);
  }

  static Future<void> updateProfile(ProfileModel profile) async {
    final db = await database;
    await db.update(
      'profiles',
      profile.toMap(),
      where: 'userId = ?',
      whereArgs: [profile.userId],
    );
  }

  // Timeline operations (unified feed)
  static Future<List<Map<String, dynamic>>> getTimelineEntries(String userId) async {
    final db = await database;
    
    // Get activities
    final activities = await db.query(
      'activities',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    // Get coding activities
    final codingActivities = await db.query(
      'coding_activities',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    // Combine and sort
    final allEntries = <Map<String, dynamic>>[];
    
    for (final activity in activities) {
      allEntries.add({
        ...activity,
        'entryType': 'activity',
        'sortDate': activity['date'],
      });
    }
    
    for (final codingActivity in codingActivities) {
      allEntries.add({
        ...codingActivity,
        'entryType': 'coding',
        'sortDate': codingActivity['createdAt'],
      });
    }

    // Sort by date
    allEntries.sort((a, b) {
      final dateA = DateTime.parse(a['sortDate']);
      final dateB = DateTime.parse(b['sortDate']);
      return dateB.compareTo(dateA);
    });

    return allEntries;
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
