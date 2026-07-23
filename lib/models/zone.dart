class Zone {
  final String id;
  final String code;
  final String label;
  final String description;
  final int sortOrder;

  Zone({
    required this.id,
    required this.code,
    required this.label,
    this.description = '',
    this.sortOrder = 0,
  });

  factory Zone.fromMap(String id, Map<String, dynamic> map) => Zone(
    id: id,
    code: map['code'] as String? ?? '',
    label: map['label'] as String? ?? '',
    description: map['description'] as String? ?? '',
    sortOrder: map['sortOrder'] as int? ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'code': code,
    'label': label,
    'description': description,
    'sortOrder': sortOrder,
  };
}
