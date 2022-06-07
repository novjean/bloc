import 'package:floor/floor.dart';

@entity
class Product {
  @primaryKey
  final String id;
  final String name;
  final String type;
  final String category;
  final String description;
  final int price;
  final String serviceId;
  final String imageUrl;
  final String ownerId;
  final String createdAt;

//<editor-fold desc="Data Methods">

  const Product({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.description,
    required this.price,
    required this.serviceId,
    required this.imageUrl,
    required this.ownerId,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          category == other.category &&
          description == other.description &&
          price == other.price &&
          serviceId == other.serviceId &&
          imageUrl == other.imageUrl &&
          ownerId == other.ownerId &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      category.hashCode ^
      description.hashCode ^
      price.hashCode ^
      serviceId.hashCode ^
      imageUrl.hashCode ^
      ownerId.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'Product{' +
        ' id: $id,' +
        ' name: $name,' +
        ' type: $type,' +
        ' category: $category,' +
        ' description: $description,' +
        ' price: $price,' +
        ' serviceId: $serviceId,' +
        ' imageUrl: $imageUrl,' +
        ' ownerId: $ownerId,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  Product copyWith({
    String? id,
    String? name,
    String? type,
    String? category,
    String? description,
    int? price,
    String? serviceId,
    String? imageUrl,
    String? ownerId,
    String? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      serviceId: serviceId ?? this.serviceId,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'type': this.type,
      'category': this.category,
      'description': this.description,
      'price': this.price,
      'serviceId': this.serviceId,
      'imageUrl': this.imageUrl,
      'ownerId': this.ownerId,
      'createdAt': this.createdAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      price: map['price'] as int,
      serviceId: map['serviceId'] as String,
      imageUrl: map['imageUrl'] as String,
      ownerId: map['ownerId'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

//</editor-fold>
}
