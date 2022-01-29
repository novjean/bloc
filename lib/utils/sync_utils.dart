
import 'package:cloud_firestore/cloud_firestore.dart';

import '../db/dao/bloc_dao.dart';

class SyncUtils {
  BlocDao dao;

  SyncUtils(this.dao);

  void loadData() {
    loadCities();
  }

  void loadCities() {
    FirebaseFirestore.instance.collection('cities').get()
    .whenComplete(() => {

    });
  }

}