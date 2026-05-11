import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/online_travel_service.dart';
import 'package:intl/intl.dart';

class SuggestionsScreen extends ConsumerStatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  ConsumerState<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends ConsumerState<SuggestionsScreen> {
  List<Map<String, dynamic>>? destinations;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDestinations();
  }

  Future<void> _fetchDestinations() async {
    try {
      final service = ref.read(onlineTravelServiceProvider);
      final data = await service.getFamousDestinations();
      setState(() {
        destinations = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showBudgetEstimator(Map<String, dynamic> destination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _BudgetEstimatorSheet(destination: destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Travel Inspiration')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : destinations == null || destinations!.isEmpty
              ? const Center(child: Text('No suggestions available at the moment.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: destinations!.length,
                  itemBuilder: (context, index) {
                    final dest = destinations![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _showBudgetEstimator(dest),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              dest['image'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (c,e,s) => Container(height: 200, color: Colors.grey[300]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dest['name'], style: Theme.of(context).textTheme.titleLarge),
                                  const SizedBox(height: 4),
                                  Text('Famous for: ${dest['famousFor']}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                                  const SizedBox(height: 8),
                                  Text(dest['description']),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: FilledButton.icon(
                                      onPressed: () => _showBudgetEstimator(dest),
                                      icon: const Icon(Icons.calculate_outlined),
                                      label: const Text('Estimate Budget'),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _BudgetEstimatorSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> destination;
  const _BudgetEstimatorSheet({required this.destination});

  @override
  ConsumerState<_BudgetEstimatorSheet> createState() => _BudgetEstimatorSheetState();
}

class _BudgetEstimatorSheetState extends ConsumerState<_BudgetEstimatorSheet> {
  DateTimeRange? _dateRange;
  Map<String, dynamic>? _estimate;
  bool _isEstimating = false;

  Future<void> _pickDates() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  Future<void> _getEstimate() async {
    if (_dateRange == null) return;
    setState(() => _isEstimating = true);
    try {
      final service = ref.read(onlineTravelServiceProvider);
      final estimate = await service.estimateBudget(
        destination: widget.destination['name'],
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
        distanceKm: widget.destination['distanceKm'] as double? ?? 5000.0,
        baseDailyBudget: widget.destination['baseDailyBudget'] as double,
      );
      setState(() {
        _estimate = estimate;
        _isEstimating = false;
      });
    } catch (e) {
      setState(() => _isEstimating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Estimate Budget for ${widget.destination['name']}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickDates,
            icon: const Icon(Icons.date_range),
            label: Text(_dateRange == null 
              ? 'Select Travel Dates' 
              : '${DateFormat.yMMMd().format(_dateRange!.start)} - ${DateFormat.yMMMd().format(_dateRange!.end)}'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _dateRange == null || _isEstimating ? null : _getEstimate,
            child: _isEstimating ? const CircularProgressIndicator(color: Colors.white) : const Text('Calculate Estimate'),
          ),
          const SizedBox(height: 24),
          if (_estimate != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16)
              ),
              child: Column(
                children: [
                  Text('Total Estimated Cost', style: Theme.of(context).textTheme.titleMedium),
                  Text('\$${_estimate!['totalEstimatedCost']}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 8),
                  Text('For ${_estimate!['days']} days in ${_estimate!['season']}'),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Accommodation:'), Text('\$${_estimate!['breakdown']['accommodation']}')]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Food & Dining:'), Text('\$${_estimate!['breakdown']['food']}')]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Transport:'), Text('\$${_estimate!['breakdown']['transport']}')]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Activities:'), Text('\$${_estimate!['breakdown']['activities']}')]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final text = 'Check out this travel budget estimate!\n\n'
                            'Destination: ${_estimate!['destination']}\n'
                            'Distance: ${_estimate!['distanceKm']} km\n'
                            'Days: ${_estimate!['days']} (${_estimate!['season']})\n'
                            'Total Cost: \$${_estimate!['totalEstimatedCost']}\n\n'
                            'Accommodation: \$${_estimate!['breakdown']['accommodation']}\n'
                            'Food: \$${_estimate!['breakdown']['food']}\n'
                            'Transport: \$${_estimate!['breakdown']['transport']}\n'
                            'Activities: \$${_estimate!['breakdown']['activities']}\n\n'
                            'Planned with Traveloop App!';
                        Share.share(text);
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share Estimate'),
                    ),
                  ),
                ],
              ),
            )
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
