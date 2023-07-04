class Promoter{
  String id;
  String name;
  String type;

//<editor-fold desc="Data Methods">
  Promoter({
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Promoter &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type);

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ type.hashCode;

  @override
  String toString() {
    return 'Promoter{' + ' id: $id,' + ' name: $name,' + ' type: $type,' + '}';
  }

  Promoter copyWith({
    String? id,
    String? name,
    String? type,
  }) {
    return Promoter(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'type': this.type,
    };
  }

  factory Promoter.fromMap(Map<String, dynamic> map) {
    return Promoter(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
    );
  }

//</editor-fold>
}