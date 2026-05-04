import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/stats_service.dart';
import '../theme/app_theme.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  String _selectedStaff = '千葉 尚暉';

  // ── 打撃部門
  int _atBats = 0;
  int _hits = 0;
  int _homeRuns = 0;
  int _rbi = 0;
  int _sacrifices = 0;

  // ── スカウト部門
  int _instagram = 0;
  int _threads = 0;
  int _stolenBases = 0;

  // ── ペナルティ
  int _errors = 0;

  bool _isSaving = false;

  static const List<String> _staffList = [
    '千葉 尚暉',
    '齋 遼弥',
    '髙橋 修平',
    '沼澤 空翔',
  ];

  // ── セクション定義 ────────────────────────────────
  static const _battingFields = [
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
      'color': Color(0xFFFF9500),
    },
    {
      'key': 'sacrifices',
      'label': '犠　打',
      'sublabel': '他スタッフへのアシスト・店舗オペ優先',
      'icon': '🛡️',
      'color': Color(0xFF06B6D4),
    },
  ];

  static const _scoutFields = [
    {
      'key': 'instagram',
      'label': 'Instagram',
      'sublabel': '投稿・ストーリーズ数',
      'icon': '📸',
      'color': Color(0xFFE1306C),
    },
    {
      'key': 'threads',
      'label': 'Threads',
      'sublabel': '投稿数',
      'icon': '🧵',
      'color': Color(0xFFAAAAAA),
    },
    {
      'key': 'stolenBases',
      'label': '盗　塁',
      'sublabel': 'SNS・MEO経由のDM/問い合わせ獲得数',
      'icon': '📱',
      'color': Color(0xFF7C3AED),
    },
  ];

  static const _penaltyFields = [
    {
      'key': 'errors',
      'label': '失　策',
      'sublabel': '当日キャンセル・報連相ミス',
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
      case 'sacrifices': return _sacrifices;
      case 'instagram': return _instagram;
      case 'threads': return _threads;
      case 'stolenBases': return _stolenBases;
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
        case 'sacrifices': _sacrifices++; break;
        case 'instagram': _instagram++; break;
        case 'threads': _threads++; break;
        case 'stolenBases': _stolenBases++; break;
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
        case 'sacrifices': if (_sacrifices > 0) _sacrifices--; break;
        case 'instagram': if (_instagram > 0) _instagram--; break;
        case 'threads': if (_threads > 0) _threads--; break;
        case 'stolenBases': if (_stolenBases > 0) _stolenBases--; break;
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
        _sacrifices = existing.sacrifices;
        _instagram = existing.instagram;
        _threads = existing.threads;
        _stolenBases = existing.stolenBases;
        _errors = existing.errors;
      });
    } else {
      _resetValues();
    }
  }

  void _resetValues() {
    setState(() {
      _atBats = 0; _hits = 0; _homeRuns = 0;
      _rbi = 0; _sacrifices = 0;
      _instagram = 0; _threads = 0; _stolenBases = 0;
      _errors = 0;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.neonGreen,
            surface: AppTheme.bgCard,
          ),
        ),
        child: child!,
      ),
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
      sacrifices: _sacrifices,
      instagram: _instagram,
      threads: _threads,
      stolenBases: _stolenBases,
      errors: _errors,
    );

    final success = await service.saveEntry(entry);
    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      HapticFeedback.heavyImpact();
      _showCelebration();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            service.lastError ?? '保存に失敗しました。通信状態を確認してください。',
          ),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showCelebration() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => _CelebrationDialog(staffName: _selectedStaff),
    );
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
            // ── 打撃部門
            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: '⚾',
                title: '打撃部門',
                subtitle: 'セッション中のスタッツ',
                color: AppTheme.neonGreen,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _StatInputCard(
                      label: _battingFields[i]['label'] as String,
                      sublabel: _battingFields[i]['sublabel'] as String,
                      icon: _battingFields[i]['icon'] as String,
                      accentColor: _battingFields[i]['color'] as Color,
                      value: _getValue(_battingFields[i]['key'] as String),
                      onIncrement: () => _increment(_battingFields[i]['key'] as String),
                      onDecrement: () => _decrement(_battingFields[i]['key'] as String),
                    ),
                  ),
                  childCount: _battingFields.length,
                ),
              ),
            ),
            // ── スカウト部門
            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: '📡',
                title: 'スカウト部門',
                subtitle: '空き時間の0円集客',
                color: const Color(0xFFE1306C),
                topMargin: 8,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _StatInputCard(
                      label: _scoutFields[i]['label'] as String,
                      sublabel: _scoutFields[i]['sublabel'] as String,
                      icon: _scoutFields[i]['icon'] as String,
                      accentColor: _scoutFields[i]['color'] as Color,
                      value: _getValue(_scoutFields[i]['key'] as String),
                      onIncrement: () => _increment(_scoutFields[i]['key'] as String),
                      onDecrement: () => _decrement(_scoutFields[i]['key'] as String),
                    ),
                  ),
                  childCount: _scoutFields.length,
                ),
              ),
            ),
            // ── ペナルティ
            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: '🚨',
                title: 'ペナルティ',
                subtitle: 'チームへのマイナス影響',
                color: AppTheme.redAlert,
                topMargin: 8,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _StatInputCard(
                      label: _penaltyFields[i]['label'] as String,
                      sublabel: _penaltyFields[i]['sublabel'] as String,
                      icon: _penaltyFields[i]['icon'] as String,
                      accentColor: _penaltyFields[i]['color'] as Color,
                      value: _getValue(_penaltyFields[i]['key'] as String),
                      onIncrement: () => _increment(_penaltyFields[i]['key'] as String),
                      onDecrement: () => _decrement(_penaltyFields[i]['key'] as String),
                      isError: true,
                    ),
                  ),
                  childCount: _penaltyFields.length,
                ),
              ),
            ),
            // ── 送信ボタン
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイトル行
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
                'プレイボール',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 日付
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
                  const Icon(Icons.calendar_today,
                      color: AppTheme.neonGreen, size: 16),
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
                  const Text('変更',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
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
                        const Icon(Icons.person,
                            color: AppTheme.neonGreen, size: 18),
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
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _save,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.neonGreen,
        minimumSize: const Size(double.infinity, 58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 6,
        shadowColor: AppTheme.neonGreen.withValues(alpha: 0.4),
      ),
      child: _isSaving
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppTheme.bgDark),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('⚾', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Text(
                  'プレイボール！',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: AppTheme.bgDark,
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── セクションヘッダー ───────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final double topMargin;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.topMargin = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topMargin, 16, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 個別スタッツ入力カード ──────────────────────────────────────────────
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value > 0
              ? accentColor.withValues(alpha: isError ? 0.7 : 0.45)
              : AppTheme.divider,
          width: value > 0 ? 1.5 : 1,
        ),
        boxShadow: value > 0
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                )
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
                            color: value > 0
                                ? accentColor
                                : AppTheme.textPrimary,
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
            // ─ / 数値 / ＋
            Row(
              children: [
                _CountButton(
                  label: '－',
                  onTap: onDecrement,
                  bgColor: AppTheme.bgCardLight,
                  fgColor: isError
                      ? AppTheme.redAlert
                      : AppTheme.textSecondary,
                  enabled: value > 0,
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    value.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: value > 0
                          ? accentColor
                          : AppTheme.textSecondary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _CountButton(
                  label: '＋',
                  onTap: onIncrement,
                  bgColor: accentColor,
                  fgColor: AppTheme.bgDark,
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
  final Color bgColor;
  final Color fgColor;
  final bool enabled;

  const _CountButton({
    required this.label,
    required this.onTap,
    required this.bgColor,
    required this.fgColor,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled
              ? bgColor
              : bgColor.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: enabled
                ? fgColor
                : fgColor.withValues(alpha: 0.35),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── 入力完了セレブレーションダイアログ ─────────────────────────────────
class _CelebrationDialog extends StatefulWidget {
  final String staffName;
  const _CelebrationDialog({required this.staffName});

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D2B0F), Color(0xFF0A1A2F)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.neonGreen,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonGreen.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚾', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 12),
                const Text(
                  'PLAY BALL!',
                  style: TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.staffName}',
                  style: const TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '今日のスタッツを記録した！',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.neonGreen.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    '「驚きと感動を、毎日積み上げろ。」',
                    style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
