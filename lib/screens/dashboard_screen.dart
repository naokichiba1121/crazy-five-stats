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

                  if (entries.isEmpty) return _buildEmptyState();

                  final statsMap = service.aggregateByStaff(entries);
                  final list = _buildSortedList(statsMap);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                    children: [
                      _buildTeamBanner(list),
                      const SizedBox(height: 16),
                      _buildTopPerformers(list),
                      const SizedBox(height: 16),
                      // 打撃テーブル
                      _buildSectionLabel('⚾', '打撃部門', AppTheme.neonGreen),
                      const SizedBox(height: 8),
                      _buildBattingTable(list),
                      const SizedBox(height: 16),
                      // スカウトテーブル
                      _buildSectionLabel('📡', 'スカウト部門', const Color(0xFFE1306C)),
                      const SizedBox(height: 8),
                      _buildScoutTable(list),
                      const SizedBox(height: 16),
                      // ペナルティ
                      _buildSectionLabel('🚨', 'ペナルティ', AppTheme.redAlert),
                      const SizedBox(height: 8),
                      _buildPenaltyTable(list),
                      const SizedBox(height: 16),
                      // 個人カード
                      _buildSectionLabel('📋', '個人成績詳細', AppTheme.textSecondary),
                      const SizedBox(height: 8),
                      ...list.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _DetailCard(stats: s),
                          )),
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

  // ─── ヘッダー ──────────────────────────────────────────────────────────
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
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
          const Text('⚾', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          const Text('データがありません',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            _tabIndex == 0 ? '今月の記録を入力しましょう！' : 'スコアボードで記録を入力しましょう！',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  List<StaffStats> _buildSortedList(Map<String, StaffStats> map) {
    final result = <StaffStats>[];
    for (final name in _staffOrder) {
      if (map.containsKey(name)) result.add(map[name]!);
    }
    for (final entry in map.entries) {
      if (!_staffOrder.contains(entry.key)) result.add(entry.value);
    }
    return result;
  }

  // ─── チームバナー ──────────────────────────────────────────────────────
  Widget _buildTeamBanner(List<StaffStats> list) {
    final totalAtBats = list.fold(0, (s, e) => s + e.atBats);
    final totalHits = list.fold(0, (s, e) => s + e.hits);
    final totalHR = list.fold(0, (s, e) => s + e.homeRuns);
    final totalIG = list.fold(0, (s, e) => s + e.instagram);
    final totalTH = list.fold(0, (s, e) => s + e.threads);
    final totalSB = list.fold(0, (s, e) => s + e.stolenBases);
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
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('チーム合計スタッツ',
                  style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('$totalGames 試合',
                    style: const TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 打撃系
          Row(
            children: [
              _BannerStat('打席', totalAtBats, const Color(0xFF4FC3F7)),
              _BannerStat('安打', totalHits, AppTheme.neonGreen),
              _BannerStat('本塁打', totalHR, AppTheme.goldAccent),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: AppTheme.divider),
          const SizedBox(height: 10),
          // スカウト系
          Row(
            children: [
              _BannerStat('Instagram', totalIG, const Color(0xFFE1306C)),
              _BannerStat('Threads', totalTH, const Color(0xFFAAAAAA)),
              _BannerStat('問い合わせ', totalSB, const Color(0xFF7C3AED)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── トップパフォーマー ────────────────────────────────────────────────
  Widget _buildTopPerformers(List<StaffStats> list) {
    if (list.isEmpty) return const SizedBox();

    final topHR = list.reduce((a, b) => a.homeRuns >= b.homeRuns ? a : b);
    final topSB = list.reduce((a, b) => a.stolenBases >= b.stolenBases ? a : b);
    final topIG = list.reduce((a, b) => a.instagram >= b.instagram ? a : b);
    final topTH = list.reduce((a, b) => a.threads >= b.threads ? a : b);
    final topBA = list.where((s) => s.atBats > 0).isEmpty
        ? null
        : list
            .where((s) => s.atBats > 0)
            .reduce((a, b) => a.battingAverage >= b.battingAverage ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🏆  トップパフォーマー',
            style: TextStyle(
                color: AppTheme.goldAccent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
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
            if (topIG.instagram > 0)
              _TopCard(
                crown: '📸',
                category: 'Instagram王',
                name: topIG.staffName,
                value: '${topIG.instagram} 投稿',
                color: const Color(0xFFE1306C),
              ),
            if (topTH.threads > 0)
              _TopCard(
                crown: '🧵',
                category: 'Threads王',
                name: topTH.staffName,
                value: '${topTH.threads} 投稿',
                color: const Color(0xFFAAAAAA),
              ),
            if (topSB.stolenBases > 0)
              _TopCard(
                crown: '📱',
                category: '盗塁王',
                name: topSB.staffName,
                value: '${topSB.stolenBases} 獲得',
                color: const Color(0xFF7C3AED),
              ),
          ],
        ),
      ],
    );
  }

  // ─── テーブル系 ────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String icon, String title, Color color) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(title,
            style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildBattingTable(List<StaffStats> list) {
    final maxHR = list.map((e) => e.homeRuns).reduce((a, b) => a > b ? a : b);
    final maxRBI = list.map((e) => e.rbi).reduce((a, b) => a > b ? a : b);
    final maxBA = list.where((s) => s.atBats > 0).isEmpty
        ? 0.0
        : list
            .where((s) => s.atBats > 0)
            .map((e) => e.battingAverage)
            .reduce((a, b) => a > b ? a : b);

    return _StatsTable(
      headers: ['選手', '打席', '安打', '本塁', '打点', '犠打', '打率'],
      headerFlex: [3, 1, 1, 1, 1, 1, 2],
      rows: list.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        final isTopHR = s.homeRuns == maxHR && maxHR > 0;
        final isTopRBI = s.rbi == maxRBI && maxRBI > 0;
        final isTopBA = s.atBats > 0 && s.battingAverage == maxBA && maxBA > 0;
        final isHighBA = s.atBats > 0 && s.battingAverage >= 0.3;

        return _TableRowData(
          rank: i + 1,
          name: s.staffName,
          isCrown: isTopBA,
          cells: [
            _CellData(s.atBats.toString()),
            _CellData(s.hits.toString()),
            _CellData(s.homeRuns.toString(),
                highlight: isTopHR, color: AppTheme.goldAccent),
            _CellData(s.rbi.toString(),
                highlight: isTopRBI, color: const Color(0xFFFF9500)),
            _CellData(s.sacrifices.toString()),
            _CellData(
              s.battingAverageStr,
              highlight: isHighBA,
              color: AppTheme.neonGreen,
              badge: isHighBA,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildScoutTable(List<StaffStats> list) {
    final maxIG = list.map((e) => e.instagram).reduce((a, b) => a > b ? a : b);
    final maxTH = list.map((e) => e.threads).reduce((a, b) => a > b ? a : b);
    final maxSB =
        list.map((e) => e.stolenBases).reduce((a, b) => a > b ? a : b);

    return _StatsTable(
      headers: ['選手', 'Instagram', 'Threads', '盗塁(DM)'],
      headerFlex: [3, 2, 2, 2],
      rows: list.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        return _TableRowData(
          rank: i + 1,
          name: s.staffName,
          isCrown: false,
          cells: [
            _CellData(s.instagram.toString(),
                highlight: s.instagram == maxIG && maxIG > 0,
                color: const Color(0xFFE1306C)),
            _CellData(s.threads.toString(),
                highlight: s.threads == maxTH && maxTH > 0,
                color: const Color(0xFFAAAAAA)),
            _CellData(s.stolenBases.toString(),
                highlight: s.stolenBases == maxSB && maxSB > 0,
                color: const Color(0xFF7C3AED)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPenaltyTable(List<StaffStats> list) {
    // 失策は少ない方がベスト → 0が最優秀
    final minErrors = list.map((e) => e.errors).reduce((a, b) => a < b ? a : b);

    return _StatsTable(
      headers: ['選手', '失策数', '評価'],
      headerFlex: [3, 2, 3],
      rows: list.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        final isClean = s.errors == minErrors;
        final grade = s.errors == 0
            ? '⚡ パーフェクト'
            : s.errors <= 1
                ? '✅ 良好'
                : s.errors <= 3
                    ? '⚠️ 要改善'
                    : '🚨 要注意';
        final gradeColor = s.errors == 0
            ? AppTheme.neonGreen
            : s.errors <= 1
                ? const Color(0xFF4FC3F7)
                : s.errors <= 3
                    ? AppTheme.goldAccent
                    : AppTheme.redAlert;

        return _TableRowData(
          rank: i + 1,
          name: s.staffName,
          isCrown: isClean && s.errors == 0,
          cells: [
            _CellData(s.errors.toString(),
                highlight: s.errors > 0,
                color: AppTheme.redAlert),
            _CellData(grade, highlight: true, color: gradeColor),
          ],
        );
      }).toList(),
    );
  }
}

// ─── 汎用テーブルウィジェット ─────────────────────────────────────────────
class _CellData {
  final String value;
  final bool highlight;
  final Color color;
  final bool badge;

  const _CellData(
    this.value, {
    this.highlight = false,
    this.color = AppTheme.textPrimary,
    this.badge = false,
  });
}

class _TableRowData {
  final int rank;
  final String name;
  final bool isCrown;
  final List<_CellData> cells;

  const _TableRowData({
    required this.rank,
    required this.name,
    required this.isCrown,
    required this.cells,
  });
}

class _StatsTable extends StatelessWidget {
  final List<String> headers;
  final List<int> headerFlex;
  final List<_TableRowData> rows;

  const _StatsTable({
    required this.headers,
    required this.headerFlex,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          // ヘッダー行
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: const BoxDecoration(
              color: Color(0xFF0D1F2F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: headers.asMap().entries.map((e) {
                final isFirst = e.key == 0;
                return Expanded(
                  flex: headerFlex[e.key],
                  child: Text(
                    e.value,
                    textAlign: isFirst ? TextAlign.left : TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // データ行
          ...rows.asMap().entries.map((entry) {
            final idx = entry.key;
            final row = entry.value;
            final isLast = idx == rows.length - 1;

            return Container(
              decoration: BoxDecoration(
                color: idx % 2 == 0
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
                    // 選手名セル
                    Expanded(
                      flex: headerFlex[0],
                      child: Row(
                        children: [
                          if (row.isCrown)
                            const Text('👑',
                                style: TextStyle(fontSize: 11))
                          else
                            Text('${row.rank}',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              row.name,
                              style: TextStyle(
                                color: row.isCrown
                                    ? AppTheme.goldAccent
                                    : AppTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: row.isCrown
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // データセル
                    ...row.cells.asMap().entries.map((ce) {
                      final cell = ce.value;
                      final flex = headerFlex[ce.key + 1];
                      return Expanded(
                        flex: flex,
                        child: cell.badge
                            ? Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cell.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  cell.value,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: cell.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : Text(
                                cell.value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: cell.highlight
                                      ? cell.color
                                      : AppTheme.textPrimary,
                                  fontSize: 12,
                                  fontWeight: cell.highlight
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                ),
                              ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── トップカード ─────────────────────────────────────────────────────────
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
                Text(category,
                    style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
                Text(name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── バナースタット ───────────────────────────────────────────────────────
class _BannerStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _BannerStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value.toString(),
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── 個人成績詳細カード ───────────────────────────────────────────────────
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
          // ヘッダー
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
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              if (isHighBA)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('打率3割超え',
                      style: TextStyle(
                          color: AppTheme.neonGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              const Spacer(),
              Text('打率 ${stats.battingAverageStr}',
                  style: TextStyle(
                      color: isHighBA
                          ? AppTheme.neonGreen
                          : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          // 打撃バッジ
          const Text('⚾ 打撃',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Badge('⚾', '打席', stats.atBats, const Color(0xFF4FC3F7)),
              _Badge('🥊', '安打', stats.hits, AppTheme.neonGreen),
              _Badge('💥', '本塁打', stats.homeRuns, AppTheme.goldAccent),
              _Badge('🤝', '打点', stats.rbi, const Color(0xFFFF9500)),
              _Badge('🛡️', '犠打', stats.sacrifices, const Color(0xFF06B6D4)),
            ],
          ),
          const SizedBox(height: 10),
          // スカウトバッジ
          const Text('📡 スカウト',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Badge('📸', 'Instagram', stats.instagram, const Color(0xFFE1306C)),
              _Badge('🧵', 'Threads', stats.threads, const Color(0xFFAAAAAA)),
              _Badge('📱', '盗塁(DM)', stats.stolenBases, const Color(0xFF7C3AED)),
            ],
          ),
          const SizedBox(height: 10),
          // ペナルティバッジ
          Wrap(
            spacing: 6,
            children: [
              _Badge('⚠️', '失策', stats.errors, AppTheme.redAlert),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String icon;
  final String label;
  final int value;
  final Color color;

  const _Badge(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: value > 0 ? color.withValues(alpha: 0.1) : AppTheme.bgCardLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value > 0 ? color.withValues(alpha: 0.4) : AppTheme.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 10)),
          const SizedBox(width: 4),
          Text(value.toString(),
              style: TextStyle(
                  color: value > 0 ? color : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
