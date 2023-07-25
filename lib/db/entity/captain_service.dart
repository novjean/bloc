class CaptainService {
  final String id;
  final String name;
  final int sequence;
  final bool isActive;

//<editor-fold desc="Data Methods">
  const CaptainService({
    required this.id,
    required this.name,
    required this.sequence,
    required this.isActive,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaptainService &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          sequence == other.sequence &&
          isActive == other.isActive);

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ sequence.hashCode ^ isActive.hashCode;

  @override
  String toString() {
    return 'CaptainService{' +
        ' id: $id,' +
        ' name: $name,' +
        ' sequence: $sequence,' +
        ' isActive: $isActive,' +
        '}';
  }

  CaptainService copyWith({
    String? id,
    String? name,
    int? sequence,
    bool? isActive,
  }) {
    return CaptainService(
      id: id ?? this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'sequence': this.sequence,
      'isActive': this.isActive,
    };
  }

  factory CaptainService.fromMap(Map<String, dynamic> map) {
    return CaptainService(
      id: map['id'] as String,
      name: map['name'] as String,
      sequence: map['sequence'] as int,
      isActive: map['isActive'] as bool,
    );
  }

//</editor-fold>
}