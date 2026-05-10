import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/trip_model.dart';
import '../../data/repositories/trip_repository.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TripModel> _filter(List<TripModel> trips, String tab) {
    final now = DateTime.now();
    return trips.where((t) {
      if (tab == 'Upcoming') return t.startDate.isAfter(now);
      if (tab == 'In Progress') {
        return t.startDate.isBefore(now) && t.endDate.isAfter(now);
      }
      return t.endDate.isBefore(now);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'In Progress'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (trips) => TabBarView(
          controller: _tabController,
          children: ['Upcoming', 'In Progress', 'Past']
              .map((tab) => _buildList(context, _filter(trips, tab), tab))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildList(
      BuildContext context, List<TripModel> trips, String status) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.luggage, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No $status trips yet',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.push('/create-trip'),
              icon: const Icon(Icons.add),
              label: const Text('Plan a Trip'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _TripCard(trip: trips[index]),
      ),
    );
  }
}

class _TripCard extends ConsumerWidget {
  final TripModel trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final budgetProgress = trip.budget > 0 ? (trip.spent / trip.budget) : 0.0;
    final dateRange =
        '${DateFormat.yMMMd().format(trip.startDate)} – ${DateFormat.yMMMd().format(trip.endDate)}';

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            height: 100,
            color: theme.colorScheme.primaryContainer,
            child: Row(
              children: [
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    trip.destination.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.name,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(trip.destination,
                          style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ),
                ),
                Chip(
                  label: Text(trip.type,
                      style: const TextStyle(fontSize: 12)),
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(dateRange,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey.shade700)),
                    const Spacer(),
                    Text('${trip.durationDays} days',
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary)),
                  ],
                ),
                if (trip.budget > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Spent: ₹${trip.spent.toStringAsFixed(0)} / ₹${trip.budget.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall),
                      Text('${(budgetProgress * 100).toInt()}%',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: budgetProgress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade200,
                    color: budgetProgress > 0.9
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          context.push('/trip/${trip.id}/builder'),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          context.push('/budget'),
                      icon: const Icon(Icons.bar_chart, size: 16),
                      label: const Text('Budget'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Trip'),
                            content: Text(
                                'Delete "${trip.name}"? This cannot be undone.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel')),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  ref
                                      .read(tripsProvider.notifier)
                                      .deleteTrip(trip.id);
                                },
                                child: Text('Delete',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
