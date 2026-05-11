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
          'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=800&q=80',
          'famousFor': 'Beaches, Culture, Surfing',
          'baseDailyBudget': 60.0,
          'distanceKm': 5800.0,
        },
        {
          'name': 'Paris, France',
          'description': 'France\'s capital, is a major European city and a global center for art, fashion, gastronomy and culture.',
          'image': 'https://images.unsplash.com/photo-1502602881469-4478ae4b693e?auto=format&fit=crop&w=800&q=80',
          'famousFor': 'Eiffel Tower, Art, Romance',
          'baseDailyBudget': 150.0,
          'distanceKm': 7900.0,
        },
        {
          'name': 'Tokyo, Japan',
          'description': 'Japan\'s busy capital, mixes the ultramodern and the traditional, from neon-lit skyscrapers to historic temples.',
          'image': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=800&q=80',
          'famousFor': 'Technology, Sushi, Temples',
          'baseDailyBudget': 120.0,
          'distanceKm': 5900.0,
        },
        {
          'name': 'Rome, Italy',
          'description': 'Capital of Italy, has nearly 3,000 years of globally influential art, architecture and culture on display.',
          'image': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=800&q=80',
          'famousFor': 'Colosseum, History, Pasta',
          'baseDailyBudget': 130.0,
          'distanceKm': 7100.0,
        },
        {
          'name': 'Maldives',
          'description': 'Tropical nation in the Indian Ocean composed of 26 ring-shaped atolls, which are made up of more than 1,000 coral islands.',
          'image': 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=800&q=80',
          'famousFor': 'Resorts, Scuba Diving, Clear Water',
          'baseDailyBudget': 250.0,
          'distanceKm': 2700.0,
        },
      ];
    } catch (e) {
      throw Exception('Failed to fetch online destinations: $e');
    }
  }

  // Estimates budget based on destination, dates, distance, and online factors (like seasonality)
  Future<Map<String, dynamic>> estimateBudget({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required double distanceKm,
    double baseDailyBudget = 100.0,
  }) async {
    try {
      // Simulate network request for dynamic pricing based on distance and API factors
      await Future.delayed(const Duration(seconds: 1));

      final int days = endDate.difference(startDate).inDays > 0 ? endDate.difference(startDate).inDays : 1;
      
      // Determine seasonality factor based on month
      double seasonalityMultiplier = 1.0;
      final int month = startDate.month;
      
      if (month >= 6 && month <= 8) { // Peak summer travel
        seasonalityMultiplier = 1.4;
      } else if (month == 12) { // Holiday season
        seasonalityMultiplier = 1.3;
      } else if (month >= 3 && month <= 5) { // Spring
        seasonalityMultiplier = 1.1;
      }

      // Calculate transport cost dynamically based on distance (approx 0.12 USD per km round trip)
      final double transportCost = distanceKm * 0.12 * seasonalityMultiplier;
      final double dailyLivingCost = baseDailyBudget * seasonalityMultiplier;
      
      final double totalAccommodation = (dailyLivingCost * 0.4) * days;
      final double totalFood = (dailyLivingCost * 0.3) * days;
      final double totalActivities = (dailyLivingCost * 0.3) * days;
      
      final double totalEstimated = totalAccommodation + totalFood + totalActivities + transportCost;

      return {
        'destination': destination,
        'days': days,
        'distanceKm': distanceKm,
        'dailyEstimatedCost': dailyLivingCost.toStringAsFixed(2),
        'totalEstimatedCost': totalEstimated.toStringAsFixed(2),
        'season': seasonalityMultiplier > 1.2 ? 'Peak Season' : 'Off-Peak Season',
        'breakdown': {
          'accommodation': totalAccommodation.toStringAsFixed(2),
          'food': totalFood.toStringAsFixed(2),
          'transport': transportCost.toStringAsFixed(2),
          'activities': totalActivities.toStringAsFixed(2),
        }
      };
    } catch (e) {
      throw Exception('Failed to estimate budget: $e');
    }
  }
}
