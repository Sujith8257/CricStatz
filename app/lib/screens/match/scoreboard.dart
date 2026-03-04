import 'package:cricstatz/config/palette.dart';
import 'package:cricstatz/config/routes.dart';
import 'package:cricstatz/models/match.dart';
import 'package:cricstatz/models/match_stats.dart';
import 'package:cricstatz/services/match_service.dart';
import 'package:cricstatz/widgets/skeleton_loaders.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class MatchScoreboardScreen extends StatefulWidget {
  final String? matchId;
  const MatchScoreboardScreen({super.key, this.matchId});

  @override
  State<MatchScoreboardScreen> createState() => _MatchScoreboardScreenState();

  static const Color _card = Color(0xFF0F172A);
  static const Color _stroke = Color(0xFF1E293B);
  static const Color _headerOverlay = Color(0x660A1F43);
  static const Color _rowOverlay = Color(0x330D1729);
  static const Color _accentBlue = Color(0xFF60A5FA);
  static const Color _ausHeaderBg = Color(0x333E60AF);
}

class _MatchScoreboardScreenState extends State<MatchScoreboardScreen> {
  bool _isAustraliaExpanded = false;
  List<Map<String, dynamic>>? _scoreboardData;
  bool _isLoading = true;
  Match? _match;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (widget.matchId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final results = await Future.wait([
        MatchService.getMatchDetails(widget.matchId!),
        MatchService.getScoreboard(widget.matchId!),
      ]);
      if (!mounted) return;
      setState(() {
        _match = results[0] as Match;
        _scoreboardData = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppPalette.surfaceGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
                children: [
                 _TopBar(match: _match),
                 _Tabs(selectedIndex: 2, matchId: widget.matchId),
                 const SizedBox(height: 16),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   child: _isLoading 
                      ? const Column(
                          children: [
                            SkeletonLoader(width: double.infinity, height: 60),
                            SizedBox(height: 16),
                            SkeletonLoader(width: double.infinity, height: 300),
                          ],
                        )
                      : Column(
                          children: [
                            if (_scoreboardData != null && _scoreboardData!.isNotEmpty) ...[
                              _InningsSummaryBar(title: _scoreboardData![0]['innings'] as String, total: _scoreboardData![0]['total'] as String),
                              const SizedBox(height: 10),
                              _BattingTable(batsmen: _scoreboardData![0]['batting'] as List<BatsmanScore>),
                              const _ExtrasTotal(),
                              const SizedBox(height: 12),
                              // Fall of wickets could also be dynamic
                              const _FallOfWickets(),
                              const SizedBox(height: 12),
                              _BowlingTable(bowlers: _scoreboardData![0]['bowling'] as List<BowlerScore>),
                            ],
                            const SizedBox(height: 16),
                            const _KeyPartnerships(),
                      const SizedBox(height: 18),
                      _AustraliaInningsHeader(
                        expanded: _isAustraliaExpanded,
                        onTap: () => setState(
                          () => _isAustraliaExpanded = !_isAustraliaExpanded,
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: const _AustraliaFullScorecard(),
                        crossFadeState: _isAustraliaExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                        sizeCurve: Curves.easeOutCubic,
                      ),
                    ],
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

class _TopBar extends StatelessWidget {
  final Match? match;
  const _TopBar({this.match});
  
  @override
  Widget build(BuildContext context) {
    final teamA = match?.teamAId ?? 'Team A';
    final teamB = match?.teamBId ?? 'Team B';
    final subtitle = match?.matchFormat ?? 'Match Scorecard';
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 72,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: const BoxDecoration(
            color: Color(0xF20A1F43),
            border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                ),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppPalette.textPrimary,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$teamA vs $teamB',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppPalette.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFCBD5E1),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share_outlined,
                  color: AppPalette.textPrimary,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selectedIndex, this.matchId});

  final int selectedIndex;
  final String? matchId;

  @override
  Widget build(BuildContext context) {
    const tabs = ['INFO', 'LIVE', 'SCORECARD', 'PLAYERS'];
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 51,
          decoration: const BoxDecoration(
            color: Color(0xF20A1F43),
            border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
          ),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final isSelected = i == selectedIndex;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (i == selectedIndex) return;
                    if (i == 0) {
                      Navigator.pushNamed(context, AppRoutes.info, arguments: matchId);
                    } else if (i == 1) {
                      Navigator.pushNamed(context, AppRoutes.live, arguments: matchId);
                    } else if (i == 2) {
                      // Already on scorecard
                    } else if (i == 3) {
                      Navigator.pushNamed(context, AppRoutes.players, arguments: matchId);
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? AppPalette.accent
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      tabs[i],
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isSelected
                                ? AppPalette.accent
                                : AppPalette.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.6,
                          ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _InningsSummaryBar extends StatelessWidget {
  final String title;
  final String total;
  const _InningsSummaryBar({required this.title, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: MatchScoreboardScreen._card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MatchScoreboardScreen._stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppPalette.progress,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            alignment: Alignment.center,
            child: Text(
              title.substring(0, title.length > 3 ? 3 : title.length).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppPalette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Text(
            total,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppPalette.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _BattingTable extends StatelessWidget {
  final List<BatsmanScore> batsmen;
  const _BattingTable({required this.batsmen});

  @override
  Widget build(BuildContext context) {
    Widget headerCell(String label, {TextAlign align = TextAlign.center}) {
      return Text(
        label,
        textAlign: align,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppPalette.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              fontSize: 10,
            ),
      );
    }

    Widget row({
      required String name,
      required String dismissal,
      required String r,
      required String b,
      required String f4,
      required String f6,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0x801E293B))),
          color: MatchScoreboardScreen._rowOverlay,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF1E293B),
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppPalette.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dismissal,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppPalette.textMuted,
                                    fontSize: 10,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _num(context, r, bold: true)),
            Expanded(child: _num(context, b, muted: true)),
            Expanded(child: _num(context, f4, muted: true)),
            Expanded(child: _num(context, f6, muted: true)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: MatchScoreboardScreen._card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MatchScoreboardScreen._stroke),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 9),
            decoration: const BoxDecoration(
              color: MatchScoreboardScreen._headerOverlay,
              border: Border(
                  bottom: BorderSide(color: MatchScoreboardScreen._stroke)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 5,
                    child: headerCell('BATTER', align: TextAlign.left)),
                Expanded(child: headerCell('R')),
                Expanded(child: headerCell('B')),
                Expanded(child: headerCell('4S')),
                Expanded(child: headerCell('6S')),
              ],
            ),
          ),
          ...batsmen.map((b) => row(
            name: b.name,
            dismissal: 'dismissed', // Should be dynamic
            r: b.runs,
            b: b.balls,
            f4: b.fours.toString(),
            f6: b.sixes.toString(),
          )),
        ],
      ),
    );
  }

  Widget _num(BuildContext context, String v,
      {bool bold = false, bool muted = false}) {
    return Text(
      v,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: muted ? AppPalette.textMuted : AppPalette.textPrimary,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            fontSize: 14,
          ),
    );
  }
}

class _ExtrasTotal extends StatelessWidget {
  const _ExtrasTotal();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0x330A1F43),
        border: Border(
          left: BorderSide(color: MatchScoreboardScreen._stroke),
          right: BorderSide(color: MatchScoreboardScreen._stroke),
          bottom: BorderSide(color: MatchScoreboardScreen._stroke),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Extras',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                  children: const [
                    TextSpan(text: '12 '),
                    TextSpan(
                      text: '(b 1, lb 2, w 9, nb 0)',
                      style: TextStyle(
                        color: AppPalette.textSubtle,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0x0DFFFFFF)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Total Runs',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppPalette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MatchScoreboardScreen._accentBlue,
                        fontWeight: FontWeight.w800,
                      ),
                  children: const [
                    TextSpan(text: '240 '),
                    TextSpan(
                      text: '(10 wickets, 50.0 overs)',
                      style: TextStyle(
                        color: AppPalette.textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FallOfWickets extends StatelessWidget {
  const _FallOfWickets();

  @override
  Widget build(BuildContext context) {
    Widget chip(String top, String name, String over) {
      return Container(
        width: 78,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x801E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x331E293B)),
        ),
        child: Column(
          children: [
            Text(
              top,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppPalette.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppPalette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              over,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppPalette.textMuted,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FALL OF WICKETS',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppPalette.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              chip('1-30', 'Gill', '4.2 ov'),
              const SizedBox(width: 10),
              chip('2-76', 'Rohit', '9.4 ov'),
              const SizedBox(width: 10),
              chip('3-81', 'Iyer', '10.2 ov'),
              const SizedBox(width: 10),
              chip('4-148', 'Kohli', '23.0 ov'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BowlingTable extends StatelessWidget {
  final List<BowlerScore> bowlers;
  const _BowlingTable({required this.bowlers});

  @override
  Widget build(BuildContext context) {
    Widget headerCell(String t) => Text(
          t,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppPalette.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                fontSize: 10,
              ),
        );

    Widget row(
        String name, String o, String m, String r, String w, String eco) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x801E293B))),
          color: Color(0x330D1729),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppPalette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Expanded(child: _num(context, o)),
            Expanded(child: _num(context, m, muted: true)),
            Expanded(child: _num(context, r)),
            Expanded(child: _num(context, w, blue: true)),
            Expanded(child: _num(context, eco, muted: true)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: MatchScoreboardScreen._card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MatchScoreboardScreen._stroke),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
            decoration: const BoxDecoration(
              color: MatchScoreboardScreen._headerOverlay,
              border: Border(
                  bottom: BorderSide(color: MatchScoreboardScreen._stroke)),
            ),
            child: Row(
              children: [
                Expanded(flex: 5, child: headerCell('BOWLER')),
                Expanded(child: headerCell('O')),
                Expanded(child: headerCell('M')),
                Expanded(child: headerCell('R')),
                Expanded(child: headerCell('W')),
                Expanded(child: headerCell('ECO')),
              ],
            ),
          ),
          ...bowlers.map((b) => row(b.name, b.overs, b.maidens, b.runs, b.wickets, b.econ)),
        ],
      ),
    );
  }

  Widget _num(BuildContext context, String v,
      {bool muted = false, bool blue = false}) {
    return Text(
      v,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: blue
                ? MatchScoreboardScreen._accentBlue
                : (muted ? AppPalette.textMuted : AppPalette.textPrimary),
            fontWeight: blue ? FontWeight.w800 : FontWeight.w500,
            fontSize: 14,
          ),
    );
  }
}

class _KeyPartnerships extends StatelessWidget {
  const _KeyPartnerships();

  @override
  Widget build(BuildContext context) {
    Widget card({
      required String title,
      required String summary,
      required double value,
      required String left,
      required String right,
    }) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MatchScoreboardScreen._card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MatchScoreboardScreen._stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  summary,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MatchScoreboardScreen._accentBlue,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: const Color(0xFF0B1F3D),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppPalette.accent),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  left,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppPalette.textMuted,
                      ),
                ),
                Text(
                  right,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppPalette.textMuted,
                      ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY PARTNERSHIPS',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppPalette.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 12),
          card(
            title: 'Kohli & Rahul',
            summary: '67 (109)',
            value: 0.55,
            left: 'Kohli: 32(50)',
            right: 'Rahul: 31(59)',
          ),
          const SizedBox(height: 12),
          card(
            title: 'Rohit & Gill',
            summary: '30 (26)',
            value: 0.8,
            left: 'Rohit: 25(19)',
            right: 'Gill: 4(7)',
          ),
        ],
      ),
    );
  }
}

class _AustraliaInningsHeader extends StatelessWidget {
  const _AustraliaInningsHeader({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 17),
        decoration: BoxDecoration(
          color: MatchScoreboardScreen._ausHeaderBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MatchScoreboardScreen._stroke),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEAB308),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'AUS',
                style: TextStyle(
                  color: AppPalette.bgSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Australia Innings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppPalette.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
              ),
            ),
            Text(
              '241/4',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppPalette.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(width: 6),
            Text(
              '(43.0)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPalette.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 12),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppPalette.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _AustraliaFullScorecard extends StatelessWidget {
  const _AustraliaFullScorecard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _AustraliaBattingTable(),
        _AustraliaExtrasTotal(),
        SizedBox(height: 12),
        _AustraliaBowlingTable(),
      ],
    );
  }
}

class _AustraliaBattingTable extends StatelessWidget {
  const _AustraliaBattingTable();

  @override
  Widget build(BuildContext context) {
    Widget headerCell(String label, {TextAlign align = TextAlign.center}) {
      return Text(
        label,
        textAlign: align,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppPalette.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              fontSize: 10,
            ),
      );
    }

    Widget row({
      required String name,
      required String dismissal,
      required String r,
      required String b,
      required String f4,
      required String f6,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0x801E293B))),
          color: MatchScoreboardScreen._rowOverlay,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF1E293B),
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppPalette.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dismissal,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppPalette.textMuted,
                                    fontSize: 10,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _num(context, r, bold: true)),
            Expanded(child: _num(context, b, muted: true)),
            Expanded(child: _num(context, f4, muted: true)),
            Expanded(child: _num(context, f6, muted: true)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: MatchScoreboardScreen._card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MatchScoreboardScreen._stroke),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 9),
            decoration: const BoxDecoration(
              color: MatchScoreboardScreen._headerOverlay,
              border: Border(
                  bottom: BorderSide(color: MatchScoreboardScreen._stroke)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 5,
                    child: headerCell('BATTER', align: TextAlign.left)),
                Expanded(child: headerCell('R')),
                Expanded(child: headerCell('B')),
                Expanded(child: headerCell('4S')),
                Expanded(child: headerCell('6S')),
              ],
            ),
          ),
          row(
            name: 'Travis Head',
            dismissal: 'c Gill b Siraj',
            r: '137',
            b: '120',
            f4: '15',
            f6: '4',
          ),
          row(
            name: 'Marnus\nLabuschagne',
            dismissal: 'not out',
            r: '58',
            b: '110',
            f4: '4',
            f6: '0',
          ),
        ],
      ),
    );
  }

  Widget _num(BuildContext context, String v,
      {bool bold = false, bool muted = false}) {
    return Text(
      v,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: muted ? AppPalette.textMuted : AppPalette.textPrimary,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            fontSize: 14,
          ),
    );
  }
}

class _AustraliaExtrasTotal extends StatelessWidget {
  const _AustraliaExtrasTotal();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0x330A1F43),
        border: Border(
          left: BorderSide(color: MatchScoreboardScreen._stroke),
          right: BorderSide(color: MatchScoreboardScreen._stroke),
          bottom: BorderSide(color: MatchScoreboardScreen._stroke),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Extras',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                  children: const [
                    TextSpan(text: '18 '),
                    TextSpan(
                      text: '(b 5, lb 2, w 11, nb 0)',
                      style: TextStyle(
                        color: AppPalette.textSubtle,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0x0DFFFFFF)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Total Runs',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppPalette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MatchScoreboardScreen._accentBlue,
                        fontWeight: FontWeight.w800,
                      ),
                  children: const [
                    TextSpan(text: '241 '),
                    TextSpan(
                      text: '(4 wickets, 43.0 overs)',
                      style: TextStyle(
                        color: AppPalette.textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AustraliaBowlingTable extends StatelessWidget {
  const _AustraliaBowlingTable();

  @override
  Widget build(BuildContext context) {
    Widget headerCell(String t) => Text(
          t,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppPalette.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                fontSize: 10,
              ),
        );

    Widget row(
        String name, String o, String m, String r, String w, String eco) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x801E293B))),
          color: Color(0x330D1729),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppPalette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Expanded(child: _num(context, o)),
            Expanded(child: _num(context, m, muted: true)),
            Expanded(child: _num(context, r)),
            Expanded(child: _num(context, w, blue: true)),
            Expanded(child: _num(context, eco, muted: true)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: MatchScoreboardScreen._card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MatchScoreboardScreen._stroke),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
            decoration: const BoxDecoration(
              color: MatchScoreboardScreen._headerOverlay,
              border: Border(
                  bottom: BorderSide(color: MatchScoreboardScreen._stroke)),
            ),
            child: Row(
              children: [
                Expanded(flex: 5, child: headerCell('BOWLER')),
                Expanded(child: headerCell('O')),
                Expanded(child: headerCell('M')),
                Expanded(child: headerCell('R')),
                Expanded(child: headerCell('W')),
                Expanded(child: headerCell('ECO')),
              ],
            ),
          ),
          row('Jasprit Bumrah', '9', '2', '43', '2', '4.77'),
          row('Mohammed Shami', '7', '1', '47', '1', '6.71'),
        ],
      ),
    );
  }

  Widget _num(BuildContext context, String v,
      {bool muted = false, bool blue = false}) {
    return Text(
      v,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: blue
                ? MatchScoreboardScreen._accentBlue
                : (muted ? AppPalette.textMuted : AppPalette.textPrimary),
            fontWeight: blue ? FontWeight.w800 : FontWeight.w500,
            fontSize: 14,
          ),
    );
  }
}
