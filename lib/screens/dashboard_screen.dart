import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/stats_service.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;

  static const List<String> _staffOrder = [
    '千葉 尚暉',
    '齋 遼弥',
    '髙橋 修平',
    '沼澤 空翔',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: Consumer<StatsService>(
                builder: (context, service, _) {
                  if (!service.isInitialized) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.neonGreen),
                    );
                  }
                  final entries = _tabIndex == 0
                      ? service.thisMonthEntries
                      : service.allEntries;

                  if (entries.isEmpty) {
                    return _buildEmptyState();
                  }

                  final statsMap = service.aggregateByStaff(entries);
                  final staffStatsList = _buildSortedStaffList(statsMap);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      _buildSummaryBanner(staffStatsList),
                      const SizedBox(height: 16),
                      _buildTopPerformers(staffStatsList),
                      const SizedBox(height: 16),
                      _buildStatsTable(staffStatsList),
                      const SizedBox(height: 16),
                      _buildDetailCards(staffStatsList),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1F0F), AppTheme.bgDark],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
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
            '累計ダッシュボード',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          const Text('📊', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.neonGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppTheme.bgDark,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '📅  今月'),
          Tab(text: '🏆  累計（全期間）'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚾', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'データがありません',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _tabIndex == 0 ? '今月の記録を入力しましょう！' : 'スコアボードで記録を入力しましょう！',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  List<StaffStats> _buildSortedStaffList(Map<String, dynamic> statsMap) {
    final result = <StaffStats>[];
    for (final name in _staffOrder) {
      if (statsMap.containsKey(name)) {
        result.add(statsMap[name] as StaffStats);
      }
    }
    // 未登録スタッフも追加
    for (final entry in statsMap.entries) {
      if (!_staffOrder.contains(entry.key)) {
        result.add(entry.value as StaffStats);
      }
    }
    return result;
  }

  Widget _buildSummaryBanner(List<StaffStats> list) {
    final totalAtBats = list.fold(0, (s, e) => s + e.atBats);
    final totalHits = list.fold(0, (s, e) => s + e.hits);
    final totalHR = list.fold(0, (s, e) => s + e.homeRuns);
    final totalRBI = list.fold(0, (s, e) => s + e.rbi);
    final totalGames = list.fold(0, (s, e) => s + e.games);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2B0F), Color(0xFF0A1A2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.neonGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'チーム合計スタッツ',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$totalGames 試合',
                  style: const TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryItem(label: '打席', value: totalAtBats.toString(), color: const Color(0xFF4FC3F7)),
              _SummaryItem(label: '安打', value: totalHits.toString(), color: AppTheme.neonGreen),
              _SummaryItem(label: '本塁打', value: totalHR.toString(), color: AppTheme.goldAccent),
              _SummaryItem(label: '打点', value: totalRBI.toString(), color: AppTheme.goldAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers(List<StaffStats> list) {
    if (list.isEmpty) return const SizedBox();

    // 各カテゴリのトップを特定
    final topHR = list.reduce((a, b) => a.homeRuns >= b.homeRuns ? a : b);
    final topBA = list.where((s) => s.atBats > 0).isEmpty
        ? null
        : list.where((s) => s.atBats > 0).reduce((a, b) => a.battingAverage >= b.battingAverage ? a : b);
    final topRBI = list.reduce((a, b) => a.rbi >= b.rbi ? a : b);
    final topSB = list.reduce((a, b) => a.stolenBases >= b.stolenBases ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏆  トップパフォーマー',
          style: TextStyle(
            color: AppTheme.goldAccent,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.4,
          children: [
            if (topHR.homeRuns > 0)
              _TopCard(
                crown: '👑',
                category: '本塁打王',
                name: topHR.staffName,
                value: '${topHR.homeRuns} HR',
                color: AppTheme.goldAccent,
              ),
            if (topBA != null && topBA.battingAverage > 0)
              _TopCard(
                crown: '🥇',
                category: '首位打者',
                name: topBA.staffName,
                value: topBA.battingAverageStr,
                color: AppTheme.neonGreen,
                highlight: topBA.battingAverage >= 0.3,
              ),
            if (topRBI.rbi > 0)
              _TopCard(
                crown: '🤝',
                category: '打点王',
                name: topRBI.staffName,
                value: '${topRBI.rbi} 打点',
                color: const Color(0xFFFF9500),
              ),
            if (topSB.stolenBases > 0)
              _TopCard(
                crown: '📱',
                category: '盗塁王',
                name: topSB.staffName,
                value: '${topSB.stolenBases} 盗塁',
                color: const Color(0xFF7C3AED),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsTable(List<StaffStats> list) {
    if (list.isEmpty) return const SizedBox();

    final topHR = list.map((e) => e.homeRuns).reduce((a, b) => a > b ? a : b);
    final topRBI = list.map((e) => e.rbi).reduce((a, b) => a > b ? a : b);
    final topBA = list.where((s) => s.atBats > 0).isEmpty
        ? 0.0
        : list.where((s) => s.atBats > 0).map((e) => e.battingAverage).reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          // テーブルヘッダー
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF0D1F2F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _TableHeader('選手', flex: 3),
                _TableHeader('打席'),
                _TableHeader('安打'),
                _TableHeader('本塁'),
                _TableHeader('打点'),
                _TableHeader('盗塁'),
                _TableHeader('打率', isHighlight: true),
              ],
            ),
          ),
          // テーブルボディ
          ...list.asMap().entries.map((entry) {
            final index = entry.key;
            final s = entry.value;
            final isLast = index == list.length - 1;
            final isTopHR = s.homeRuns == topHR && topHR > 0;
            final isTopRBI = s.rbi == topRBI && topRBI > 0;
            final isTopBA = s.atBats > 0 && s.battingAverage == topBA && topBA > 0;
            final isHighBA = s.atBats > 0 && s.battingAverage >= 0.3;

            return Container(
              decoration: BoxDecoration(
                color: index % 2 == 0
                    ? AppTheme.bgCard
                    : AppTheme.bgCardLight.withValues(alpha: 0.5),
                borderRadius: isLast
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      )
                    : null,
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(color: AppTheme.divider, width: 0.5),
                      ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    // 選手名
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          if (isTopBA)
                            const Text('👑', style: TextStyle(fontSize: 12))
                          else
                            Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              s.staffName,
                              style: TextStyle(
                                color: isTopBA ? AppTheme.goldAccent : AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: isTopBA ? FontWeight.w700 : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _TableCell(s.atBats.toString()),
                    _TableCell(s.hits.toString()),
                    _TableCellHighlight(
                      s.homeRuns.toString(),
                      highlight: isTopHR,
                      color: AppTheme.goldAccent,
                    ),
                    _TableCellHighlight(
                      s.rbi.toString(),
                      highlight: isTopRBI,
                      color: const Color(0xFFFF9500),
                    ),
                    _TableCell(s.stolenBases.toString()),
                    // 打率
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: isHighBA
                            ? BoxDecoration(
                                color: AppTheme.neonGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              )
                            : null,
                        child: Text(
                          s.battingAverageStr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isHighBA ? AppTheme.neonGreen : AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: isHighBA ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailCards(List<StaffStats> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋  個人成績詳細',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ...list.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DetailCard(stats: s),
            )),
      ],
    );
  }
}

// ─── ウィジェット部品 ─────────────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  final String crown;
  final String category;
  final String name;
  final String value;
  final Color color;
  final bool highlight;

  const _TopCard({
    required this.crown,
    required this.category,
    required this.name,
    required this.value,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: highlight ? 0.6 : 0.3),
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(crown, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  final int flex;
  final bool isHighlight;

  const _TableHeader(this.text, {this.flex = 1, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isHighlight ? AppTheme.neonGreen : AppTheme.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String value;
  const _TableCell(this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TableCellHighlight extends StatelessWidget {
  final String value;
  final bool highlight;
  final Color color;

  const _TableCellHighlight(this.value, {required this.highlight, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: highlight ? color : AppTheme.textPrimary,
          fontSize: 13,
          fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final StaffStats stats;

  const _DetailCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isHighBA = stats.atBats > 0 && stats.battingAverage >= 0.3;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighBA
              ? AppTheme.neonGreen.withValues(alpha: 0.4)
              : AppTheme.divider,
          width: isHighBA ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isHighBA) ...[
                const Text('👑', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
              ],
              Text(
                stats.staffName,
                style: TextStyle(
                  color: isHighBA ? AppTheme.goldAccent : AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              if (isHighBA)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '打率3割超え',
                    style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                '打率 ${stats.battingAverageStr}',
                style: TextStyle(
                  color: isHighBA ? AppTheme.neonGreen : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatGrid(),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    final items = [
      _StatItem('⚾', '打席', stats.atBats, const Color(0xFF4FC3F7)),
      _StatItem('🥊', '安打', stats.hits, AppTheme.neonGreen),
      _StatItem('💥', '本塁打', stats.homeRuns, AppTheme.goldAccent),
      _StatItem('🤝', '打点', stats.rbi, const Color(0xFFFF9500)),
      _StatItem('📱', '盗塁', stats.stolenBases, const Color(0xFF7C3AED)),
      _StatItem('✅', '犠打', stats.sacrifices, const Color(0xFF06B6D4)),
      _StatItem('⚠️', '失策', stats.errors, AppTheme.redAlert),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => _MiniStatBadge(item: item)).toList(),
    );
  }
}

class _StatItem {
  final String icon;
  final String label;
  final int value;
  final Color color;
  _StatItem(this.icon, this.label, this.value, this.color);
}

class _MiniStatBadge extends StatelessWidget {
  final _StatItem item;
  const _MiniStatBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: item.value > 0
            ? item.color.withValues(alpha: 0.1)
            : AppTheme.bgCardLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.value > 0
              ? item.color.withValues(alpha: 0.4)
              : AppTheme.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            item.label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            item.value.toString(),
            style: TextStyle(
              color: item.value > 0 ? item.color : AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
