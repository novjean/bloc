import 'package:bloc/db/entity/bill.dart';
import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/order.dart';

class CartItemUtils {
  static List<Order> extractOrders(List<CartItem> cartItems) {
    List<Order> orders = [];
    String userId = cartItems[0].userId;

    Order curOrder = Order(userId);

    for (int i = 0; i < cartItems.length; i++) {
      CartItem ci = cartItems[i];

      if (userId != ci.userId) {
        if (i != 0) {
          orders.add(curOrder);
        }
        userId = ci.userId;
        curOrder = Order(userId);
        curOrder.cartItems.add(ci);
        curOrder.total += ci.productPrice * ci.quantity;
      } else {
        curOrder.total += ci.productPrice * ci.quantity;
        curOrder.cartItems.add(ci);
      }

      if (i == cartItems.length - 1) {
        orders.add(curOrder);
        break;
      }
    }
    return orders;
  }

  static Bill extractBill(List<CartItem> cartItems) {
    cartItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    String userId = cartItems[0].userId;
    int orderNumber = 1;
    int curCreatedAt = cartItems[0].createdAt;

    List<Order> orders = [];
    Order curOrder = Order(userId);
    curOrder.number = orderNumber;
    for (int i = 0; i < cartItems.length; i++) {
      CartItem ci = cartItems[i];

      if (curCreatedAt != ci.createdAt) {
        if (i != 0) {
          orders.add(curOrder);
        }
        curCreatedAt = ci.createdAt;
        curOrder = Order(userId);
        curOrder.number = ++orderNumber;
        curOrder.cartItems.add(ci);
        curOrder.total += ci.productPrice * ci.quantity;
      } else {
        curOrder.total += ci.productPrice * ci.quantity;
        curOrder.cartItems.add(ci);
      }

      if (i == cartItems.length - 1) {
        orders.add(curOrder);
        break;
      }
    }
    Bill bill = Bill(userId, orders);
    return bill;
  }

  // static Bill extractPendingOrders(List<CartItem> cartItems) {
  //   cartItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  //
  //   String userId = cartItems[0].userId;
  //   int orderNumber = 1;
  //   int curCreatedAt = cartItems[0].createdAt;
  //
  //   List<Order> orders = [];
  //   Order curOrder = Order(userId);
  //   curOrder.number = orderNumber;
  //   for (int i = 0; i < cartItems.length; i++) {
  //     CartItem ci = cartItems[i];
  //     if(ci.isCompleted)
  //       continue;
  //
  //     if (curCreatedAt != ci.createdAt) {
  //       if (i != 0) {
  //         orders.add(curOrder);
  //       }
  //       curCreatedAt = ci.createdAt;
  //       curOrder = Order(userId);
  //       curOrder.number = ++orderNumber;
  //       curOrder.cartItems.add(ci);
  //       curOrder.total += ci.productPrice * ci.quantity;
  //     } else {
  //       curOrder.total += ci.productPrice * ci.quantity;
  //       curOrder.cartItems.add(ci);
  //     }
  //
  //     if (i == cartItems.length - 1) {
  //       orders.add(curOrder);
  //       break;
  //     }
  //   }
  //   Bill bill = Bill(userId, orders);
  //   return bill;
  // }
}
