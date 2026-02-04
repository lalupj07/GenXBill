import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:genx_bill/features/clients/data/models/client_model.dart';

final clientBoxProvider = Provider<Box<Client>>((ref) {
  return Hive.box<Client>('clients');
});

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final box = ref.watch(clientBoxProvider);
  return ClientRepository(box);
});

class ClientRepository {
  final Box<Client> _box;

  ClientRepository(this._box);

  Future<void> addClient(Client client) async {
    await _box.put(client.id, client);
  }

  Future<void> updateClient(Client client) async {
    await _box.put(client.id, client);
  }

  Future<void> deleteClient(String id) async {
    await _box.delete(id);
  }

  Client? getClient(String id) {
    return _box.get(id);
  }

  List<Client> getAllClients() {
    return _box.values.toList();
  }

  List<Client> searchClients(String query) {
    if (query.isEmpty) return getAllClients();

    return _box.values.where((client) {
      return client.name.toLowerCase().contains(query.toLowerCase()) ||
          client.email.toLowerCase().contains(query.toLowerCase()) ||
          client.phone.contains(query);
    }).toList();
  }
}
