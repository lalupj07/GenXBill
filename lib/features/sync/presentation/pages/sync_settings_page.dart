import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/sync/domain/services/sync_server_service.dart';
import 'package:genx_bill/features/sync/domain/services/sync_client_service.dart';

class SyncSettingsPage extends StatelessWidget {
  const SyncSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Sync'),
      ),
      body: const SyncSettingsView(),
    );
  }
}

class SyncSettingsView extends ConsumerStatefulWidget {
  const SyncSettingsView({super.key});

  @override
  ConsumerState<SyncSettingsView> createState() => _SyncSettingsViewState();
}

class _SyncSettingsViewState extends ConsumerState<SyncSettingsView> {
  final TextEditingController _ipController = TextEditingController();
  bool _isSynching = false;

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverRunning = ref.watch(serverStatusProvider);
    final serverIp = ref.watch(serverIpProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildServerSection(serverRunning, serverIp),
          const Divider(height: 32),
          _buildClientSection(),
        ],
      ),
    );
  }

  Widget _buildServerSection(bool isRunning, String? ip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Server Mode (Host)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
                'Enable this device to host data for other devices (e.g., Desktop).'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRunning ? 'Server is Running' : 'Server is Stopped',
                        style: TextStyle(
                          color: isRunning ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isRunning && ip != null)
                        SelectableText('IP Address: $ip',
                            style: const TextStyle(
                                fontFamily: 'Courier', fontSize: 16)),
                    ],
                  ),
                ),
                Switch(
                  value: isRunning,
                  onChanged: (value) async {
                    try {
                      if (value) {
                        await ref.read(syncServerServiceProvider).startServer();
                      } else {
                        await ref.read(syncServerServiceProvider).stopServer();
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client Mode (Connect)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
                'Connect to a host device to sync data (e.g., Android).'),
            const SizedBox(height: 16),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Host IP Address',
                border: OutlineInputBorder(),
                hintText: 'e.g. 192.168.1.5',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSynching ? null : _handleSync,
              icon: _isSynching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: const Text('Sync Data from Host'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSync() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Host IP')),
      );
      return;
    }

    setState(() {
      _isSynching = true;
    });

    try {
      final clientService = ref.read(syncClientServiceProvider);
      // Check connection
      final canConnect = await clientService.checkConnection(ip);
      if (!canConnect) {
        throw Exception('Cannot connect to host at $ip');
      }

      await clientService.syncFromHost(ip);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Sync Successful! Products, Clients, Expenses, Inventory & Employees Updated.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSynching = false;
        });
      }
    }
  }
}
