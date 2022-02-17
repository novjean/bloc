import '../db/entity/category.dart';

class CategoryUtils {
  static Category getCategory(Map<String, dynamic> data, String docId) {
    String id = docId;
    String name = data['name'];
    String type = data['type'];
    String serviceId = data['serviceId'];
    String imageUrl = data['imageUrl'];
    String ownerId = data['ownerId'];
    String createdAt = data['createdAt'];
    String sequence = data['sequence'];

    Category category =
        Category(id, name, type, serviceId, imageUrl, ownerId, createdAt, sequence);
    return category;
  }
}
