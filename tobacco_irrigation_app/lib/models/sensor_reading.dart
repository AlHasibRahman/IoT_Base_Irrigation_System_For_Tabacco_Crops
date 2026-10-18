class SensorReading {
  const SensorReading({
    required this.id,
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.soilPh,
    required this.pumpOn,
    required this.wateringDurationMinutes,
    required this.recordedAt,
  });

  final int id;
  final int deviceId;
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double soilPh;
  final bool pumpOn;
  final double wateringDurationMinutes;
  final DateTime? recordedAt;

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      id: _asInt(_read(json, 'id', 'Id')),
      deviceId: _asInt(_read(json, 'deviceId', 'DeviceId')),
      temperature: _asDouble(_read(json, 'temperature', 'Temperature')),
      humidity: _asDouble(_read(json, 'humidity', 'Humidity')),
      soilMoisture: _asDouble(_read(json, 'soilMoisture', 'SoilMoisture')),
      soilPh: _asDouble(_read(json, 'soilPh', 'SoilPh')),
      pumpOn: _asBool(_read(json, 'pumpOn', 'PumpOn')),
      wateringDurationMinutes: _asDouble(
        _read(json, 'wateringDurationMinutes', 'WateringDurationMinutes'),
      ),
      recordedAt: _asDateTime(_read(json, 'recordedAt', 'RecordedAt')),
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

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1' || text == 'on';
}

DateTime? _asDateTime(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}
