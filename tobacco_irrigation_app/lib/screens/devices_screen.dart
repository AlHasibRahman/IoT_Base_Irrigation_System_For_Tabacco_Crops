import 'package:flutter/material.dart';

import '../models/device.dart';
import '../utils.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({
    super.key,
    required this.devices,
    required this.selectedDeviceId,
    required this.onSelectDevice,
    required this.onRefresh,
  });

  final List<Device> devices;
  final int? selectedDeviceId;
  final ValueChanged<Device> onSelectDevice;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My devices'),
        actions: [
          IconButton(
            tooltip: 'Reload devices',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Choose the device you want to monitor.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 14),
            for (final device in devices)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: device.id == selectedDeviceId
                          ? const Color(0xFF187A3D)
                          : Colors.green.shade50,
                      width: device.id == selectedDeviceId ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE8F4EB),
                      child: const Icon(Icons.sensors_rounded, color: Color(0xFF187A3D)),
                    ),
                    title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        '${device.fieldName}\nDevice ID: ${device.id}  •  Created: ${formatDate(device.createdAt)}',
                      ),
                    ),
                    isThreeLine: true,
                    trailing: device.id == selectedDeviceId
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF187A3D))
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: () => onSelectDevice(device),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'This screen lists devices returned by GET /api/devices. '
              'Creating or deleting devices is not currently supported by your API.',
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
