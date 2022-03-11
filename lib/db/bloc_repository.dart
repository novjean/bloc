
import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/category.dart';
import 'package:bloc/db/entity/product.dart';
import 'package:bloc/db/entity/user.dart';
import 'package:logger/logger.dart';

import 'entity/bloc.dart';
import 'entity/bloc_service.dart';
import 'entity/city.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class BlocRepository {
  /** User **/
  static void insertUser(BlocDao dao, User user) async {
    logger.i("insertUser(): " + user.username);
    await dao.insertUser(user);
  }

  /** City **/
  static void insertCity(BlocDao dao, City city) async {
    logger.i("insertCity(): " + city.name);
    await dao.insertCity(city);
  }

  /** Bloc **/
  static void insertBloc(BlocDao dao, Bloc bloc) async {
    logger.i("insertBloc(): " + bloc.name);
    await dao.insertBloc(bloc);
  }

  /** Service **/
  static void insertBlocService(BlocDao dao, BlocService service) async {
    logger.i("insertBlocService(): " + service.name);
    await dao.insertBlocService(service);
  }

  /** Category **/
  static void insertCategory(BlocDao dao, Category cat) async {
    logger.i("insertCategory(): " + cat.name);
    await dao.insertCategory(cat);
  }

  /** Cart Item **/
  static void insertCartItem(BlocDao dao, CartItem cartitem) async {
    logger.i("insertCartItem(): " + cartitem.id);
    await dao.insertCartItem(cartitem);
  }

  static Future<List<CartItem>> getCartItems(BlocDao dao, String userId) {
    logger.i("getProducts(): ");
    Future<List<CartItem>> fCartItems = dao.getCartItems(userId);
    return fCartItems;
  }

  static void deleteCartItems(BlocDao dao, String productId) {
    logger.i("deleteCartItems(): " + productId);
    dao.deleteCartItems(productId);
  }

  /** Product **/
  static void insertProduct(BlocDao dao, Product product) async {
    logger.i("insertProduct(): " + product.name);
    await dao.insertProduct(product);
  }

  static Future<List<Product>> getProducts(BlocDao dao) async {
    logger.i("getProducts(): ");
    Future<List<Product>> fProducts = dao.getProducts();
    return fProducts;
  }

  static Future<List<Product>> getProductsByCategory(BlocDao dao, String catType) async {
    logger.i("getProductsByCategory(): " + catType);
    Future<List<Product>> fProducts = dao.getProductsByCategory(catType);
    return fProducts;
  }

  // static Future<Product?> getProduct(BlocDao dao, String productId) async {
  //   logger.i("getProduct(): " + productId);
  //   return dao.getProduct(productId);
  // }
}