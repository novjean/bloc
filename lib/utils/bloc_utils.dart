import 'package:bloc/db/entity/bloc.dart';

class BlocUtils {
  static Bloc getBloc(Map<String, dynamic> data, String docId) {
    String id = docId;
    String name = data['name'];
    String cityName = data['city'];
    String addressLine1 = data['addressLine1'];
    String addressLine2 = data['addressLine2'];
    String pinCode = data['pinCode'];
    String imageUrl = data['imageUrl'];
    String ownerId = data['ownerId'];
    String createdAt = data['createdAt'];

    Bloc bloc = Bloc(id, name, cityName, addressLine1, addressLine2, pinCode,
        imageUrl, ownerId, createdAt);
    return bloc;
  }
}
