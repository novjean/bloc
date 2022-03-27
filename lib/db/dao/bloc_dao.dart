import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/category.dart';
import 'package:bloc/db/entity/product.dart';
import 'package:floor/floor.dart';

import '../entity/bloc.dart';
import '../entity/bloc_service.dart';
import '../entity/city.dart';
import '../entity/user.dart';

@dao
abstract class BlocDao {
  /** User **/
  @insert
  Future<void> insertUser(User user);

  /** City **/
  @insert
  Future<void> insertCity(City city);

  /** Bloc **/
  @insert
  Future<void> insertBloc(Bloc bloc);

  /** Service **/
  @insert
  Future<void> insertBlocService(BlocService service);

  /** Category **/
  @insert
  Future<void> insertCategory(Category cat);

  @Query('SELECT * FROM Category ORDER BY sequence ASC')
  Stream<List<Category>> getCategories();

  /** Cart Items **/
  @insert
  Future<void> insertCartItem(CartItem cartitem);

  @Query('SELECT * FROM CartItem where userId=:uId')
  Future<List<CartItem>> getCartItems(String uId);

  @Query('SELECT * FROM CartItem where serviceId=:sId ORDER BY userId ASC')
  Future<List<CartItem>> getSortedCartItems(String sId);

  @Query('DELETE FROM CartItem where productId=:prodId')
  Future<CartItem?> deleteCartItems(String prodId);

  /** Product **/
  @insert
  Future<void> insertProduct(Product product);

  @Query('SELECT * FROM Product')
  Future<List<Product>> getProducts();

  @Query('SELECT * FROM Product where type=:catType')
  Future<List<Product>> getProductsByCategory(String catType);

  // @Query('SELECT * FROM Product where id=:productId')
  // Future<Product?> getProduct(String productId);

}