import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/stats_entry.dart';

class StatsService extends ChangeNotifier {
  static const String _boxName = 'stats_entries';
  late Box<StatsEntry> _box;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _box = await Hive.openBox<StatsEntry>(_boxName);
    _isInitialized = true;
    notifyListeners();
  }

  List<StatsEntry> get allEntries {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// 今月のエントリ
  List<StatsEntry> get thisMonthEntries {
    final now = DateTime.now();
    return allEntries
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
  }

  /// 今週のエントリ（月曜始まり）
  List<StatsEntry> get thisWeekEntries {
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return allEntries.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(startOfWeek) && d.isBefore(endOfWeek);
    }).toList();
  }

  /// 今シーズン（3ヶ月区切り）のエントリ
  /// 2〜4月 / 5〜7月 / 8〜10月 / 11〜1月
  List<StatsEntry> get thisSeasonEntries {
    final now = DateTime.now();
    final range = _seasonRange(now);
    return allEntries.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(range[0]) && d.isBefore(range[1]);
    }).toList();
  }

  /// 今年度（2月1日〜翌年1月末）のエントリ
  List<StatsEntry> get thisYearEntries {
    final now = DateTime.now();
    final range = _fiscalYearRange(now);
    return allEntries.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(range[0]) && d.isBefore(range[1]);
    }).toList();
  }

  /// シーズン開始・終了日を返す [start, exclusiveEnd]
  /// 11〜1月シーズンは年をまたぐため特別処理
  static List<DateTime> _seasonRange(DateTime now) {
    final m = now.month;
    if (m >= 2 && m <= 4) {
      return [DateTime(now.year, 2, 1), DateTime(now.year, 5, 1)];
    } else if (m >= 5 && m <= 7) {
      return [DateTime(now.year, 5, 1), DateTime(now.year, 8, 1)];
    } else if (m >= 8 && m <= 10) {
      return [DateTime(now.year, 8, 1), DateTime(now.year, 11, 1)];
    } else {
      // 11月〜1月（翌年）
      final startYear = m == 1 ? now.year - 1 : now.year;
      return [
        DateTime(startYear, 11, 1),
        DateTime(startYear + 1, 2, 1),
      ];
    }
  }

  /// 今年度の開始・終了日を返す [start, exclusiveEnd]
  /// 年度 = 2月1日〜翌年1月31日
  static List<DateTime> _fiscalYearRange(DateTime now) {
    final startYear = now.month == 1 ? now.year - 1 : now.year;
    return [
      DateTime(startYear, 2, 1),
      DateTime(startYear + 1, 2, 1), // 翌年2月1日（exclusive）→ 翌年1月末まで
    ];
  }

  /// 現在のシーズン表示ラベル（例: "2〜4月"）
  static String get currentSeasonLabel {
    final now = DateTime.now();
    final m = now.month;
    if (m >= 2 && m <= 4) return '2〜4月';
    if (m >= 5 && m <= 7) return '5〜7月';
    if (m >= 8 && m <= 10) return '8〜10月';
    return '11〜1月';
  }

  /// 現在の年度表示ラベル（例: "2025年度"）
  static String get currentFiscalYearLabel {
    final now = DateTime.now();
    final startYear = now.month == 1 ? now.year - 1 : now.year;
    return '$startYear年度';
  }

  /// スタッフ別集計
  Map<String, StaffStats> aggregateByStaff(List<StatsEntry> entries) {
    final Map<String, StaffStats> result = {};
    for (final entry in entries) {
      if (!result.containsKey(entry.staffName)) {
        result[entry.staffName] = StaffStats(entry.staffName);
      }
      result[entry.staffName]!.add(entry);
    }
    return result;
  }

  Future<void> saveEntry(StatsEntry entry) async {
    await _box.put(entry.id, entry);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// 同じ日・同じスタッフのエントリがあればnullでなく返す
  StatsEntry? findEntry(DateTime date, String staffName) {
    final dateKey = '${date.year}-${date.month}-${date.day}';
    try {
      return allEntries.firstWhere((e) {
        final eKey = '${e.date.year}-${e.date.month}-${e.date.day}';
        return eKey == dateKey && e.staffName == staffName;
      });
    } catch (_) {
      return null;
    }
  }
}

class StaffStats {
  final String staffName;
  int atBats = 0;
  int hits = 0;
  int homeRuns = 0;
  int rbi = 0;
  int sacrifices = 0;
  int instagram = 0;
  int threads = 0;
  int stolenBases = 0;
  int errors = 0;
  int games = 0;

  StaffStats(this.staffName);

  void add(StatsEntry e) {
    atBats += e.atBats;
    hits += e.hits;
    homeRuns += e.homeRuns;
    rbi += e.rbi;
    sacrifices += e.sacrifices;
    instagram += e.instagram;
    threads += e.threads;
    stolenBases += e.stolenBases;
    errors += e.errors;
    games++;
  }

  int get totalScout => instagram + threads;

  double get battingAverage => atBats == 0 ? 0.0 : hits / atBats;

  String get battingAverageStr {
    if (atBats == 0) return '.000';
    return '.${(battingAverage * 1000).floor().toString().padLeft(3, '0')}';
  }
}
