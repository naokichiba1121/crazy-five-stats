// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatsEntryAdapter extends TypeAdapter<StatsEntry> {
  @override
  final int typeId = 0;

  @override
  StatsEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatsEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      staffName: fields[2] as String,
      atBats: fields[3] as int,
      hits: fields[4] as int,
      homeRuns: fields[5] as int,
      rbi: fields[6] as int,
      sacrifices: (fields[8] as int?) ?? 0,
      instagram: (fields[10] as int?) ?? 0,
      threads: (fields[11] as int?) ?? 0,
      stolenBases: fields[7] as int,
      errors: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StatsEntry obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.staffName)
      ..writeByte(3)
      ..write(obj.atBats)
      ..writeByte(4)
      ..write(obj.hits)
      ..writeByte(5)
      ..write(obj.homeRuns)
      ..writeByte(6)
      ..write(obj.rbi)
      ..writeByte(7)
      ..write(obj.stolenBases)
      ..writeByte(8)
      ..write(obj.sacrifices)
      ..writeByte(9)
      ..write(obj.errors)
      ..writeByte(10)
      ..write(obj.instagram)
      ..writeByte(11)
      ..write(obj.threads);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatsEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
