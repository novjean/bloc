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
      version: 20,
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
            'CREATE TABLE IF NOT EXISTS `Bloc` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `cityId` TEXT NOT NULL, `addressLine1` TEXT NOT NULL, `addressLine2` TEXT NOT NULL, `pinCode` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `createdAt` TEXT NOT NULL, `isActive` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `BlocService` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `blocId` TEXT NOT NULL, `type` TEXT NOT NULL, `primaryPhone` REAL NOT NULL, `secondaryPhone` REAL NOT NULL, `emailId` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `createdAt` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `CartItem` (`cartId` TEXT NOT NULL, `serviceId` TEXT NOT NULL, `billId` TEXT NOT NULL, `tableNumber` INTEGER NOT NULL, `cartNumber` INTEGER NOT NULL, `userId` TEXT NOT NULL, `productId` TEXT NOT NULL, `productName` TEXT NOT NULL, `productPrice` REAL NOT NULL, `isCommunity` INTEGER NOT NULL, `quantity` INTEGER NOT NULL, `isCompleted` INTEGER NOT NULL, `isBilled` INTEGER NOT NULL, `createdAt` INTEGER NOT NULL, PRIMARY KEY (`cartId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Category` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `type` TEXT NOT NULL, `serviceId` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `createdAt` INTEGER NOT NULL, `sequence` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `City` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Product` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `type` TEXT NOT NULL, `category` TEXT NOT NULL, `description` TEXT NOT NULL, `price` REAL NOT NULL, `serviceId` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `createdAt` INTEGER NOT NULL, `isAvailable` INTEGER NOT NULL, `priceHighest` REAL NOT NULL, `priceLowest` REAL NOT NULL, `priceHighestTime` INTEGER NOT NULL, `priceLowestTime` INTEGER NOT NULL, `priceCommunity` REAL NOT NULL, `isOfferRunning` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`id` TEXT NOT NULL, `username` TEXT NOT NULL, `email` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `clearanceLevel` INTEGER NOT NULL, `phoneNumber` INTEGER NOT NULL, `name` TEXT NOT NULL, `fcmToken` TEXT NOT NULL, `blocServiceId` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ManagerService` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `sequence` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ServiceTable` (`id` TEXT NOT NULL, `serviceId` TEXT NOT NULL, `captainId` TEXT NOT NULL, `tableNumber` INTEGER NOT NULL, `capacity` INTEGER NOT NULL, `isOccupied` INTEGER NOT NULL, `isActive` INTEGER NOT NULL, `type` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Seat` (`id` TEXT NOT NULL, `custId` TEXT NOT NULL, `serviceId` TEXT NOT NULL, `tableId` TEXT NOT NULL, `tableNumber` INTEGER NOT NULL, PRIMARY KEY (`id`))');

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
  _$BlocDao(this.database, this.changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;
}
