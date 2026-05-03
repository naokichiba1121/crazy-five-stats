import 'package:hive/hive.dart';

part 'stats_entry.g.dart';

@HiveType(typeId: 0)
class StatsEntry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late String staffName;

  @HiveField(3)
  late int atBats; // 打席数

  @HiveField(4)
  late int hits; // 安打

  @HiveField(5)
  late int homeRuns; // 本塁打

  @HiveField(6)
  late int rbi; // 打点

  @HiveField(7)
  late int stolenBases; // 盗塁

  @HiveField(8)
  late int sacrifices; // 犠打

  @HiveField(9)
  late int errors; // 失策

  StatsEntry({
    required this.id,
    required this.date,
    required this.staffName,
    required this.atBats,
    required this.hits,
    required this.homeRuns,
    required this.rbi,
    required this.stolenBases,
    required this.sacrifices,
    required this.errors,
  });

  /// 打率 = 安打 ÷ 打席数
  double get battingAverage {
    if (atBats == 0) return 0.0;
    return hits / atBats;
  }

  String get battingAverageStr {
    if (atBats == 0) return '.000';
    final val = battingAverage;
    // 野球スタイル: .XXX
    return '.${(val * 1000).floor().toString().padLeft(3, '0')}';
  }
}
