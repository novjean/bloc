// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  BlocDao? _blocDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 4,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Person` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`userId` TEXT NOT NULL, `username` TEXT NOT NULL, `email` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `clearanceLevel` INTEGER NOT NULL, PRIMARY KEY (`userId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `City` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Bloc` (`id` TEXT NOT NULL, `cityName` TEXT NOT NULL, `addressLine1` TEXT NOT NULL, `addressLine2` TEXT NOT NULL, `pinCode` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `createdAt` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  BlocDao get blocDao {
    return _blocDaoInstance ??= _$BlocDao(database, changeListener);
  }
}

class _$BlocDao extends BlocDao {
  _$BlocDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _personInsertionAdapter = InsertionAdapter(
            database,
            'Person',
            (Person item) =>
                <String, Object?>{'id': item.id, 'name': item.name},
            changeListener),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (User item) => <String, Object?>{
                  'userId': item.userId,
                  'username': item.username,
                  'email': item.email,
                  'imageUrl': item.imageUrl,
                  'clearanceLevel': item.clearanceLevel
                }),
        _cityInsertionAdapter = InsertionAdapter(
            database,
            'City',
            (City item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'ownerId': item.ownerId,
                  'imageUrl': item.imageUrl
                }),
        _blocInsertionAdapter = InsertionAdapter(
            database,
            'Bloc',
            (Bloc item) => <String, Object?>{
                  'id': item.id,
                  'cityName': item.cityName,
                  'addressLine1': item.addressLine1,
                  'addressLine2': item.addressLine2,
                  'pinCode': item.pinCode,
                  'imageUrl': item.imageUrl,
                  'ownerId': item.ownerId,
                  'createdAt': item.createdAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Person> _personInsertionAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  final InsertionAdapter<City> _cityInsertionAdapter;

  final InsertionAdapter<Bloc> _blocInsertionAdapter;

  @override
  Future<List<Person>> findAllPersons() async {
    return _queryAdapter.queryList('SELECT * FROM Person',
        mapper: (Map<String, Object?> row) =>
            Person(row['id'] as int, row['name'] as String));
  }

  @override
  Stream<Person?> findPersonById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Person WHERE id = ?1',
        mapper: (Map<String, Object?> row) =>
            Person(row['id'] as int, row['name'] as String),
        arguments: [id],
        queryableName: 'Person',
        isView: false);
  }

  @override
  Future<void> insertPerson(Person person) async {
    await _personInsertionAdapter.insert(person, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertCity(City city) async {
    await _cityInsertionAdapter.insert(city, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertBloc(Bloc bloc) async {
    await _blocInsertionAdapter.insert(bloc, OnConflictStrategy.abort);
  }
}
