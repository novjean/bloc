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
      version: 15,
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
            'CREATE TABLE IF NOT EXISTS `Bloc` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `cityName` TEXT NOT NULL, `addressLine1` TEXT NOT NULL, `addressLine2` TEXT NOT NULL, `pinCode` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `createdAt` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `BlocService` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `blocId` TEXT NOT NULL, `type` TEXT NOT NULL, `primaryNumber` REAL NOT NULL, `secondaryNumber` REAL NOT NULL, `email` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `createdAt` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `CartItem` (`id` TEXT NOT NULL, `serviceId` TEXT NOT NULL, `cartNumber` INTEGER NOT NULL, `userId` TEXT NOT NULL, `productId` TEXT NOT NULL, `productName` TEXT NOT NULL, `productPrice` REAL NOT NULL, `quantity` INTEGER NOT NULL, `createdAt` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Category` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `type` TEXT NOT NULL, `serviceId` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `createdAt` TEXT NOT NULL, `sequence` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `City` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Product` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `type` TEXT NOT NULL, `description` TEXT NOT NULL, `price` INTEGER NOT NULL, `serviceId` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `createdAt` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`userId` TEXT NOT NULL, `username` TEXT NOT NULL, `email` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `clearanceLevel` INTEGER NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`userId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ManagerService` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `sequence` INTEGER NOT NULL, PRIMARY KEY (`id`))');

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
        _userInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (User item) => <String, Object?>{
                  'userId': item.userId,
                  'username': item.username,
                  'email': item.email,
                  'imageUrl': item.imageUrl,
                  'clearanceLevel': item.clearanceLevel,
                  'name': item.name
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
                  'name': item.name,
                  'cityName': item.cityName,
                  'addressLine1': item.addressLine1,
                  'addressLine2': item.addressLine2,
                  'pinCode': item.pinCode,
                  'imageUrl': item.imageUrl,
                  'ownerId': item.ownerId,
                  'createdAt': item.createdAt
                }),
        _blocServiceInsertionAdapter = InsertionAdapter(
            database,
            'BlocService',
            (BlocService item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'blocId': item.blocId,
                  'type': item.type,
                  'primaryNumber': item.primaryNumber,
                  'secondaryNumber': item.secondaryNumber,
                  'email': item.email,
                  'imageUrl': item.imageUrl,
                  'ownerId': item.ownerId,
                  'createdAt': item.createdAt
                }),
        _categoryInsertionAdapter = InsertionAdapter(
            database,
            'Category',
            (Category item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'type': item.type,
                  'serviceId': item.serviceId,
                  'imageUrl': item.imageUrl,
                  'ownerId': item.ownerId,
                  'createdAt': item.createdAt,
                  'sequence': item.sequence
                },
            changeListener),
        _cartItemInsertionAdapter = InsertionAdapter(
            database,
            'CartItem',
            (CartItem item) => <String, Object?>{
                  'id': item.id,
                  'serviceId': item.serviceId,
                  'cartNumber': item.cartNumber,
                  'userId': item.userId,
                  'productId': item.productId,
                  'productName': item.productName,
                  'productPrice': item.productPrice,
                  'quantity': item.quantity,
                  'createdAt': item.createdAt
                }),
        _productInsertionAdapter = InsertionAdapter(
            database,
            'Product',
            (Product item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'type': item.type,
                  'description': item.description,
                  'price': item.price,
                  'serviceId': item.serviceId,
                  'imageUrl': item.imageUrl,
                  'ownerId': item.ownerId,
                  'createdAt': item.createdAt
                }),
        _managerServiceInsertionAdapter = InsertionAdapter(
            database,
            'ManagerService',
            (ManagerService item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'sequence': item.sequence
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  final InsertionAdapter<City> _cityInsertionAdapter;

  final InsertionAdapter<Bloc> _blocInsertionAdapter;

  final InsertionAdapter<BlocService> _blocServiceInsertionAdapter;

  final InsertionAdapter<Category> _categoryInsertionAdapter;

  final InsertionAdapter<CartItem> _cartItemInsertionAdapter;

  final InsertionAdapter<Product> _productInsertionAdapter;

  final InsertionAdapter<ManagerService> _managerServiceInsertionAdapter;

  @override
  Stream<List<Category>> getCategories() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM Category ORDER BY sequence ASC',
        mapper: (Map<String, Object?> row) => Category(
            row['id'] as String,
            row['name'] as String,
            row['type'] as String,
            row['serviceId'] as String,
            row['imageUrl'] as String,
            row['ownerId'] as String,
            row['createdAt'] as String,
            row['sequence'] as int),
        queryableName: 'Category',
        isView: false);
  }

  @override
  Future<List<CartItem>> getCartItems(String uId) async {
    return _queryAdapter.queryList('SELECT * FROM CartItem where userId=?1',
        mapper: (Map<String, Object?> row) => CartItem(
            id: row['id'] as String,
            serviceId: row['serviceId'] as String,
            cartNumber: row['cartNumber'] as int,
            userId: row['userId'] as String,
            productId: row['productId'] as String,
            productName: row['productName'] as String,
            productPrice: row['productPrice'] as double,
            quantity: row['quantity'] as int,
            createdAt: row['createdAt'] as int),
        arguments: [uId]);
  }

  @override
  Future<List<CartItem>> getSortedCartItems(String sId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM CartItem where serviceId=?1 ORDER BY userId ASC',
        mapper: (Map<String, Object?> row) => CartItem(
            id: row['id'] as String,
            serviceId: row['serviceId'] as String,
            cartNumber: row['cartNumber'] as int,
            userId: row['userId'] as String,
            productId: row['productId'] as String,
            productName: row['productName'] as String,
            productPrice: row['productPrice'] as double,
            quantity: row['quantity'] as int,
            createdAt: row['createdAt'] as int),
        arguments: [sId]);
  }

  @override
  Future<CartItem?> deleteCartItems(String prodId) async {
    return _queryAdapter.query('DELETE FROM CartItem where productId=?1',
        mapper: (Map<String, Object?> row) => CartItem(
            id: row['id'] as String,
            serviceId: row['serviceId'] as String,
            cartNumber: row['cartNumber'] as int,
            userId: row['userId'] as String,
            productId: row['productId'] as String,
            productName: row['productName'] as String,
            productPrice: row['productPrice'] as double,
            quantity: row['quantity'] as int,
            createdAt: row['createdAt'] as int),
        arguments: [prodId]);
  }

  @override
  Future<List<Product>> getProducts() async {
    return _queryAdapter.queryList('SELECT * FROM Product',
        mapper: (Map<String, Object?> row) => Product(
            row['id'] as String,
            row['name'] as String,
            row['type'] as String,
            row['description'] as String,
            row['price'] as int,
            row['serviceId'] as String,
            row['imageUrl'] as String,
            row['ownerId'] as String,
            row['createdAt'] as String));
  }

  @override
  Future<List<Product>> getProductsByCategory(String catType) async {
    return _queryAdapter.queryList('SELECT * FROM Product where type=?1',
        mapper: (Map<String, Object?> row) => Product(
            row['id'] as String,
            row['name'] as String,
            row['type'] as String,
            row['description'] as String,
            row['price'] as int,
            row['serviceId'] as String,
            row['imageUrl'] as String,
            row['ownerId'] as String,
            row['createdAt'] as String),
        arguments: [catType]);
  }

  @override
  Stream<List<ManagerService>> getManagerServices() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM ManagerService ORDER BY sequence ASC',
        mapper: (Map<String, Object?> row) => ManagerService(
            row['id'] as String, row['name'] as String, row['sequence'] as int),
        queryableName: 'ManagerService',
        isView: false);
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

  @override
  Future<void> insertBlocService(BlocService service) async {
    await _blocServiceInsertionAdapter.insert(
        service, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertCategory(Category cat) async {
    await _categoryInsertionAdapter.insert(cat, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertCartItem(CartItem cartitem) async {
    await _cartItemInsertionAdapter.insert(cartitem, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertProduct(Product product) async {
    await _productInsertionAdapter.insert(product, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertManagerService(ManagerService ms) async {
    await _managerServiceInsertionAdapter.insert(ms, OnConflictStrategy.abort);
  }
}
