import 'package:flutter/material.dart';

import '../models/device.dart';
import '../models/sensor_reading.dart';
import '../services/api_service.dart';
import '../utils.dart';
import '../widgets/app_states.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.device});

  final Device device;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SensorReading> _readings = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.device.id != widget.device.id) _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await apiService.getReadingHistory(widget.device.id, limit: 50);
      if (!mounted) return;
      setState(() => _readings = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor history'),
        actions: [
          IconButton(
            tooltip: 'Refresh history',
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const AppLoadingState(message: 'Loading sensor history…')
          : _error != null
              ? AppErrorState(
                  title: 'Could not load history',
                  message: _error!,
                  onRetry: _loadHistory,
                )
              : _readings.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: Text(
                          'No sensor readings have been saved for this device yet. '
                          'When your ESP8266 posts data to /api/readings, it will appear here.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _readings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _HistoryCard(
                          reading: _readings[index],
                          index: index,
                        ),
                      ),
                    ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.reading, required this.index});

  final SensorReading reading;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.green.shade50),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4EB),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF187A3D),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formatDateTime(reading.recordedAt),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Icon(
                  reading.pumpOn ? Icons.play_circle_fill_rounded : Icons.stop_circle_rounded,
                  color: reading.pumpOn ? Colors.green : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ReadingChip(label: 'Temperature', value: '${reading.temperature.toStringAsFixed(1)}°C'),
                _ReadingChip(label: 'Humidity', value: '${reading.humidity.toStringAsFixed(1)}%'),
                _ReadingChip(label: 'Moisture', value: '${reading.soilMoisture.toStringAsFixed(0)}%'),
                _ReadingChip(label: 'Soil pH', value: reading.soilPh.toStringAsFixed(2)),
                _ReadingChip(
                  label: 'Watering duration',
                  value: '${reading.wateringDurationMinutes.toStringAsFixed(1)} min',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingChip extends StatelessWidget {
  const _ReadingChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
