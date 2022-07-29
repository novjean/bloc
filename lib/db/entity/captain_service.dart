import 'package:floor/floor.dart';

@entity
class CaptainService {
  @primaryKey
  final String id;
  final String name;
  final int sequence;

//<editor-fold desc="Data Methods">

  const CaptainService({
    required this.id,
    required this.name,
    required this.sequence,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaptainService &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          sequence == other.sequence);

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ sequence.hashCode;

  @override
  String toString() {
    return 'CaptainService{' +
        ' id: $id,' +
        ' name: $name,' +
        ' sequence: $sequence,' +
        '}';
  }

  CaptainService copyWith({
    String? id,
    String? name,
    int? sequence,
  }) {
    return CaptainService(
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

  factory CaptainService.fromMap(Map<String, dynamic> map) {
    return CaptainService(
      id: map['id'] as String,
      name: map['name'] as String,
      sequence: map['sequence'] as int,
    );
  }

//</editor-fold>
}