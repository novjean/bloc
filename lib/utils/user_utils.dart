import '../db/entity/user.dart';

class UserUtils {
  static User getUser(Map<String, dynamic> data, String docId) {
    String userId = data['user_id'];;
    String name = data['name'];
    String username = data['username'];
    String email = data['email'];
    int clearanceLevel = data['clearance_level'];
    String imageUrl = data['image_url'];

    final User user = User(userId,
        username,
        email,
        imageUrl,
        clearanceLevel,
        name);
    return user;
  }
}