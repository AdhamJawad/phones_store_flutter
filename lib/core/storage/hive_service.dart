import 'package:hive_flutter/hive_flutter.dart';

import '../config/hive_boxes.dart';
import 'models/persisted_auth_session.dart';

final class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PersistedAuthSessionAdapter());
    await Hive.openBox<PersistedAuthSession>(HiveBoxes.auth);
  }
}
