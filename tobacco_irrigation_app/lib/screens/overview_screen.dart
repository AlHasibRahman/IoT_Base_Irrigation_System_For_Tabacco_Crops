import 'dart:async';

import 'package:flutter/material.dart';

import '../models/device.dart';
import '../models/sensor_metric.dart';
import '../models/sensor_reading.dart';
import '../services/api_service.dart';
import '../utils.dart';
import '../widgets/app_states.dart';
import '../widgets/metric_card.dart';
import 'sensor_detail_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key, required this.device});

  final Device device;

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  SensorReading? _reading;
  bool _loading = true;
  bool _requestInProgress = false;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadLatest();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadLatest(showSpinner: false),
    );
  }

  @override
  void didUpdateWidget(covariant OverviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.device.id != widget.device.id) {
      _reading = null;
      _loadLatest();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLatest({bool showSpinner = true}) async {
    if (_requestInProgress) return;
    _requestInProgress = true;
    if (showSpinner && mounted) setState(() => _loading = true);

    try {
      final latest = await apiService.getLatestReading(widget.device.id);
      if (!mounted) return;
      setState(() {
        _reading = latest;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      _requestInProgress = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDetail(SensorMetric metric) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SensorDetailScreen(
          device: widget.device,
          metric: metric,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reading = _reading;
    return RefreshIndicator(
      onRefresh: () => _loadLatest(showSpinner: false),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF187A3D),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tobacco Care',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Text('Drip irrigation monitoring system'),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh sensor data',
                onPressed: () => _loadLatest(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF176B36), Color(0xFF39A95E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.eco_rounded, color: Colors.white, size: 29),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.device.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.device.fieldName,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'DEVICE #${widget.device.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Live sensor dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Text(
                'Auto-refresh: 10s',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reading?.recordedAt == null
                ? 'Waiting for the first sensor reading'
                : 'Last update: ${formatDateTime(reading!.recordedAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          if (_loading && reading == null) ...[
            const SizedBox(height: 24),
            const AppLoadingState(message: 'Fetching sensor readings…'),
          ] else ...[
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Could not update sensor data: $_error',
                  style: const TextStyle(color: Color(0xFF8B3B00)),
                ),
              ),
            ],
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final spacing = 12.0;
                final cardWidth = (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: MetricCard(
                        title: 'Temperature & humidity',
                        value: reading == null
                            ? '--'
                            : '${reading.temperature.toStringAsFixed(1)}°C',
                        subtitle: reading == null
                            ? 'No reading available'
                            : 'Humidity ${reading.humidity.toStringAsFixed(1)}%',
                        icon: Icons.thermostat_rounded,
                        iconColor: const Color(0xFFE87532),
                        onTap: () => _openDetail(SensorMetric.temperatureHumidity),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: MetricCard(
                        title: 'Soil moisture',
                        value: reading == null
                            ? '--'
                            : '${reading.soilMoisture.toStringAsFixed(0)}%',
                        subtitle: 'Water available in soil',
                        icon: Icons.water_drop_rounded,
                        iconColor: const Color(0xFF2489C9),
                        onTap: () => _openDetail(SensorMetric.soilMoisture),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: MetricCard(
                        title: 'Soil pH',
                        value: reading == null ? '--' : reading.soilPh.toStringAsFixed(2),
                        subtitle: 'Soil acidity / alkalinity',
                        icon: Icons.science_rounded,
                        iconColor: const Color(0xFF8D62C7),
                        onTap: () => _openDetail(SensorMetric.soilPh),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: MetricCard(
                        title: 'Water pump',
                        value: reading == null ? '--' : (reading.pumpOn ? 'ON' : 'OFF'),
                        subtitle: reading == null
                            ? 'Status unavailable'
                            : reading.pumpOn
                                ? 'Pump is running'
                                : 'Pump is stopped',
                        icon: Icons.settings_input_component_rounded,
                        iconColor: reading?.pumpOn == true
                            ? const Color(0xFF21834A)
                            : const Color(0xFF68746C),
                        onTap: () => _openDetail(SensorMetric.pumpStatus),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4EB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF187A3D)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Values are read from your ASP.NET Core API. '
                    'This app monitors pump status; it does not switch the pump on or off.',
                    style: TextStyle(color: Color(0xFF245C39), height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
