
import 'package:flutter/material.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc_service.dart';
import '../widgets/ui/cover_photo.dart';
import '../widgets/ui/expandable_fab.dart';
import 'cart_screen.dart';
import 'forms/new_product_screen.dart';
import 'forms/new_service_category_screen.dart';

class NewBlocServiceDetailScreen extends StatelessWidget{
  BlocDao dao;
  BlocService service;

  NewBlocServiceDetailScreen({key, required this.dao, required this.service})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.name),
      ),
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => {
              // _showAction(context, 0)
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => CartScreen(service: service, dao:dao)),
              ),
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          ActionButton(
            onPressed: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => NewProductScreen(service: service)),
              ),
            },
            icon: const Icon(Icons.fastfood),
          ),
          ActionButton(
            onPressed: () => {
              // _showAction(context, 2),
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => NewServiceCategoryScreen(service: service, dao:dao)),
              ),
            },
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CoverPhoto(service.name, service.imageUrl),
          SizedBox(height: 20.0),

          _buildArticleTitleAndDate(),
          _buildArticleImage(),
          _buildArticleDescription(),
        ],
      ),
    );
  }

  Widget _buildArticleTitleAndDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            article.title,
            style: const TextStyle(fontFamily: 'Butler', fontSize: 20, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 14),
          // DateTime
          Row(
            children: [
              const Icon(Ionicons.time_outline, size: 16),
              const SizedBox(width: 4),
              Text(
                article.publishedAt,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }


}