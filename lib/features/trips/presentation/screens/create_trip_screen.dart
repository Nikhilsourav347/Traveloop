import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../data/models/trip_model.dart';
import '../../data/repositories/trip_repository.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _tripTypes = [
    'Solo', 'Family', 'Friends', 'Honeymoon', 'Business', 'Adventure'
  ];
  String _selectedType = 'Solo';
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ??
            (_startDate?.add(const Duration(days: 1)) ??
                DateTime.now().add(const Duration(days: 1))));

    final firstDate =
        isStart ? DateTime.now() : (_startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String get _durationText {
    if (_startDate == null || _endDate == null) return 'Select dates';
    final difference = _endDate!.difference(_startDate!).inDays;
    return '${difference + 1} days, $difference nights';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final trip = TripModel(
      name: _nameController.text.trim(),
      destination: _destinationController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      type: _selectedType,
      budget: double.tryParse(_budgetController.text) ?? 0,
    );

    await ref.read(tripsProvider.notifier).addTrip(trip);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ "${trip.name}" saved to your device!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Trip'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Cover Photo placeholder
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  Text('Tap to add cover photo',
                      style: TextStyle(color: theme.colorScheme.primary)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text('Trip Details',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Trip Name *',
                hintText: 'e.g., "Goa Beach Getaway"',
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Trip name is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination *',
                hintText: 'e.g., "Goa, India"',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Destination is required' : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Start Date *',
                          prefixIcon: Icon(Icons.calendar_today)),
                      child: Text(_startDate == null
                          ? 'Select'
                          : DateFormat.yMMMd().format(_startDate!)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'End Date *',
                          prefixIcon: Icon(Icons.event)),
                      child: Text(_endDate == null
                          ? 'Select'
                          : DateFormat.yMMMd().format(_endDate!)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Duration: $_durationText',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 16),

            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Budget Limit (₹)',
                hintText: 'Optional',
                prefixText: '₹ ',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 32),

            Text('Trip Type',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tripTypes.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),

            GradientButton(
              onPressed: _isSaving ? null : _submit,
              text: _isSaving ? 'Saving...' : 'Create Trip',
              isLoading: _isSaving,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
