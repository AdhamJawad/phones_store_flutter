import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class PersistedAuthSession extends HiveObject {
  PersistedAuthSession({
    required this.token,
    required this.tokenType,
    required this.userJson,
  });

  @HiveField(0)
  final String token;

  @HiveField(1)
  final String tokenType;

  @HiveField(2)
  final Map<String, dynamic> userJson;
}

class PersistedAuthSessionAdapter extends TypeAdapter<PersistedAuthSession> {
  @override
  final int typeId = 1;

  @override
  PersistedAuthSession read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return PersistedAuthSession(
      token: fields[0] as String,
      tokenType: fields[1] as String,
      userJson: Map<String, dynamic>.from(fields[2] as Map),
    );
  }

  @override
  void write(BinaryWriter writer, PersistedAuthSession obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.token)
      ..writeByte(1)
      ..write(obj.tokenType)
      ..writeByte(2)
      ..write(obj.userJson);
  }
}
