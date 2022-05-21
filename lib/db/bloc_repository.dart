
import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/category.dart';
import 'package:bloc/db/entity/manager_service.dart';
import 'package:bloc/db/entity/product.dart';
import 'package:bloc/db/entity/seat.dart';
import 'package:bloc/db/entity/service_table.dart';
import 'package:bloc/db/entity/user.dart';
import 'package:logger/logger.dart';

import 'entity/bloc.dart';
import 'entity/bloc_service.dart';
import 'entity/city.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class BlocRepository {
  /** City **/
  static void insertCity(BlocDao dao, City city) async {
    await dao.insertCity(city);
  }

  /** Bloc **/
  static void insertBloc(BlocDao dao, Bloc bloc) async {
    await dao.insertBloc(bloc);
  }

  /** Service **/
  static void insertBlocService(BlocDao dao, BlocService service) async {
    await dao.insertBlocService(service);
  }

  /** Category **/
  static void insertCategory(BlocDao dao, Category cat) async {
    await dao.insertCategory(cat);
  }

  static Stream<List<Category>> getCategories(BlocDao dao) {
    return dao.getCategories();
  }

  static Future<List<Category>> getCategoriesFuture(BlocDao dao) async {
    logger.i("getCategoriesFuture(): ");
    Future<List<Category>> fCats = dao.getCategoriesFuture();
    return fCats;
  }

  static void clearCategories(BlocDao dao) {
    dao.clearCategories();
  }

  /** Cart Item **/
  static void insertCartItem(BlocDao dao, CartItem cartitem) {
    dao.insertCartItem(cartitem);
  }

  static Future<List<CartItem>> getCartItems(BlocDao dao, String userId) {
    logger.i("getCartItems(): ");
    Future<List<CartItem>> fCartItems = dao.getCartItems(userId);
    return fCartItems;
  }

  static Future<List<CartItem>> getCartItemsByTableNumber(BlocDao dao, String serviceId) {
    logger.i("getCartItemsByTableNumber(): ");
    Future<List<CartItem>> fCartItems = dao.getCartItemsByTableNumber(serviceId);
    return fCartItems;
  }


  static Future<List<CartItem>> getSortedCartItems(BlocDao dao,String serviceId) {
    logger.i("getSortedCartItems(): ");
    Future<List<CartItem>> fCartItems = dao.getSortedCartItems(serviceId);
    return fCartItems;
  }

  static void deleteCartItems(BlocDao dao, String productId) {
    logger.i("deleteCartItems(): " + productId);
    dao.deleteCartItems(productId);
  }

  /** Manager Service **/
  static void insertManagerService(BlocDao dao, ManagerService ms) async {
    logger.i("insertManagerService(): ");
    await dao.insertManagerService(ms);
  }

  /** Product **/
  static void insertProduct(BlocDao dao, Product product) async {
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

  static void clearProducts(BlocDao dao) {
    dao.clearProducts();
  }

  /** User **/
  static void insertUser(BlocDao dao, User user) async {
    logger.i("insertUser(): " + user.username);
    await dao.insertUser(user);
  }
  static void updateUser(BlocDao dao, User user) async {
    logger.i("updateUser(): " + user.username);
    await dao.updateUser(user);
  }

  /** Service Table **/
  static void insertServiceTable(BlocDao dao, ServiceTable serviceTable) async {
    logger.i('insertServiceTable(): ');
    await dao.insertServiceTable(serviceTable);
  }

  static void updateTableOccupyStatus(BlocDao dao, String serviceId, int tableNumber, bool occupyStatus) async {
    logger.i('updateTableOccupied(): ');
    await dao.updateTableOccupied(serviceId, tableNumber, occupyStatus);
  }

  /** Seat **/
  static void insertSeat(BlocDao dao, Seat seat) async {
    logger.i('insertSeat(): ');
    await dao.insertSeat(seat);
  }

  static void updateCustInSeat(BlocDao dao, String seatId, String custId) async {
    logger.i('updateCustInSeat(): ');
    await dao.updateCustInSeat(seatId, custId);
  }

  static Future<List<Seat>> getSeats(BlocDao dao, String serviceId, int tableNumber) {
    logger.i('getSeats() for table : ' + tableNumber.toString());

    Future<List<Seat>> fSeats = dao.getSeats(serviceId, tableNumber);
    return fSeats;

  }


}
