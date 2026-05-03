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
