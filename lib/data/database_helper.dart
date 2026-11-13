import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite schema — phụ trách: Lưu Minh Thông
/// CT484 group project CafeSpot
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cafe_spot.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cafes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            description TEXT NOT NULL,
            image_url TEXT NOT NULL,
            rating REAL NOT NULL DEFAULT 0,
            category TEXT NOT NULL,
            is_favorite INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE reviews (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cafe_id INTEGER NOT NULL,
            author TEXT NOT NULL,
            content TEXT NOT NULL,
            rating REAL NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (cafe_id) REFERENCES cafes (id) ON DELETE CASCADE
          )
        ''');
        await _seed(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Đổi ảnh seed từ picsum (hay timeout) sang asset tĩnh.
          const mapping = {
            'The Coffee House': 'assets/images/cafe1.png',
            'Cộng Cà Phê': 'assets/images/cafe2.png',
            'Highland Coffee': 'assets/images/cafe3.png',
            'Garden Beans': 'assets/images/cafe4.png',
          };
          for (final entry in mapping.entries) {
            await db.update(
              'cafes',
              {'image_url': entry.value},
              where: 'name = ?',
              whereArgs: [entry.key],
            );
          }
          await db.rawUpdate(
            "UPDATE cafes SET image_url = 'assets/images/cafe1.png' "
            "WHERE image_url LIKE '%picsum.photos%'",
          );
        }
      },
    );
  }

  Future<void> _seed(Database db) async {
    final now = DateTime.now().toIso8601String();
    final seeds = [
      {
        'name': 'The Coffee House',
        'address': 'Ninh Kiều, Cần Thơ',
        'description': 'Không gian rộng, wifi ổn định, phù hợp học nhóm.',
        'image_url': 'assets/images/cafe1.png',
        'rating': 4.5,
        'category': 'Chuỗi',
        'is_favorite': 1,
        'created_at': now,
      },
      {
        'name': 'Cộng Cà Phê',
        'address': 'Xuân Khánh, Cần Thơ',
        'description': 'Phong cách hoài cổ, đồ uống đậm đà.',
        'image_url': 'assets/images/cafe2.png',
        'rating': 4.2,
        'category': 'Specialty',
        'is_favorite': 0,
        'created_at': now,
      },
      {
        'name': 'Highland Coffee',
        'address': 'Cái Răng, Cần Thơ',
        'description': 'View sông, bàn ngoài trời thoáng mát.',
        'image_url': 'assets/images/cafe3.png',
        'rating': 4.0,
        'category': 'Chuỗi',
        'is_favorite': 0,
        'created_at': now,
      },
      {
        'name': 'Garden Beans',
        'address': 'An Khánh, Ninh Kiều',
        'description': 'Quán nhỏ yên tĩnh, phù hợp làm việc cá nhân.',
        'image_url': 'assets/images/cafe4.png',
        'rating': 4.7,
        'category': 'Local',
        'is_favorite': 1,
        'created_at': now,
      },
    ];
    for (final row in seeds) {
      await db.insert('cafes', row);
    }
  }
}
