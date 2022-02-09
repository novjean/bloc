import 'package:bloc/db/entity/bloc_service.dart';
import 'package:flutter/material.dart';

import '../db/dao/bloc_dao.dart';

class BlocServiceDetailScreen extends StatelessWidget {
  BlocDao dao;
  BlocService service;

  BlocServiceDetailScreen({key, required this.dao, required this.service})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.name),
      ),
      body: Center(
        child: Text('Loading...'),
      ),
    );
  }
}