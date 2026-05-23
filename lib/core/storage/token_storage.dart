import 'package:hive/hive.dart';

import '../config/hive_boxes.dart';
import '../config/storage_keys.dart';
import 'models/persisted_auth_session.dart';

class TokenStorage {
  Box<PersistedAuthSession> get _box =>
      Hive.box<PersistedAuthSession>(HiveBoxes.auth);

  Future<void> save(PersistedAuthSession session) async {
    await _box.put(StorageKeys.persistedSession, session);
  }

  Future<PersistedAuthSession?> readSession() async {
    return _box.get(StorageKeys.persistedSession);
  }

  Future<String?> readToken() async {
    return _box.get(StorageKeys.persistedSession)?.token;
  }

  Future<void> clear() async {
    await _box.delete(StorageKeys.persistedSession);
  }
}
