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
  _$BlocDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _blocServiceInsertionAdapter = InsertionAdapter(
            database,
            'BlocService',
            (BlocService item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'blocId': item.blocId,
                  'type': item.type,
                  'primaryPhone': item.primaryPhone,
                  'secondaryPhone': item.secondaryPhone,
                  'emailId': item.emailId,
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
                  'cartId': item.cartId,
                  'serviceId': item.serviceId,
                  'billId': item.billId,
                  'tableNumber': item.tableNumber,
                  'cartNumber': item.cartNumber,
                  'userId': item.userId,
                  'productId': item.productId,
                  'productName': item.productName,
                  'productPrice': item.productPrice,
                  'isCommunity': item.isCommunity ? 1 : 0,
                  'quantity': item.quantity,
                  'isCompleted': item.isCompleted ? 1 : 0,
                  'isBilled': item.isBilled ? 1 : 0,
                  'createdAt': item.createdAt
                }),
        _productInsertionAdapter = InsertionAdapter(
            database,
            'Product',
            (Product item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'type': item.type,
                  'category': item.category,
                  'description': item.description,
                  'price': item.price,
                  'serviceId': item.serviceId,
                  'imageUrl': item.imageUrl,
                  'ownerId': item.ownerId,
                  'createdAt': item.createdAt,
                  'isAvailable': item.isAvailable ? 1 : 0,
                  'priceHighest': item.priceHighest,
                  'priceLowest': item.priceLowest,
                  'priceHighestTime': item.priceHighestTime,
                  'priceLowestTime': item.priceLowestTime,
                  'priceCommunity': item.priceCommunity,
                  'isOfferRunning': item.isOfferRunning ? 1 : 0
                }),
        _managerServiceInsertionAdapter = InsertionAdapter(
            database,
            'ManagerService',
            (ManagerService item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'sequence': item.sequence
                },
            changeListener),
        _seatInsertionAdapter = InsertionAdapter(
            database,
            'Seat',
            (Seat item) => <String, Object?>{
                  'id': item.id,
                  'custId': item.custId,
                  'serviceId': item.serviceId,
                  'tableId': item.tableId,
                  'tableNumber': item.tableNumber
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<BlocService> _blocServiceInsertionAdapter;

  final InsertionAdapter<Category> _categoryInsertionAdapter;

  final InsertionAdapter<CartItem> _cartItemInsertionAdapter;

  final InsertionAdapter<Product> _productInsertionAdapter;

  final InsertionAdapter<ManagerService> _managerServiceInsertionAdapter;

  final InsertionAdapter<Seat> _seatInsertionAdapter;

  @override
  Stream<List<Category>> getCategories() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM Category ORDER BY sequence ASC',
        mapper: (Map<String, Object?> row) => Category(
            id: row['id'] as String,
            name: row['name'] as String,
            type: row['type'] as String,
            serviceId: row['serviceId'] as String,
            imageUrl: row['imageUrl'] as String,
            ownerId: row['ownerId'] as String,
            createdAt: row['createdAt'] as int,
            sequence: row['sequence'] as int),
        queryableName: 'Category',
        isView: false);
  }

  @override
  Future<List<Category>> getCategoriesFuture() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Category ORDER BY sequence ASC',
        mapper: (Map<String, Object?> row) => Category(
            id: row['id'] as String,
            name: row['name'] as String,
            type: row['type'] as String,
            serviceId: row['serviceId'] as String,
            imageUrl: row['imageUrl'] as String,
            ownerId: row['ownerId'] as String,
            createdAt: row['createdAt'] as int,
            sequence: row['sequence'] as int));
  }

  @override
  Future<void> clearCategories() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Category');
  }

  @override
  Future<List<CartItem>> getCartItems(String uId) async {
    return _queryAdapter.queryList('SELECT * FROM CartItem where userId=?1',
        mapper: (Map<String, Object?> row) => CartItem(
            cartId: row['cartId'] as String,
            serviceId: row['serviceId'] as String,
            billId: row['billId'] as String,
            tableNumber: row['tableNumber'] as int,
            cartNumber: row['cartNumber'] as int,
            userId: row['userId'] as String,
            productId: row['productId'] as String,
            productName: row['productName'] as String,
            productPrice: row['productPrice'] as double,
            isCommunity: (row['isCommunity'] as int) != 0,
            quantity: row['quantity'] as int,
            isCompleted: (row['isCompleted'] as int) != 0,
            isBilled: (row['isBilled'] as int) != 0,
            createdAt: row['createdAt'] as int),
        arguments: [uId]);
  }

  @override
  Future<List<CartItem>> getSortedCartItems(String sId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM CartItem where serviceId=?1 ORDER BY userId ASC',
        mapper: (Map<String, Object?> row) => CartItem(
            cartId: row['cartId'] as String,
            serviceId: row['serviceId'] as String,
            billId: row['billId'] as String,
            tableNumber: row['tableNumber'] as int,
            cartNumber: row['cartNumber'] as int,
            userId: row['userId'] as String,
            productId: row['productId'] as String,
            productName: row['productName'] as String,
            productPrice: row['productPrice'] as double,
            isCommunity: (row['isCommunity'] as int) != 0,
            quantity: row['quantity'] as int,
            isCompleted: (row['isCompleted'] as int) != 0,
            isBilled: (row['isBilled'] as int) != 0,
            createdAt: row['createdAt'] as int),
        arguments: [sId]);
  }

  @override
  Future<List<CartItem>> getCartItemsByTableNumber(String sId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM CartItem where serviceId=?1 ORDER BY tableNumber ASC',
        mapper: (Map<String, Object?> row) => CartItem(
            cartId: row['cartId'] as String,
            serviceId: row['serviceId'] as String,
            billId: row['billId'] as String,
            tableNumber: row['tableNumber'] as int,
            cartNumber: row['cartNumber'] as int,
            userId: row['userId'] as String,
            productId: row['productId'] as String,
            productName: row['productName'] as String,
            productPrice: row['productPrice'] as double,
            isCommunity: (row['isCommunity'] as int) != 0,
            quantity: row['quantity'] as int,
            isCompleted: (row['isCompleted'] as int) != 0,
            isBilled: (row['isBilled'] as int) != 0,
            createdAt: row['createdAt'] as int),
        arguments: [sId]);
  }

  @override
  Future<List<CartItem>> getPendingCartItemsByTableNumber(String sId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM CartItem where serviceId=?1 and isCompleted=0 ORDER BY tableNumber ASC',
        mapper: (Map<String, Object?> row) => CartItem(cartId: row['cartId'] as String, serviceId: row['serviceId'] as String, billId: row['billId'] as String, tableNumber: row['tableNumber'] as int, cartNumber: row['cartNumber'] as int, userId: row['userId'] as String, productId: row['productId'] as String, productName: row['productName'] as String, productPrice: row['productPrice'] as double, isCommunity: (row['isCommunity'] as int) != 0, quantity: row['quantity'] as int, isCompleted: (row['isCompleted'] as int) != 0, isBilled: (row['isBilled'] as int) != 0, createdAt: row['createdAt'] as int),
        arguments: [sId]);
  }

  @override
  Future<List<CartItem>> getCompletedCartItemsByTableNumber(String sId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM CartItem where serviceId=?1 and isCompleted=1 ORDER BY tableNumber ASC',
        mapper: (Map<String, Object?> row) => CartItem(cartId: row['cartId'] as String, serviceId: row['serviceId'] as String, billId: row['billId'] as String, tableNumber: row['tableNumber'] as int, cartNumber: row['cartNumber'] as int, userId: row['userId'] as String, productId: row['productId'] as String, productName: row['productName'] as String, productPrice: row['productPrice'] as double, isCommunity: (row['isCommunity'] as int) != 0, quantity: row['quantity'] as int, isCompleted: (row['isCompleted'] as int) != 0, isBilled: (row['isBilled'] as int) != 0, createdAt: row['createdAt'] as int),
        arguments: [sId]);
  }

  @override
  Future<void> deleteCartItems(String prodId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM CartItem where productId=?1',
        arguments: [prodId]);
  }

  @override
  Future<List<Product>> getProducts() async {
    return _queryAdapter.queryList('SELECT * FROM Product',
        mapper: (Map<String, Object?> row) => Product(
            id: row['id'] as String,
            name: row['name'] as String,
            type: row['type'] as String,
            category: row['category'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            serviceId: row['serviceId'] as String,
            imageUrl: row['imageUrl'] as String,
            ownerId: row['ownerId'] as String,
            createdAt: row['createdAt'] as int,
            isAvailable: (row['isAvailable'] as int) != 0,
            priceHighest: row['priceHighest'] as double,
            priceLowest: row['priceLowest'] as double,
            priceHighestTime: row['priceHighestTime'] as int,
            priceLowestTime: row['priceLowestTime'] as int,
            priceCommunity: row['priceCommunity'] as double,
            isOfferRunning: (row['isOfferRunning'] as int) != 0));
  }

  @override
  Future<List<Product>> getProductsByCategory(String catType) async {
    return _queryAdapter.queryList('SELECT * FROM Product where type=?1',
        mapper: (Map<String, Object?> row) => Product(
            id: row['id'] as String,
            name: row['name'] as String,
            type: row['type'] as String,
            category: row['category'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            serviceId: row['serviceId'] as String,
            imageUrl: row['imageUrl'] as String,
            ownerId: row['ownerId'] as String,
            createdAt: row['createdAt'] as int,
            isAvailable: (row['isAvailable'] as int) != 0,
            priceHighest: row['priceHighest'] as double,
            priceLowest: row['priceLowest'] as double,
            priceHighestTime: row['priceHighestTime'] as int,
            priceLowestTime: row['priceLowestTime'] as int,
            priceCommunity: row['priceCommunity'] as double,
            isOfferRunning: (row['isOfferRunning'] as int) != 0),
        arguments: [catType]);
  }

  @override
  Future<void> clearProducts() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Product');
  }

  @override
  Stream<List<ManagerService>> getManagerServices() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM ManagerService ORDER BY sequence ASC',
        mapper: (Map<String, Object?> row) => ManagerService(
            id: row['id'] as String,
            name: row['name'] as String,
            sequence: row['sequence'] as int),
        queryableName: 'ManagerService',
        isView: false);
  }

  @override
  Future<void> updateCustInSeat(String seatId, String custId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Seat SET custId = ?2 WHERE id = ?1',
        arguments: [seatId, custId]);
  }

  @override
  Future<List<Seat>> getSeats(String serviceId, int tableNumber) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Seat where serviceId=?1 and tableNumber=?2',
        mapper: (Map<String, Object?> row) => Seat(
            id: row['id'] as String,
            custId: row['custId'] as String,
            serviceId: row['serviceId'] as String,
            tableId: row['tableId'] as String,
            tableNumber: row['tableNumber'] as int),
        arguments: [serviceId, tableNumber]);
  }

  @override
  Future<void> deleteSeats(int tableNumber) async {
    await _queryAdapter.queryNoReturn('DELETE FROM Seat where tableNumber=?1',
        arguments: [tableNumber]);
  }

  @override
  Future<void> insertBlocService(BlocService service) async {
    await _blocServiceInsertionAdapter.insert(
        service, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertCategory(Category cat) async {
    await _categoryInsertionAdapter.insert(cat, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertCartItem(CartItem cartitem) async {
    await _cartItemInsertionAdapter.insert(
        cartitem, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertProduct(Product product) async {
    await _productInsertionAdapter.insert(product, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertManagerService(ManagerService ms) async {
    await _managerServiceInsertionAdapter.insert(
        ms, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertSeat(Seat seat) async {
    await _seatInsertionAdapter.insert(seat, OnConflictStrategy.replace);
  }
}
