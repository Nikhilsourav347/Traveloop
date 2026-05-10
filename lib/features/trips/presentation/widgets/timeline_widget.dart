import 'package:flutter/material.dart';
import 'activity_card.dart';

class TimelineWidget extends StatelessWidget {
  const TimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Day 1 Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Day 1',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Mon, Dec 20',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Timeline content with line
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary, width: 4),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary, width: 4),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  children: [
                    ActivityCard(
                      title: 'Arrive at Airport',
                      time: '10:00 AM',
                      location: 'Mumbai Int. Airport',
                      cost: '₹5,000',
                      duration: '2 hours',
                      icon: Icons.flight_land,
                    ),
                    ActivityCard(
                      title: 'Check-in Hotel',
                      time: '2:00 PM',
                      location: 'The Oberoi, Mumbai',
                      cost: '₹3,500',
                      duration: '1 hour',
                      icon: Icons.hotel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () {
              // Add activity bottom sheet
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Activity'),
          ),
        ),
        const SizedBox(height: 32),

        // Day 2 Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Day 2',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Tue, Dec 21',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary, width: 4),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  children: [
                    ActivityCard(
                      title: 'Travel to Goa',
                      time: '8:00 AM',
                      location: 'Highway Route 66',
                      cost: '₹2,500',
                      duration: '6 hours',
                      icon: Icons.directions_car,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () {
              // Add activity bottom sheet
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Activity'),
          ),
        ),
        const SizedBox(height: 24),
        
        Center(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.event_available),
            label: const Text('Add New Day'),
          ),
        ),
        const SizedBox(height: 80), // Padding for sticky bottom budget bar
      ],
    );
  }
}
