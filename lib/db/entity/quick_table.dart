class QuickTable {
  final String id;
  final int phone;
  final String tableName;
  final int createdAt;

//<editor-fold desc="Data Methods">
  const QuickTable({
    required this.id,
    required this.phone,
    required this.tableName,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuickTable &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          phone == other.phone &&
          tableName == other.tableName &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^ phone.hashCode ^ tableName.hashCode ^ createdAt.hashCode;

  @override
  String toString() {
    return 'QuickTable{' +
        ' id: $id,' +
        ' phone: $phone,' +
        ' tableName: $tableName,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  QuickTable copyWith({
    String? id,
    int? phone,
    String? tableName,
    int? createdAt,
  }) {
    return QuickTable(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      tableName: tableName ?? this.tableName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'phone': this.phone,
      'tableName': this.tableName,
      'createdAt': this.createdAt,
    };
  }

  factory QuickTable.fromMap(Map<String, dynamic> map) {
    return QuickTable(
      id: map['id'] as String,
      phone: map['phone'] as int,
      tableName: map['tableName'] as String,
      createdAt: map['createdAt'] as int,
    );
  }

//</editor-fold>
}