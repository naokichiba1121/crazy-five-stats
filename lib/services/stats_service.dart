import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// StatsEntry (シンプルなデータクラス、Hive不要)
// ─────────────────────────────────────────────
class StatsEntry {
  final String id;
  final DateTime date;
  final String staffName;
  final int atBats;
  final int hits;
  final int homeRuns;
  final int rbi;
  final int sacrifices;
  final int instagram;
  final int threads;
  final int stolenBases;
  final int errors;

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

  double get battingAverage => atBats == 0 ? 0.0 : hits / atBats;

  String get battingAverageStr {
    if (atBats == 0) return '.000';
    return '.${(battingAverage * 1000).floor().toString().padLeft(3, '0')}';
  }

  int get totalScout => instagram + threads;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'staffName': staffName,
        'atBats': atBats,
        'hits': hits,
        'homeRuns': homeRuns,
        'rbi': rbi,
        'sacrifices': sacrifices,
        'instagram': instagram,
        'threads': threads,
        'stolenBases': stolenBases,
        'errors': errors,
      };

  factory StatsEntry.fromJson(Map<String, dynamic> json) {
    // GASから返ってくる行データ（List or Map）に対応
    DateTime parseDate(dynamic d) {
      if (d == null || d.toString().isEmpty) return DateTime.now();
      try {
        return DateTime.parse(d.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return StatsEntry(
      id: json['id']?.toString() ?? '',
      date: parseDate(json['date']),
      staffName: json['staffName']?.toString() ?? '',
      atBats: parseInt(json['atBats']),
      hits: parseInt(json['hits']),
      homeRuns: parseInt(json['homeRuns']),
      rbi: parseInt(json['rbi']),
      sacrifices: parseInt(json['sacrifices']),
      instagram: parseInt(json['instagram']),
      threads: parseInt(json['threads']),
      stolenBases: parseInt(json['stolenBases']),
      errors: parseInt(json['errors']),
    );
  }

  /// GASが配列形式で返す場合の変換
  /// HEADERS = ['id','date','staffName','atBats','hits','homeRuns','rbi',
  ///            'sacrifices','instagram','threads','stolenBases','errors']
  factory StatsEntry.fromRow(List<dynamic> row) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    DateTime parseDate(dynamic d) {
      if (d == null || d.toString().isEmpty) return DateTime.now();
      try {
        return DateTime.parse(d.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return StatsEntry(
      id: row.length > 0 ? row[0].toString() : '',
      date: parseDate(row.length > 1 ? row[1] : null),
      staffName: row.length > 2 ? row[2].toString() : '',
      atBats: parseInt(row.length > 3 ? row[3] : 0),
      hits: parseInt(row.length > 4 ? row[4] : 0),
      homeRuns: parseInt(row.length > 5 ? row[5] : 0),
      rbi: parseInt(row.length > 6 ? row[6] : 0),
      sacrifices: parseInt(row.length > 7 ? row[7] : 0),
      instagram: parseInt(row.length > 8 ? row[8] : 0),
      threads: parseInt(row.length > 9 ? row[9] : 0),
      stolenBases: parseInt(row.length > 10 ? row[10] : 0),
      errors: parseInt(row.length > 11 ? row[11] : 0),
    );
  }
}

// ─────────────────────────────────────────────
// StaffStats（集計用）
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
// StatsService（GAS HTTP API版）
// ─────────────────────────────────────────────
class StatsService extends ChangeNotifier {
  static const String _gasUrlKey = 'gas_url';

  String _gasUrl = '';
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _lastError;

  List<StatsEntry> _entries = [];

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get hasGasUrl => _gasUrl.isNotEmpty;

  // ── 初期化 ──────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _gasUrl = prefs.getString(_gasUrlKey) ?? '';
    if (_gasUrl.isNotEmpty) {
      await loadEntries();
    }
    _isInitialized = true;
    notifyListeners();
  }

  // ── GAS URLの保存 ────────────────────────────
  Future<void> setGasUrl(String url) async {
    _gasUrl = url.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gasUrlKey, _gasUrl);
    notifyListeners();
    if (_gasUrl.isNotEmpty) {
      await loadEntries();
    }
  }

  String get gasUrl => _gasUrl;

  // ── 全データ読み込み ─────────────────────────
  Future<void> loadEntries() async {
    if (_gasUrl.isEmpty) return;
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$_gasUrl?action=getAll');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          _entries = [];
          for (final item in decoded) {
            try {
              if (item is List) {
                final e = StatsEntry.fromRow(item);
                if (e.id.isNotEmpty) _entries.add(e);
              } else if (item is Map<String, dynamic>) {
                final e = StatsEntry.fromJson(item);
                if (e.id.isNotEmpty) _entries.add(e);
              }
            } catch (_) {
              // 個別パース失敗はスキップ
            }
          }
          _entries.sort((a, b) => b.date.compareTo(a.date));
        }
      } else {
        _lastError = 'サーバーエラー: ${response.statusCode}';
      }
    } catch (e) {
      _lastError = '接続エラー: ${e.toString().split('\n').first}';
      if (kDebugMode) debugPrint('loadEntries error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── エントリ保存（GAS経由） ──────────────────
  Future<bool> saveEntry(StatsEntry entry) async {
    if (_gasUrl.isEmpty) return false;

    try {
      final data = entry.toJson();
      final encoded = Uri.encodeComponent(jsonEncode(data));
      final uri = Uri.parse('$_gasUrl?action=save&data=$encoded');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // ローカルキャッシュも更新
        final idx = _entries.indexWhere((e) => e.id == entry.id);
        if (idx >= 0) {
          _entries[idx] = entry;
        } else {
          _entries.insert(0, entry);
        }
        _entries.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('saveEntry error: $e');
      return false;
    }
  }

  // ── エントリ削除（ローカルのみ）── ─────────────
  void removeEntryLocally(String id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // ── 同日・同スタッフのエントリを検索 ─────────
  StatsEntry? findEntry(DateTime date, String staffName) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      return _entries.firstWhere((e) {
        final eKey =
            '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
        return eKey == dateKey && e.staffName == staffName;
      });
    } catch (_) {
      return null;
    }
  }

  // ── 期間別フィルタ ────────────────────────────
  List<StatsEntry> get allEntries => List.unmodifiable(_entries);

  List<StatsEntry> get thisWeekEntries {
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return _entries.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(startOfWeek) && d.isBefore(endOfWeek);
    }).toList();
  }

  List<StatsEntry> get thisMonthEntries {
    final now = DateTime.now();
    return _entries
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
  }

  List<StatsEntry> get thisSeasonEntries {
    final now = DateTime.now();
    final range = _seasonRange(now);
    return _entries.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(range[0]) && d.isBefore(range[1]);
    }).toList();
  }

  List<StatsEntry> get thisYearEntries {
    final now = DateTime.now();
    final range = _fiscalYearRange(now);
    return _entries.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(range[0]) && d.isBefore(range[1]);
    }).toList();
  }

  // ── 集計 ─────────────────────────────────────
  Map<String, StaffStats> aggregateByStaff(List<StatsEntry> entries) {
    final Map<String, StaffStats> result = {};
    for (final entry in entries) {
      result.putIfAbsent(entry.staffName, () => StaffStats(entry.staffName));
      result[entry.staffName]!.add(entry);
    }
    return result;
  }

  // ── シーズン計算 ──────────────────────────────
  static List<DateTime> _seasonRange(DateTime now) {
    final m = now.month;
    if (m >= 2 && m <= 4) {
      return [DateTime(now.year, 2, 1), DateTime(now.year, 5, 1)];
    } else if (m >= 5 && m <= 7) {
      return [DateTime(now.year, 5, 1), DateTime(now.year, 8, 1)];
    } else if (m >= 8 && m <= 10) {
      return [DateTime(now.year, 8, 1), DateTime(now.year, 11, 1)];
    } else {
      final startYear = m == 1 ? now.year - 1 : now.year;
      return [
        DateTime(startYear, 11, 1),
        DateTime(startYear + 1, 2, 1),
      ];
    }
  }

  static List<DateTime> _fiscalYearRange(DateTime now) {
    final startYear = now.month == 1 ? now.year - 1 : now.year;
    return [
      DateTime(startYear, 2, 1),
      DateTime(startYear + 1, 2, 1),
    ];
  }

  static String get currentSeasonLabel {
    final m = DateTime.now().month;
    if (m >= 2 && m <= 4) return '2〜4月';
    if (m >= 5 && m <= 7) return '5〜7月';
    if (m >= 8 && m <= 10) return '8〜10月';
    return '11〜1月';
  }

  static String get currentFiscalYearLabel {
    final now = DateTime.now();
    final startYear = now.month == 1 ? now.year - 1 : now.year;
    return '$startYear年度';
  }
}
