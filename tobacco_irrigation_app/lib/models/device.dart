class Device {
  const Device({
    required this.id,
    required this.name,
    required this.fieldName,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String fieldName;
  final DateTime? createdAt;

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: _asInt(_read(json, 'id', 'Id')),
      name: _asString(_read(json, 'name', 'Name'), fallback: 'Unnamed device'),
      fieldName: _asString(
        _read(json, 'fieldName', 'FieldName'),
        fallback: 'Field not specified',
      ),
      createdAt: _asDateTime(_read(json, 'createdAt', 'CreatedAt')),
    );
  }
}

Object? _read(Map<String, dynamic> json, String camelCase, String pascalCase) {
  return json[camelCase] ?? json[pascalCase];
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _asString(Object? value, {required String fallback}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

DateTime? _asDateTime(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}
