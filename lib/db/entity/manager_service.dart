class ManagerService {

  final String id;
  final String name;
  final int sequence;

//<editor-fold desc="Data Methods">

  const ManagerService({
    required this.id,
    required this.name,
    required this.sequence,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManagerService &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          sequence == other.sequence);

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ sequence.hashCode;

  @override
  String toString() {
    return 'ManagerService{' +
        ' id: $id,' +
        ' name: $name,' +
        ' sequence: $sequence,' +
        '}';
  }

  ManagerService copyWith({
    String? id,
    String? name,
    int? sequence,
  }) {
    return ManagerService(
      id: id ?? this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'sequence': this.sequence,
    };
  }

  factory ManagerService.fromMap(Map<String, dynamic> map) {
    return ManagerService(
      id: map['id'] as String,
      name: map['name'] as String,
      sequence: map['sequence'] as int,
    );
  }

//</editor-fold>
}