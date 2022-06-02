class InventoryOption {
  String id;
  String title;
  int sequence;

//<editor-fold desc="Data Methods">

  InventoryOption({
    required this.id,
    required this.title,
    required this.sequence,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          sequence == other.sequence);

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ sequence.hashCode;

  @override
  String toString() {
    return 'InventoryOption{' +
        ' id: $id,' +
        ' title: $title,' +
        ' sequence: $sequence,' +
        '}';
  }

  InventoryOption copyWith({
    String? id,
    String? title,
    int? sequence,
  }) {
    return InventoryOption(
      id: id ?? this.id,
      title: title ?? this.title,
      sequence: sequence ?? this.sequence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'sequence': this.sequence,
    };
  }

  factory InventoryOption.fromMap(Map<String, dynamic> map) {
    return InventoryOption(
      id: map['id'] as String,
      title: map['title'] as String,
      sequence: map['sequence'] as int,
    );
  }

//</editor-fold>
}