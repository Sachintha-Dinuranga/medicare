import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'app_database.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');
  }

  // Insert a new location into the database
  Future<int> insertLocation(String name, double latitude, double longitude) async {
    Database db = await instance.database;
    return await db.insert('locations', {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  // Get all saved locations
  Future<List<Map<String, dynamic>>> getAllLocations() async {
    Database db = await instance.database;
    return await db.query('locations');
  }

 // Get one location by ID
Future<Map<String, dynamic>?> getLocationById(int id) async {
  Database db = await instance.database;
  
  // Perform the query to get the location by ID
  List<Map<String, dynamic>> result = await db.query(
    'locations',          // Table name
    where: 'id = ?',       // WHERE clause to match the ID
    whereArgs: [id],       // Arguments for the WHERE clause
    limit: 1,              // We only want one result
  );

  // Check if a result is returned
  if (result.isNotEmpty) {
    return result.first;   // Return the first result as a map
  } else {
    return null;           // Return null if no location found
  }
}

  // Update a location by id
  Future<int> updateLocation(int id, String name) async {
    Database db = await instance.database;
    return await db.update(
      'locations',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a location by id
  Future<int> deleteLocation(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'locations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
