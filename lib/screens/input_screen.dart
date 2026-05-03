import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/stats_service.dart';
import '../models/stats_entry.dart';
import '../theme/app_theme.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedStaff = '千葉 尚暉';

  int _atBats = 0;
  int _hits = 0;
  int _homeRuns = 0;
  int _rbi = 0;
  int _stolenBases = 0;
  int _sacrifices = 0;
  int _errors = 0;

  bool _isSaving = false;
  bool _savedSuccess = false;

  static const List<String> _staffList = [
    '千葉 尚暉',
    '齋 遼弥',
    '髙橋 修平',
    '沼澤 空翔',
  ];

  final List<Map<String, dynamic>> _statFields = const [
    {
      'key': 'atBats',
      'label': '打席数',
      'sublabel': 'セッション・施術数',
      'icon': '⚾',
      'color': Color(0xFF4FC3F7),
    },
    {
      'key': 'hits',
      'label': '安　打',
      'sublabel': '物販販売・オプション数',
      'icon': '🥊',
      'color': Color(0xFF00FF7F),
    },
    {
      'key': 'homeRuns',
      'label': '本塁打',
      'sublabel': '高単価コース・複数成約数',
      'icon': '💥',
      'color': Color(0xFFFFD700),
    },
    {
      'key': 'rbi',
      'label': '打　点',
      'sublabel': '紹介発生・口コミ投稿数',
      'icon': '🤝',
      'color': Color(0xFFFFD700),
    },
    {
      'key': 'stolenBases',
      'label': '盗　塁',
      'sublabel': 'SNS・MEO経由のDM/問い合わせ獲得数',
      'icon': '📱',
      'color': Color(0xFF7C3AED),
    },
    {
      'key': 'sacrifices',
      'label': '犠　打',
      'sublabel': '清掃・SNS更新・タスク完了数',
      'icon': '✅',
      'color': Color(0xFF06B6D4),
    },
    {
      'key': 'errors',
      'label': '失　策',
      'sublabel': 'キャンセル・報連相ミス',
      'icon': '⚠️',
      'color': Color(0xFFFF3B30),
    },
  ];

  int _getValue(String key) {
    switch (key) {
      case 'atBats': return _atBats;
      case 'hits': return _hits;
      case 'homeRuns': return _homeRuns;
      case 'rbi': return _rbi;
      case 'stolenBases': return _stolenBases;
      case 'sacrifices': return _sacrifices;
      case 'errors': return _errors;
      default: return 0;
    }
  }

  void _increment(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      switch (key) {
        case 'atBats': _atBats++; break;
        case 'hits': _hits++; break;
        case 'homeRuns': _homeRuns++; break;
        case 'rbi': _rbi++; break;
        case 'stolenBases': _stolenBases++; break;
        case 'sacrifices': _sacrifices++; break;
        case 'errors': _errors++; break;
      }
    });
  }

  void _decrement(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      switch (key) {
        case 'atBats': if (_atBats > 0) _atBats--; break;
        case 'hits': if (_hits > 0) _hits--; break;
        case 'homeRuns': if (_homeRuns > 0) _homeRuns--; break;
        case 'rbi': if (_rbi > 0) _rbi--; break;
        case 'stolenBases': if (_stolenBases > 0) _stolenBases--; break;
        case 'sacrifices': if (_sacrifices > 0) _sacrifices--; break;
        case 'errors': if (_errors > 0) _errors--; break;
      }
    });
  }

  void _loadExistingEntry() {
    final service = context.read<StatsService>();
    if (!service.isInitialized) return;
    final existing = service.findEntry(_selectedDate, _selectedStaff);
    if (existing != null && existing.id.isNotEmpty) {
      setState(() {
        _atBats = existing.atBats;
        _hits = existing.hits;
        _homeRuns = existing.homeRuns;
        _rbi = existing.rbi;
        _stolenBases = existing.stolenBases;
        _sacrifices = existing.sacrifices;
        _errors = existing.errors;
      });
    } else {
      _resetValues();
    }
  }

  void _resetValues() {
    setState(() {
      _atBats = 0;
      _hits = 0;
      _homeRuns = 0;
      _rbi = 0;
      _stolenBases = 0;
      _sacrifices = 0;
      _errors = 0;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonGreen,
              surface: AppTheme.bgCard,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadExistingEntry();
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final service = context.read<StatsService>();
    final dateKey = DateFormat('yyyyMMdd').format(_selectedDate);
    final id = '${_selectedStaff}_$dateKey';

    final entry = StatsEntry(
      id: id,
      date: _selectedDate,
      staffName: _selectedStaff,
      atBats: _atBats,
      hits: _hits,
      homeRuns: _homeRuns,
      rbi: _rbi,
      stolenBases: _stolenBases,
      sacrifices: _sacrifices,
      errors: _errors,
    );

    await service.saveEntry(entry);

    setState(() {
      _isSaving = false;
      _savedSuccess = true;
    });

    HapticFeedback.heavyImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('⚾', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(
                '$_selectedStaff のスコアを記録しました！',
                style: const TextStyle(
                  color: AppTheme.bgDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.neonGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _savedSuccess = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadExistingEntry();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy年M月d日 (E)', 'ja_JP').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(dateStr)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final field = _statFields[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _StatInputCard(
                        label: field['label'] as String,
                        sublabel: field['sublabel'] as String,
                        icon: field['icon'] as String,
                        accentColor: field['color'] as Color,
                        value: _getValue(field['key'] as String),
                        onIncrement: () => _increment(field['key'] as String),
                        onDecrement: () => _decrement(field['key'] as String),
                        isError: field['key'] == 'errors',
                      ),
                    );
                  },
                  childCount: _statFields.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverToBoxAdapter(child: _buildSubmitButton()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String dateStr) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1F0F), AppTheme.bgDark],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.neonGreen, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'CRAZY FIVE',
                    style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'スコアボード',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // 日付選択
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.bgCardLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.neonGreen, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '変更',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // スタッフ選択
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.bgCardLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.divider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStaff,
                  isExpanded: true,
                  dropdownColor: AppTheme.bgCard,
                  icon: const Icon(Icons.expand_more, color: AppTheme.neonGreen),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _staffList.map((name) {
                    return DropdownMenuItem(
                      value: name,
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: AppTheme.neonGreen, size: 18),
                          const SizedBox(width: 10),
                          Text(name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedStaff = val);
                      _loadExistingEntry();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            // 入力説明
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.fieldGreen.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.neonGreenDim.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Text('⚾', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '今日のスタッツを入力してください。同じ日付・スタッフの記録は上書き保存されます。',
                      style: TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: _savedSuccess ? AppTheme.neonGreenDim : AppTheme.neonGreen,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: _savedSuccess ? 0 : 4,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.bgDark,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _savedSuccess ? '✓ 記録完了！' : '⚾  プレイボール！',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppTheme.bgDark,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── 個別スタッツ入力カード ────────────────────────────────────────────────
class _StatInputCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String icon;
  final Color accentColor;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isError;

  const _StatInputCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.accentColor,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value > 0
              ? accentColor.withValues(alpha: isError ? 0.6 : 0.4)
              : AppTheme.divider,
          width: value > 0 ? 1.5 : 1,
        ),
        boxShadow: value > 0
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // アイコン＋ラベル
            Expanded(
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: value > 0 ? accentColor : AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sublabel,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ─ / 数値 / ＋ ボタン
            Row(
              children: [
                _CountButton(
                  label: '－',
                  onTap: onDecrement,
                  color: isError ? AppTheme.redAlert : AppTheme.textSecondary,
                  bgColor: AppTheme.bgCardLight,
                  enabled: value > 0,
                ),
                Container(
                  width: 52,
                  alignment: Alignment.center,
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      color: value > 0 ? accentColor : AppTheme.textSecondary,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _CountButton(
                  label: '＋',
                  onTap: onIncrement,
                  color: AppTheme.bgDark,
                  bgColor: accentColor,
                  enabled: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color bgColor;
  final bool enabled;

  const _CountButton({
    required this.label,
    required this.onTap,
    required this.color,
    required this.bgColor,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? bgColor : bgColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? color : color.withValues(alpha: 0.4),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
