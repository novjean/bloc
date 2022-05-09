import '../db/entity/user.dart';

class UserUtils {
  static User getUser(Map<String, dynamic> data) {
    String userId = data['user_id'];
    String name = data['name'];
    String username = data['username'];
    String email = data['email'];
    int clearanceLevel = data['clearance_level'];
    String imageUrl = data['image_url'];
    int phoneNumber = data['phone_number'];

    final User user = User(userId:userId,
        username:username,
        email:email,
        imageUrl:imageUrl,
        clearanceLevel:clearanceLevel,
        phoneNumber: phoneNumber,
        name:name);
    return user;
  }
}