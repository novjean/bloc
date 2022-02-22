import '../db/entity/product.dart';

class ProductUtils {
  static Product getProduct(Map<String, dynamic> data, String docId) {
    String id = docId;
    String name = data['name'];
    String type = data['type'];
    String description = data['description'];
    int price = data['price'];
    String serviceId = data['serviceId'];
    String imageUrl = data['imageUrl'];
    String ownerId = data['ownerId'];
    String createdAt = data['createdAt'];

    Product product = Product(id, name, type, description, price, serviceId, imageUrl, ownerId, createdAt);
    return product;
  }}