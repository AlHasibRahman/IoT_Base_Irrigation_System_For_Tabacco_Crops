import 'package:flutter/material.dart';

import '../models/device.dart';
import '../models/sensor_metric.dart';
import '../models/sensor_reading.dart';
import '../services/api_service.dart';
import '../utils.dart';
import '../widgets/app_states.dart';

class SensorDetailScreen extends StatefulWidget {
  const SensorDetailScreen({
    super.key,
    required this.device,
    required this.metric,
  });

  final Device device;
  final SensorMetric metric;

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen> {
  SensorReading? _latest;
  List<SensorReading> _history = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reading = await apiService.getLatestReading(widget.device.id);
      final history = await apiService.getReadingHistory(widget.device.id, limit: 50);
      if (!mounted) return;
      setState(() {
        _latest = reading;
        _history = history;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _title => switch (widget.metric) {
        SensorMetric.temperatureHumidity => 'Temperature & humidity',
        SensorMetric.soilMoisture => 'Soil moisture',
        SensorMetric.soilPh => 'Soil pH',
        SensorMetric.pumpStatus => 'Pump status',
      };

  IconData get _icon => switch (widget.metric) {
        SensorMetric.temperatureHumidity => Icons.thermostat_rounded,
        SensorMetric.soilMoisture => Icons.water_drop_rounded,
        SensorMetric.soilPh => Icons.science_rounded,
        SensorMetric.pumpStatus => Icons.settings_input_component_rounded,
      };

  String _value(SensorReading reading) => switch (widget.metric) {
        SensorMetric.temperatureHumidity =>
          '${reading.temperature.toStringAsFixed(1)}°C  •  ${reading.humidity.toStringAsFixed(1)}%',
        SensorMetric.soilMoisture => '${reading.soilMoisture.toStringAsFixed(0)}%',
        SensorMetric.soilPh => reading.soilPh.toStringAsFixed(2),
        SensorMetric.pumpStatus => reading.pumpOn ? 'ON' : 'OFF',
      };

  String _historyLabel(SensorReading reading) => switch (widget.metric) {
        SensorMetric.temperatureHumidity =>
          'Temp ${reading.temperature.toStringAsFixed(1)}°C  •  Humidity ${reading.humidity.toStringAsFixed(1)}%',
        SensorMetric.soilMoisture => 'Soil moisture: ${reading.soilMoisture.toStringAsFixed(0)}%',
        SensorMetric.soilPh => 'Soil pH: ${reading.soilPh.toStringAsFixed(2)}',
        SensorMetric.pumpStatus => 'Pump ${reading.pumpOn ? 'ON' : 'OFF'}',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            tooltip: 'Refresh values',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading && _latest == null
          ? const AppLoadingState(message: 'Loading sensor details…')
          : _error != null && _latest == null
              ? AppErrorState(
                  title: 'Could not load sensor details',
                  message: _error!,
                  onRetry: _load,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
                    children: [
                      Text(
                        widget.device.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF176B36), Color(0xFF39A95E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(_icon, color: Colors.white, size: 34),
                            const SizedBox(height: 18),
                            Text(
                              'Current ${_title.toLowerCase()}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _latest == null ? '--' : _value(_latest!),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Updated: ${formatDateTime(_latest?.recordedAt)}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text('Refresh warning: $_error', style: const TextStyle(color: Colors.deepOrange)),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Recent readings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 10),
                      if (_history.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(18),
                          child: Text('No saved readings for this device yet.'),
                        )
                      else
                        for (final reading in _history)
                          Card(
                            color: Colors.white,
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.green.shade50),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE8F4EB),
                                child: Icon(Icons.show_chart_rounded, color: Color(0xFF187A3D)),
                              ),
                              title: Text(_historyLabel(reading)),
                              subtitle: Text(formatDateTime(reading.recordedAt)),
                            ),
                          ),
                      const SizedBox(height: 6),
                      const Text(
                        'History is loaded from GET /api/devices/{id}/readings. '
                        'The API returns the newest readings first.',
                        style: TextStyle(color: Colors.black54, height: 1.4),
                      ),
                    ],
                  ),
                ),
    );
  }
}
