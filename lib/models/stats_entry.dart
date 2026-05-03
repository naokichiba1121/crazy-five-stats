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

  // ── 打撃部門（セッション中）──────────────────────
  @HiveField(3)
  late int atBats; // 打席数（セッション・施術数）

  @HiveField(4)
  late int hits; // 安打（物販・オプション数）

  @HiveField(5)
  late int homeRuns; // 本塁打（高単価コース・複数成約数）

  @HiveField(6)
  late int rbi; // 打点（紹介発生・口コミ投稿数）

  @HiveField(8)
  late int sacrifices; // 犠打（他スタッフへのアシスト・店舗オペ優先）

  // ── スカウト部門（空き時間）──────────────────────
  @HiveField(10)
  late int instagram; // Instagram更新（投稿・ストーリーズ数）

  @HiveField(11)
  late int threads; // Threads更新（投稿数）

  @HiveField(7)
  late int stolenBases; // 盗塁（SNS・MEO経由のDM/問い合わせ獲得数）

  // ── ペナルティ ────────────────────────────────────
  @HiveField(9)
  late int errors; // 失策（当日キャンセル・報連相ミス）

  StatsEntry({
    required this.id,
    required this.date,
    required this.staffName,
    required this.atBats,
    required this.hits,
    required this.homeRuns,
    required this.rbi,
    required this.sacrifices,
    required this.instagram,
    required this.threads,
    required this.stolenBases,
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
    return '.${(val * 1000).floor().toString().padLeft(3, '0')}';
  }

  /// スカウト合計（Instagram + Threads）
  int get totalScout => instagram + threads;
}
