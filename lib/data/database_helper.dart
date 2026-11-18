import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      version: 4,
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
            created_at TEXT NOT NULL,
            open_hours TEXT NOT NULL DEFAULT '',
            phone TEXT NOT NULL DEFAULT '',
            price_range TEXT NOT NULL DEFAULT ''
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
        await _createCollectionTables(db);
        await _seed(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
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
        if (oldVersion < 3) {
          await db.execute(
            "ALTER TABLE cafes ADD COLUMN open_hours TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE cafes ADD COLUMN phone TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE cafes ADD COLUMN price_range TEXT NOT NULL DEFAULT ''",
          );
          for (final entry in _seedInfo.entries) {
            await db.update(
              'cafes',
              {
                'open_hours': entry.value[0],
                'phone': entry.value[1],
                'price_range': entry.value[2],
              },
              where: 'name = ?',
              whereArgs: [entry.key],
            );
          }
        }
        if (oldVersion < 4) {
          await _createCollectionTables(db);
        }
      },
    );
  }

  Future<void> _createCollectionTables(Database db) async {
    await db.execute('''
      CREATE TABLE collections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE collection_cafes (
        collection_id INTEGER NOT NULL,
        cafe_id INTEGER NOT NULL,
        PRIMARY KEY (collection_id, cafe_id)
      )
    ''');
  }

  static const _seedInfo = {
    'The Coffee House': ['07:00 - 22:00', '0901 234 567', 'Trung bình'],
    'Cộng Cà Phê': ['07:00 - 23:00', '0902 345 678', 'Trung bình'],
    'Highland Coffee': ['06:30 - 22:30', '0903 456 789', 'Trung bình'],
    'Garden Beans': ['08:00 - 21:00', '0904 567 890', 'Bình dân'],
  };

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
      final info = _seedInfo[row['name']]!;
      await db.insert('cafes', {
        ...row,
        'open_hours': info[0],
        'phone': info[1],
        'price_range': info[2],
      });
    }
  }
}
