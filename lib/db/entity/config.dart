class Config{
  final String id;
  final String name;
  final String blocServiceId;
  final bool value;

//<editor-fold desc="Data Methods">
  const Config({
    required this.id,
    required this.name,
    required this.blocServiceId,
    required this.value,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Config &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          blocServiceId == other.blocServiceId &&
          value == other.value);

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ blocServiceId.hashCode ^ value.hashCode;

  @override
  String toString() {
    return 'Config{' +
        ' id: $id,' +
        ' name: $name,' +
        ' blocServiceId: $blocServiceId,' +
        ' value: $value,' +
        '}';
  }

  Config copyWith({
    String? id,
    String? name,
    String? blocServiceId,
    bool? value,
  }) {
    return Config(
      id: id ?? this.id,
      name: name ?? this.name,
      blocServiceId: blocServiceId ?? this.blocServiceId,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'blocServiceId': this.blocServiceId,
      'value': this.value,
    };
  }

  factory Config.fromMap(Map<String, dynamic> map) {
    return Config(
      id: map['id'] as String,
      name: map['name'] as String,
      blocServiceId: map['blocServiceId'] as String,
      value: map['value'] as bool,
    );
  }

//</editor-fold>
}