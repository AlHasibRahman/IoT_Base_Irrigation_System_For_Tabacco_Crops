import 'package:flutter/material.dart';

import 'models/device.dart';
import 'screens/devices_screen.dart';
import 'screens/history_screen.dart';
import 'screens/overview_screen.dart';
import 'services/api_service.dart';
import 'widgets/app_states.dart';

class TobaccoIrrigationApp extends StatelessWidget {
  const TobaccoIrrigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF187A3D);
    return MaterialApp(
      title: 'Tobacco Irrigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: const Color(0xFFF5F8F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F8F5),
          foregroundColor: Color(0xFF173D28),
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  List<Device> _devices = const [];
  int? _selectedDeviceId;
  int _selectedTab = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final devices = await apiService.getDevices();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        if (devices.isEmpty) {
          _selectedDeviceId = null;
        } else if (_selectedDeviceId == null ||
            !devices.any((device) => device.id == _selectedDeviceId)) {
          _selectedDeviceId = devices.first.id;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectDevice(Device device) {
    setState(() {
      _selectedDeviceId = device.id;
      _selectedTab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDevice = _devices.cast<Device?>().firstWhere(
          (device) => device?.id == _selectedDeviceId,
          orElse: () => null,
        );

    Widget body;
    if (_loading) {
      body = const AppLoadingState(message: 'Connecting to your irrigation API…');
    } else if (_error != null) {
      body = AppErrorState(
        title: 'Could not load devices',
        message: '$_error\n\nAPI URL: ${ApiService.baseUrl}',
        onRetry: _loadDevices,
      );
    } else if (_devices.isEmpty) {
      body = _NoDevicesState(onRetry: _loadDevices);
    } else {
      switch (_selectedTab) {
        case 1:
          body = HistoryScreen(device: selectedDevice!);
          break;
        case 2:
          body = DevicesScreen(
            devices: _devices,
            selectedDeviceId: _selectedDeviceId,
            onSelectDevice: _selectDevice,
            onRefresh: _loadDevices,
          );
          break;
        default:
          body = OverviewScreen(device: selectedDevice!);
          break;
      }
    }

    return Scaffold(
      body: SafeArea(child: body),
      bottomNavigationBar: _loading || _error != null || _devices.isEmpty
          ? null
          : NavigationBar(
              selectedIndex: _selectedTab,
              onDestinationSelected: (index) => setState(() => _selectedTab = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Overview',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_rounded),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.sensors_rounded),
                  selectedIcon: Icon(Icons.sensors),
                  label: 'Devices',
                ),
              ],
            ),
    );
  }
}

class _NoDevicesState extends StatelessWidget {
  const _NoDevicesState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sensors_off_rounded, size: 58, color: Color(0xFF187A3D)),
            const SizedBox(height: 16),
            Text(
              'No irrigation devices yet',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'The API is reachable, but GET /api/devices returned an empty list. '
              'Add a Device row to your SQL Server database, then try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reload devices'),
            ),
          ],
        ),
      ),
    );
  }
}
