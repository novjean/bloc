import 'package:bloc/db/entity/bill.dart';
import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/bloc_order.dart';

class CartItemUtils {

  static List<BlocOrder> extractOrdersByTableNumber(List<CartItem> cartItems) {
    List<BlocOrder> orders = [];
    int tableNumber = cartItems[0].tableNumber;

    BlocOrder curOrder = BlocOrder(createdAt: cartItems[0].createdAt);
    curOrder.tableNumber = tableNumber;
    curOrder.customerId = cartItems[0].userId;

    for (int i = 0; i < cartItems.length; i++) {
      CartItem ci = cartItems[i];

      if (tableNumber != ci.tableNumber) {
        if (i != 0) {
          orders.add(curOrder);
        }
        tableNumber = ci.tableNumber;
        curOrder = BlocOrder(createdAt: ci.createdAt);
        curOrder.customerId = ci.userId;
        curOrder.tableNumber = tableNumber;
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

  static List<BlocOrder> extractOrdersByUserId(List<CartItem> cartItems) {
    List<BlocOrder> orders = [];
    String userId = cartItems[0].userId;
    int tableNumber = cartItems[0].tableNumber;

    BlocOrder curOrder = BlocOrder(createdAt: cartItems[0].createdAt);
    curOrder.customerId = userId;
    curOrder.tableNumber = tableNumber;

    for (int i = 0; i < cartItems.length; i++) {
      CartItem ci = cartItems[i];

      if (userId != ci.userId) {
        if (i != 0) {
          orders.add(curOrder);
        }
        userId = ci.userId;
        curOrder = BlocOrder(createdAt: ci.createdAt);
        curOrder.customerId=userId;
        curOrder.tableNumber = ci.tableNumber;
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

  static List<BlocOrder> extractOrdersByTime(List<CartItem> cartItems) {
    List<BlocOrder> orders = [];
    int createdAt  = cartItems[0].createdAt;

    BlocOrder curOrder = BlocOrder(createdAt: cartItems[0].createdAt);
    curOrder.customerId = cartItems[0].userId;
    curOrder.tableNumber = cartItems[0].tableNumber;

    for (int i=0;i< cartItems.length; i++){
      CartItem ci = cartItems[i];

      if(createdAt!=ci.createdAt){
        if (i != 0) {
          orders.add(curOrder);
        }
        createdAt = ci.createdAt;
        curOrder = BlocOrder(createdAt: ci.createdAt);
        curOrder.customerId = ci.userId;
        curOrder.tableNumber = ci.tableNumber;
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

  static List<BlocOrder> createOngoingOrdersBill(List<CartItem> cartItems) {
    List<BlocOrder> orders = [];

    int createdAt  = cartItems[0].createdAt;
    String userId = cartItems[0].userId;
    int tableNumber = cartItems[0].tableNumber;

    BlocOrder order = BlocOrder(createdAt: createdAt);
    order.customerId = userId;
    order.tableNumber = tableNumber;

    for (int i=0;i< cartItems.length; i++){
      CartItem ci = cartItems[i];
      order.cartItems.add(ci);
      order.total += ci.productPrice * ci.quantity;

      if (i == cartItems.length - 1) {
        orders.add(order);
        break;
      }
    }
    return orders;
  }

  static List<BlocOrder> extractOrdersByBillId(List<CartItem> cartItems) {
    String billId = cartItems[0].billId;

    List<BlocOrder> orders = [];
    int createdAt  = cartItems[0].createdAt;

    BlocOrder curOrder = BlocOrder(createdAt: cartItems[0].createdAt);
    curOrder.customerId = cartItems[0].userId;
    curOrder.tableNumber = cartItems[0].tableNumber;

    for (int i=0;i< cartItems.length; i++){
      CartItem ci = cartItems[i];

      if(createdAt!=ci.createdAt){
        if (i != 0) {
          orders.add(curOrder);
        }
        createdAt = ci.createdAt;
        curOrder = BlocOrder(createdAt: ci.createdAt);
        curOrder.customerId = ci.userId;
        curOrder.tableNumber = ci.tableNumber;
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

    String billId = cartItems[0].billId;
    String userId = cartItems[0].userId;
    int orderNumber = 1;
    int curCreatedAt = cartItems[0].createdAt;

    List<BlocOrder> orders = [];
    BlocOrder curOrder = BlocOrder(createdAt: curCreatedAt);
    curOrder.customerId = userId;
    curOrder.tableNumber = cartItems[0].tableNumber;
    curOrder.sequence = orderNumber;
    for (int i = 0; i < cartItems.length; i++) {
      CartItem ci = cartItems[i];

      if (curCreatedAt != ci.createdAt) {
        if (i != 0) {
          orders.add(curOrder);
        }
        curCreatedAt = ci.createdAt;
        curOrder = BlocOrder(createdAt: curCreatedAt);
        curOrder.customerId = userId;
        curOrder.tableNumber = ci.tableNumber;
        curOrder.sequence = ++orderNumber;
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
    Bill bill = Bill(billId: billId, custId: userId, orders: orders);
    return bill;
  }

  static List<Bill> extractBills(List<CartItem> cartItems) {
    List<Bill> bills = [];
    List<CartItem> billCartItems = [];
    String curBillId = '';

    for(int i=0;i<cartItems.length; i++){
      CartItem ci = cartItems[i];
      if(curBillId.isEmpty){
        curBillId = ci.billId;
      }

      if(curBillId.compareTo(ci.billId)==0){
        billCartItems.add(ci);
      } else {
        Bill bill = extractBill(billCartItems);
        bills.add(bill);
        curBillId = '';
        billCartItems.clear();
      }
    }
    return bills;
  }

}
