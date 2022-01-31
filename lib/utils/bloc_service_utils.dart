import '../db/entity/bloc_service.dart';

class BlocServiceUtils {
  static BlocService getBlocService(Map<String, dynamic> data, String docId) {
    String id = docId;
    String name = data['name'];
    String blocId = data['blocId'];
    String type = data['type'];
    double primaryNumber = double.parse(data['primaryPhone']);
    double secondaryNumber = double.parse(data['secondaryPhone']);
    String email = data['emailId'];
    String imageUrl = data['imageUrl'];
    String ownerId = data['ownerId'];
    String createdAt = data['createdAt'];

    BlocService service = BlocService(id, name, blocId, type, primaryNumber, secondaryNumber,
        email, imageUrl, ownerId, createdAt);
    return service;
  }
}