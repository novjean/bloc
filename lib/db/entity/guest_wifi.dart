class GuestWifi {
  final String id;
  final String blocServiceId;
  final String name;
  final String password;
  int creationTime;

//<editor-fold desc="Data Methods">

  GuestWifi({
    required this.id,
    required this.blocServiceId,
    required this.name,
    required this.password,
    required this.creationTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GuestWifi &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          blocServiceId == other.blocServiceId &&
          name == other.name &&
          password == other.password &&
          creationTime == other.creationTime);

  @override
  int get hashCode =>
      id.hashCode ^
      blocServiceId.hashCode ^
      name.hashCode ^
      password.hashCode ^
      creationTime.hashCode;

  @override
  String toString() {
    return 'GuestWifi{' +
        ' id: $id,' +
        ' blocServiceId: $blocServiceId,' +
        ' name: $name,' +
        ' password: $password,' +
        ' creationTime: $creationTime,' +
        '}';
  }

  GuestWifi copyWith({
    String? id,
    String? blocServiceId,
    String? name,
    String? password,
    int? creationTime,
  }) {
    return GuestWifi(
      id: id ?? this.id,
      blocServiceId: blocServiceId ?? this.blocServiceId,
      name: name ?? this.name,
      password: password ?? this.password,
      creationTime: creationTime ?? this.creationTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'blocServiceId': this.blocServiceId,
      'name': this.name,
      'password': this.password,
      'creationTime': this.creationTime,
    };
  }

  factory GuestWifi.fromMap(Map<String, dynamic> map) {
    return GuestWifi(
      id: map['id'] as String,
      blocServiceId: map['blocServiceId'] as String,
      name: map['name'] as String,
      password: map['password'] as String,
      creationTime: map['creationTime'] as int,
    );
  }

//</editor-fold>
}