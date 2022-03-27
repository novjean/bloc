import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemUtils {
  static CartItem getCartItem(Map<String, dynamic> data, String docId) {
    String id = docId;
    int cartNumber = data['cartNumber'];
    String productId = data['productId'];
    String productName = data['productName'];
    double productPrice = data['productPrice'];
    int quantity = data['quantity'];
    String serviceId = data['serviceId'];
    String userId = data['userId'];
    int createdAt = data['createdAt'];

    CartItem ci = CartItem(
        id: id,
        serviceId: serviceId,
        cartNumber: cartNumber,
        userId: userId,
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        quantity: quantity,
        createdAt: createdAt);

    return ci;
  }

  static List<Order> extractOrders(List<CartItem> cartItems) {
    List<Order> orders=[];
    String userId=cartItems[0].userId;

    Order curOrder = Order(userId);

    for(int i=0;i<cartItems.length;i++){
      CartItem ci = cartItems[i];

      if(userId != ci.userId){
        if(i!=0){
          orders.add(curOrder);
        }
        userId = ci.userId;
        curOrder = Order(userId);
        curOrder.cartItems.add(ci);
      } else {
        curOrder.cartItems.add(ci);
      }

      if(i==cartItems.length-1){
        orders.add(curOrder);
        break;
      }
    }
    return orders;
  }
}
