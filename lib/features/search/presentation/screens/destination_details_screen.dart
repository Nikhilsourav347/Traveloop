import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../../core/services/ai_travel_service.dart';

// ─── Providers ───────────────────────────────────────────
final _daysProvider = StateProvider<int>((ref) => 3);
final _travelersProvider = StateProvider<int>((ref) => 2);
final _budgetTierProvider = StateProvider<int>((ref) => 0); // 0=Budget,1=Medium,2=Luxury
final _travelDateProvider = StateProvider<DateTime>((ref) => DateTime.now().add(const Duration(days: 7)));

// ─── Screen ──────────────────────────────────────────────
class DestinationDetailsScreen extends ConsumerStatefulWidget {
  final String destination;
  const DestinationDetailsScreen({super.key, required this.destination});

  @override
  ConsumerState<DestinationDetailsScreen> createState() => _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends ConsumerState<DestinationDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TripPlan _plan;
  late TabController _tabController;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.delayed(const Duration(milliseconds: 300), () {
      final svc = ref.read(aiTravelServiceProvider);
      final days = ref.read(_daysProvider);
      setState(() {
        _plan = svc.generateTripPlan(widget.destination, days);
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _regenerate() {
    final svc = ref.read(aiTravelServiceProvider);
    final days = ref.read(_daysProvider);
    setState(() {
      _loaded = false;
      _plan = svc.generateTripPlan(widget.destination, days);
      _loaded = true;
    });
  }

  void _sharePlan() {
    if (!_loaded) return;
    final days = ref.read(_daysProvider);
    final travelers = ref.read(_travelersProvider);
    final tiers = ref.read(aiTravelServiceProvider).calculateBudgetTiers(
      days: days,
      travelers: travelers,
      baseDailyCost: _plan.baseDailyCost,
      distanceKm: _plan.distanceKm,
    );
    final tier = tiers[ref.read(_budgetTierProvider)];
    final fmt = NumberFormat('#,##0', 'en_IN');
    final text = '''
🌍 Traveloop Trip Plan: ${_plan.destination}
📅 $days Days | 👥 $travelers Travelers
💰 ${tier.tier} Budget: ₹${fmt.format(tier.total)}

🏆 Top Attractions:
${_plan.topAttractions.take(5).map((a) => '• $a').join('\n')}

🗓️ Day 1: ${_plan.itinerary.isNotEmpty ? _plan.itinerary[0].title : ''}

📦 Pack: ${_plan.packingTips.take(3).join(', ')}
🌤️ Best Season: ${_plan.bestSeason}

Planned with Traveloop App! ✈️
''';
    Share.share(text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ref.watch(_daysProvider);
    final travelers = ref.watch(_travelersProvider);
    final tierIdx = ref.watch(_budgetTierProvider);
    final travelDate = ref.watch(_travelDateProvider);

    if (!_loaded) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('AI is planning your trip to ${widget.destination}…',
                  style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    final svc = ref.read(aiTravelServiceProvider);
    final tiers = svc.calculateBudgetTiers(
      days: days,
      travelers: travelers,
      baseDailyCost: _plan.baseDailyCost,
      distanceKm: _plan.distanceKm,
    );
    final selectedTier = tiers[tierIdx];
    final seasonTip = svc.getSeasonTip(widget.destination, travelDate);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero Banner ──────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _sharePlan,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _plan.destination,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 8, color: Colors.black54)]),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: _plan.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (c, u, e) => Container(color: theme.colorScheme.primaryContainer,
                        child: const Icon(Icons.landscape, size: 80)),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Famous For chips ─────────────────
                  Wrap(
                    spacing: 8,
                    children: _plan.famousFor.split(',').map((f) => Chip(
                      label: Text(f.trim(), style: const TextStyle(fontSize: 12)),
                      backgroundColor: theme.colorScheme.primaryContainer,
                    )).toList(),
                  ),
                  const SizedBox(height: 12),

                  // ── Description ──────────────────────
                  Text(_plan.description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
                  const SizedBox(height: 20),

                  // ── Trip Settings Card ───────────────
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trip Settings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _SettingRow(
                          icon: Icons.calendar_today,
                          label: 'Days',
                          value: '$days',
                          onMinus: days > 1 ? () { ref.read(_daysProvider.notifier).state--; _regenerate(); } : null,
                          onPlus: days < 14 ? () { ref.read(_daysProvider.notifier).state++; _regenerate(); } : null,
                        ),
                        const SizedBox(height: 8),
                        _SettingRow(
                          icon: Icons.people,
                          label: 'Travelers',
                          value: '$travelers',
                          onMinus: travelers > 1 ? () => ref.read(_travelersProvider.notifier).state-- : null,
                          onPlus: travelers < 20 ? () => ref.read(_travelersProvider.notifier).state++ : null,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: travelDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) ref.read(_travelDateProvider.notifier).state = picked;
                          },
                          icon: const Icon(Icons.date_range),
                          label: Text('Travel Date: ${DateFormat.yMMMd().format(travelDate)}'),
                          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Season Tip ───────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('🌤️', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Best Season: ${_plan.bestSeason}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(seasonTip, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Budget Section ───────────────────
                  Text('Budget Estimate', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(tiers.length, (i) {
                      final selected = i == tierIdx;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => ref.read(_budgetTierProvider.notifier).state = i,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: selected ? theme.colorScheme.primary : Colors.grey.shade300),
                              boxShadow: selected ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8)] : [],
                            ),
                            child: Text(
                              tiers[i].tier,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: selected ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  _BudgetBreakdownCard(estimate: selectedTier, days: days, travelers: travelers),
                  const SizedBox(height: 20),

                  // ── Tabs: Attractions | Itinerary | Packing ──
                  TabBar(
                    controller: _tabController,
                    tabs: const [Tab(text: '🏆 Attractions'), Tab(text: '🗓️ Itinerary'), Tab(text: '🎒 Packing')],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 320,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _AttractionsTab(plan: _plan),
                        _ItineraryTab(plan: _plan),
                        _PackingTab(plan: _plan),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Nearby Places ────────────────────
                  Text('Nearby Places', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _plan.nearbyPlaces.map((p) => ActionChip(
                      label: Text(p),
                      avatar: const Icon(Icons.location_on, size: 16),
                      onPressed: () {},
                    )).toList(),
                  ),
                  const SizedBox(height: 32),

                  // ── Share Button ─────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _sharePlan,
                      icon: const Icon(Icons.share),
                      label: const Text('Share This Trip Plan'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub Widgets ─────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const _SettingRow({required this.icon, required this.label, required this.value, this.onMinus, this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        IconButton(onPressed: onPlus, icon: const Icon(Icons.add_circle_outline)),
      ],
    );
  }
}

class _BudgetBreakdownCard extends StatelessWidget {
  final BudgetEstimate estimate;
  final int days;
  final int travelers;

  const _BudgetBreakdownCard({required this.estimate, required this.days, required this.travelers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat('#,##0', 'en_IN');
    final rows = [
      ('🏨 Hotel', estimate.hotel),
      ('🍽️ Food', estimate.food),
      ('🚗 Transport', estimate.transport),
      ('🎯 Activities', estimate.activities),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary.withValues(alpha: 0.9), theme.colorScheme.secondary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('Total Estimated Cost', style: TextStyle(color: Colors.white70)),
          Text('₹${fmt.format(estimate.total)}',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          Text('$days days • $travelers travelers', style: const TextStyle(color: Colors.white70)),
          const Divider(color: Colors.white30, height: 24),
          ...rows.map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(r.$1, style: const TextStyle(color: Colors.white)),
                Text('₹${fmt.format(r.$2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _AttractionsTab extends StatelessWidget {
  final TripPlan plan;
  const _AttractionsTab({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: plan.topAttractions.length,
      itemBuilder: (context, i) => ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text('${i + 1}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(plan.topAttractions[i], style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}

class _ItineraryTab extends StatelessWidget {
  final TripPlan plan;
  const _ItineraryTab({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: plan.itinerary.length,
      itemBuilder: (context, i) {
        final day = plan.itinerary[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(day.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            children: day.activities.map((a) => ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle_outline, size: 16),
              title: Text(a, style: const TextStyle(fontSize: 13)),
            )).toList(),
          ),
        );
      },
    );
  }
}

class _PackingTab extends StatelessWidget {
  final TripPlan plan;
  const _PackingTab({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: plan.packingTips.length,
      itemBuilder: (context, i) => ListTile(
        leading: Icon(Icons.check_box_outline_blank, color: theme.colorScheme.primary),
        title: Text(plan.packingTips[i]),
      ),
    );
  }
}
