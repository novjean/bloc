import 'package:bloc/db/entity/manager_service.dart';

class ManagerUtils {
  static ManagerService getManagerService(Map<String, dynamic> data, String docId) {
    String id = docId;
    String name = data['name'];
    int sequence = data['sequence'];

    ManagerService service = ManagerService(id, name, sequence);
    return service;
  }
}