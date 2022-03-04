import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/category.dart';
import 'package:bloc/db/entity/product.dart';
import 'package:bloc/db/entity/person.dart';
import 'package:floor/floor.dart';

import '../entity/bloc.dart';
import '../entity/bloc_service.dart';
import '../entity/city.dart';
import '../entity/user.dart';

@dao
abstract class BlocDao {
  @Query('SELECT * FROM Person')
  Future<List<Person>> findAllPersons();

  @Query('SELECT * FROM Person WHERE id = :id')
  Stream<Person?> findPersonById(int id);

  @insert
  Future<void> insertPerson(Person person);

  @insert
  Future<void> insertUser(User user);

  @insert
  Future<void> insertCity(City city);

  @insert
  Future<void> insertBloc(Bloc bloc);

  @insert
  Future<void> insertBlocService(BlocService service);

  @insert
  Future<void> insertCategory(Category cat);

  @Query('SELECT * FROM Category ORDER BY sequence ASC')
  Stream<List<Category>> getCategories();

  /** Cart Items **/
  @insert
  Future<void> insertCartItem(CartItem cartitem);

  @Query('SELECT * FROM CartItem where userId=:userId')
  Future<List<CartItem>> getCartItems(String userId);

  @Query('DELETE FROM CartItem where productId=:prodId')
  Future<CartItem?> deleteCartItems(String prodId);

  /** Product **/
  @insert
  Future<void> insertProduct(Product product);

  @Query('SELECT * FROM Product')
  Future<List<Product>> getProducts();

  // @Query('SELECT * FROM Product where id=:productId')
  // Future<Product?> getProduct(String productId);

}