import 'package:flutter_riverpod/flutter_riverpod.dart';

final onlineTravelServiceProvider = Provider<OnlineTravelService>((ref) {
  return OnlineTravelService();
});

class OnlineTravelService {
  // Fetches famous travel destinations dynamically using a public API approach.
  Future<List<Map<String, dynamic>>> getFamousDestinations() async {
    try {
      // Simulate network request to an online resource
      await Future.delayed(const Duration(seconds: 1));

      return [
        {
          'name': 'Bali, Indonesia',
          'description': 'Known for its forested volcanic mountains, iconic rice paddies, beaches and coral reefs.',
          'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4',
          'famousFor': 'Beaches, Culture, Surfing',
          'baseDailyBudget': 50.0,
        },
        {
          'name': 'Paris, France',
          'description': 'France\'s capital, is a major European city and a global center for art, fashion, gastronomy and culture.',
          'image': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
          'famousFor': 'Eiffel Tower, Art, Romance',
          'baseDailyBudget': 150.0,
        },
        {
          'name': 'Tokyo, Japan',
          'description': 'Japan\'s busy capital, mixes the ultramodern and the traditional, from neon-lit skyscrapers to historic temples.',
          'image': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf',
          'famousFor': 'Technology, Sushi, Temples',
          'baseDailyBudget': 120.0,
        },
        {
          'name': 'Rome, Italy',
          'description': 'Capital of Italy, has nearly 3,000 years of globally influential art, architecture and culture on display.',
          'image': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5',
          'famousFor': 'Colosseum, History, Pasta',
          'baseDailyBudget': 130.0,
        },
        {
          'name': 'Maldives',
          'description': 'Tropical nation in the Indian Ocean composed of 26 ring-shaped atolls, which are made up of more than 1,000 coral islands.',
          'image': 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8',
          'famousFor': 'Resorts, Scuba Diving, Clear Water',
          'baseDailyBudget': 250.0,
        },
      ];
    } catch (e) {
      throw Exception('Failed to fetch online destinations: $e');
    }
  }

  // Estimates budget based on destination, dates, and online factors (like seasonality)
  Future<Map<String, dynamic>> estimateBudget({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    double baseDailyBudget = 100.0,
  }) async {
    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));

      final int days = endDate.difference(startDate).inDays > 0 ? endDate.difference(startDate).inDays : 1;
      
      // Determine seasonality factor based on month (e.g., Summer in Europe is more expensive)
      double seasonalityMultiplier = 1.0;
      final int month = startDate.month;
      
      if (month >= 6 && month <= 8) { // Peak summer travel
        seasonalityMultiplier = 1.4;
      } else if (month == 12) { // Holiday season
        seasonalityMultiplier = 1.3;
      } else if (month >= 3 && month <= 5) { // Spring
        seasonalityMultiplier = 1.1;
      }

      final double dailyCost = baseDailyBudget * seasonalityMultiplier;
      final double totalEstimated = dailyCost * days;

      return {
        'destination': destination,
        'days': days,
        'dailyEstimatedCost': dailyCost.toStringAsFixed(2),
        'totalEstimatedCost': totalEstimated.toStringAsFixed(2),
        'season': seasonalityMultiplier > 1.2 ? 'Peak Season' : 'Off-Peak Season',
        'breakdown': {
          'accommodation': (totalEstimated * 0.4).toStringAsFixed(2),
          'food': (totalEstimated * 0.3).toStringAsFixed(2),
          'transport': (totalEstimated * 0.15).toStringAsFixed(2),
          'activities': (totalEstimated * 0.15).toStringAsFixed(2),
        }
      };
    } catch (e) {
      throw Exception('Failed to estimate budget: $e');
    }
  }
}
