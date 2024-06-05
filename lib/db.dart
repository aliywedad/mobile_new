import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class db {
  static Database? _database;
  static const String _tableName = 'user';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'db.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create 'users' table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS user (
      id INTEGER PRIMARY KEY,
      tel INTEGER NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL,
      role TEXT DEFAULT 'user',
      nom TEXT,
      prenom TEXT,
      active INTEGER DEFAULT 0
    )
  ''');
    print("// Create 'user' table");

    // Create 'wilaya' table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS wilaya (
      ID_wilaya INTEGER PRIMARY KEY,
      Nom_wilaya TEXT
    )
  ''');
    print("// Create 'wilaya' table");
    // Create 'moughata' table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS moughata (
      ID_maghataa INTEGER PRIMARY KEY,
      Nom_maghataa TEXT,
      ID_wilaya INTEGER,
      FOREIGN KEY (ID_wilaya) REFERENCES wilaya(ID_wilaya)
    )
  ''');

    // Create 'commune' table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS commune (
      ID_commune INTEGER PRIMARY KEY,
      Nom_commune TEXT NOT NULL,
      ID_maghataa_id INTEGER NOT NULL,
      FOREIGN KEY (ID_maghataa_id) REFERENCES moughata(ID_maghataa)
    )
  ''');
      print("// Create 'commune' table");


    // Create 'formilair' table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS formilair (
      id INTEGER PRIMARY KEY,
      titre TEXT,
      description TEXT
    )
  ''');
      print("// Create 'formilair' table");

    // Create 'infrastructur' table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS infrastructur (
      id INTEGER PRIMARY KEY,
      nom TEXT NOT NULL,
      description TEXT NOT NULL,
      type INTEGER,
      FOREIGN KEY (type) REFERENCES typeinfrastructur(id)
    )
  ''');
    print("// Create 'typeinfrastructur' table");
    // Create 'infrastructur' table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS typeinfrastructur (
      id INTEGER PRIMARY KEY,
      nom TEXT NOT NULL
    )
  ''');

    // Create 'infrastructuresvillage' table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS infrastructuresvillage (
      ID_Infrastructures INTEGER PRIMARY KEY,
      NumeroVillage INTEGER,
      id_user INTEGER,
      TypeInfrastructure INTEGER,
      NombreTotal INTEGER,
      NombreFonctionnelles INTEGER,
      NombreNonFonctionnelles INTEGER,
      date_info DATE,
       async INTEGER,
      FOREIGN KEY (id_user) REFERENCES users(id),
      FOREIGN KEY (TypeInfrastructure) REFERENCES typeinfrastructur(id),
      FOREIGN KEY (NumeroVillage) REFERENCES village(NumeroVillage)
    )
  ''');
      print("// Create 'infrastructuresvillage' table");

    await db.execute('''
    CREATE TABLE IF NOT EXISTS infrastructuresvillage_Online (
      ID_Infrastructures INTEGER PRIMARY KEY,
      NumeroVillage INTEGER,
      user INTEGER,
      TypeInfrastructure INTEGER,
      NombreTotal INTEGER,
      NombreFonctionnelles INTEGER,
      NombreNonFonctionnelles INTEGER,
      date_info TEXT,
      FOREIGN KEY (user) REFERENCES users(id),
      FOREIGN KEY (TypeInfrastructure) REFERENCES typeinfrastructur(id),
      FOREIGN KEY (NumeroVillage) REFERENCES village(NumeroVillage)
    )
  ''');
      print("// Create 'infrastructuresvillage_Online' table");


    // Create 'question' table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS question (
      id INTEGER PRIMARY KEY,
      formilair_id INTEGER,
      text TEXT,
      type TEXT,
      choices TEXT,
      categorie TEXT,
      FOREIGN KEY (formilair_id) REFERENCES formilair(id)
    )
  ''');
      print("// Create 'question' table");


    // Create 'reponse' table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS reponse (
      id INTEGER PRIMARY KEY,
      text_reponse TEXT,
      question_id INTEGER,
      id_user INTEGER,
      async INTEGER,
      response_date DATETIME DEFAULT CURRENT_TIMESTAMP,
      village INTEGER,
      FOREIGN KEY (question_id) REFERENCES question(id),
      FOREIGN KEY (id_user) REFERENCES users(id),
      FOREIGN KEY (village) REFERENCES village(NumeroVillage)
    )
  ''');
      print("// Create 'reponse' table");


    // Create 'reponse' table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS reponse_online (
      id INTEGER PRIMARY KEY,
      text_reponse TEXT,
      question_id INTEGER,
      id_user INTEGER,
      response_date DATETIME DEFAULT CURRENT_TIMESTAMP,
      village INTEGER,
      FOREIGN KEY (question_id) REFERENCES question(id),
      FOREIGN KEY (id_user) REFERENCES users(id),
      FOREIGN KEY (village) REFERENCES village(NumeroVillage)
    )
  ''');
      print("// Create 'reponse_online' table");



    // Create 'village' table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS village (
      NumeroVillage INTEGER PRIMARY KEY,
      idCommit INTEGER,
      NomAdministratifVillage TEXT,
      NomLocal TEXT,
      DistanceChefLieu REAL,
      DistanceAxesPrincipaux REAL,
      DateCreation DATE,
      CompositionEthnique TEXT,
      AutresInfosVillage TEXT,
      FOREIGN KEY (idCommit) REFERENCES commune(ID_commune)
    )
  ''');
      print("// Create 'village' table");

  }

  insrt(String sql) async {
    Database? mydb = await database;
    int response = await mydb!.rawInsert(sql); // Remove parentheses around sql
    return response;
  }

  updat(String sql) async {
    Database? mydb = await database;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  select(String sql) async {
    Database? mydb = await database;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  Future<int> delete(String sql) async {
    Database? mydb = await database;
    int response = await mydb!.rawDelete(sql);
    return response;
  }
}
