class ManagerServiceOption {
  String id;
  String name;
  int sequence;
  String service;

//<editor-fold desc="Data Methods">

  ManagerServiceOption({
    required this.id,
    required this.name,
    required this.sequence,
    required this.service,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManagerServiceOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          sequence == other.sequence &&
          service == other.service);

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ sequence.hashCode ^ service.hashCode;

  @override
  String toString() {
    return 'ManagerServiceOption{' +
        ' id: $id,' +
        ' name: $name,' +
        ' sequence: $sequence,' +
        ' service: $service,' +
        '}';
  }

  ManagerServiceOption copyWith({
    String? id,
    String? name,
    int? sequence,
    String? service,
  }) {
    return ManagerServiceOption(
      id: id ?? this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
      service: service ?? this.service,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'sequence': this.sequence,
      'service': this.service,
    };
  }

  factory ManagerServiceOption.fromMap(Map<String, dynamic> map) {
    return ManagerServiceOption(
      id: map['id'] as String,
      name: map['name'] as String,
      sequence: map['sequence'] as int,
      service: map['service'] as String,
    );
  }

//</editor-fold>
}