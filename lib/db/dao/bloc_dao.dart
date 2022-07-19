import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/category.dart';
import 'package:bloc/db/entity/manager_service.dart';
import 'package:bloc/db/entity/product.dart';
import 'package:bloc/db/entity/seat.dart';
import 'package:bloc/db/entity/service_table.dart';
import 'package:floor/floor.dart';

import '../entity/bloc.dart';
import '../entity/bloc_service.dart';
import '../entity/city.dart';
import '../entity/user.dart';

@dao
abstract class BlocDao {
  /** User **/
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertUser(User user);

  @Query('SELECT * FROM User where userId=:uId')
  Future<User?> getUser(String uId);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateUser(User user);

  @Query('DELETE FROM User')
  Future<void> clearUsers();

  /** City **/
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertCity(City city);

  /** Bloc **/
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertBloc(Bloc bloc);

  /** Service **/
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertBlocService(BlocService service);

  /** Category **/
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertCategory(Category cat);

  @Query('SELECT * FROM Category ORDER BY sequence ASC')
  Stream<List<Category>> getCategories();

  @Query('SELECT * FROM Category ORDER BY sequence ASC')
  Future<List<Category>> getCategoriesFuture();

  @Query('DELETE FROM Category')
  Future<void> clearCategories();

  /** Cart Items **/
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertCartItem(CartItem cartitem);

  @Query('SELECT * FROM CartItem where userId=:uId')
  Future<List<CartItem>> getCartItems(String uId);

  @Query('SELECT * FROM CartItem where serviceId=:sId ORDER BY userId ASC')
  Future<List<CartItem>> getSortedCartItems(String sId);

  @Query('SELECT * FROM CartItem where serviceId=:sId ORDER BY tableNumber ASC')
  Future<List<CartItem>> getCartItemsByTableNumber(String sId);

  @Query('SELECT * FROM CartItem where serviceId=:sId and isCompleted=0 ORDER BY tableNumber ASC')
  Future<List<CartItem>> getPendingCartItemsByTableNumber(String sId);

  @Query('SELECT * FROM CartItem where serviceId=:sId and isCompleted=1 ORDER BY tableNumber ASC')
  Future<List<CartItem>> getCompletedCartItemsByTableNumber(String sId);

  @Query('DELETE FROM CartItem where productId=:prodId')
  Future<void> deleteCartItems(String prodId);

  /** Product **/
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertProduct(Product product);

  @Query('SELECT * FROM Product')
  Future<List<Product>> getProducts();

  @Query('SELECT * FROM Product where type=:catType')
  Future<List<Product>> getProductsByCategory(String catType);

  @Query('DELETE FROM Product')
  Future<void> clearProducts();

  /** Manager Service **/
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertManagerService(ManagerService ms);

  @Query('SELECT * FROM ManagerService ORDER BY sequence ASC')
  Stream<List<ManagerService>> getManagerServices();

  /** Service Table **/
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertServiceTable(ServiceTable serviceTable);

  @Query('SELECT * FROM ServiceTable where serviceId=:serviceId ORDER BY tableNumber ASC')
  Future<List<ServiceTable>> getTables(String serviceId);

  @Query("UPDATE ServiceTable SET isOccupied = :occupyStatus WHERE serviceId = :serviceId "
      "and tableNumber=:tableNumber")
  Future<void> updateTableOccupied(String serviceId, int tableNumber, bool occupyStatus);

  /** Seat **/
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertSeat(Seat seat);

  @Query("UPDATE Seat SET custId = :custId WHERE id = :seatId")
  Future<void> updateCustInSeat(String seatId, String custId);

  @Query('SELECT * FROM Seat where serviceId=:serviceId and tableNumber=:tableNumber')
  Future<List<Seat>> getSeats(String serviceId, int tableNumber);

  @Query('DELETE FROM Seat where tableNumber=:tableNumber')
  Future<void> deleteSeats(int tableNumber);


  // @Query('SELECT * FROM Product where id=:productId')
  // Future<Product?> getProduct(String productId);

}