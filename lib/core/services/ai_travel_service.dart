import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiTravelServiceProvider = Provider<AITravelService>((ref) => AITravelService());

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

class DayPlan {
  final int day;
  final String title;
  final List<String> activities;
  DayPlan({required this.day, required this.title, required this.activities});
}

class TripPlan {
  final String destination;
  final String description;
  final String imageUrl;
  final List<String> topAttractions;
  final List<String> nearbyPlaces;
  final List<String> packingTips;
  final String bestSeason;
  final String weatherTip;
  final List<DayPlan> itinerary;
  final double baseDailyCost;
  final double distanceKm;
  final String famousFor;

  TripPlan({
    required this.destination,
    required this.description,
    required this.imageUrl,
    required this.topAttractions,
    required this.nearbyPlaces,
    required this.packingTips,
    required this.bestSeason,
    required this.weatherTip,
    required this.itinerary,
    required this.baseDailyCost,
    required this.distanceKm,
    required this.famousFor,
  });
}

class BudgetEstimate {
  final String tier;
  final double total;
  final double hotel;
  final double food;
  final double transport;
  final double activities;
  BudgetEstimate({
    required this.tier,
    required this.total,
    required this.hotel,
    required this.food,
    required this.transport,
    required this.activities,
  });
}

// ─────────────────────────────────────────────
// CURATED DESTINATION DATABASE
// ─────────────────────────────────────────────
final Map<String, Map<String, dynamic>> _destinationDB = {
  'goa': {
    'description': 'Goa is India\'s beach paradise, famous for its golden sand beaches, vibrant nightlife, Portuguese heritage, and delicious seafood.',
    'image': 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=800&q=80',
    'topAttractions': ['Baga Beach', 'Dudhsagar Falls', 'Fort Aguada', 'Anjuna Beach', 'Chapora Fort', 'Basilica of Bom Jesus', 'Calangute Beach', 'Dona Paula', 'Colva Beach', 'Palolem Beach'],
    'nearbyPlaces': ['Panaji', 'Vasco da Gama', 'Margao', 'Mapusa', 'Calangute'],
    'packingTips': ['Light cotton clothes', 'Sunscreen SPF 50+', 'Swimwear', 'Flip flops', 'Waterproof bag', 'Bug repellent'],
    'bestSeason': 'November to March',
    'weatherTip': 'October to March is ideal. Avoid June–September (monsoon). Carry sunscreen and light clothes.',
    'famousFor': 'Beaches, Nightlife, Seafood, Portuguese Heritage',
    'baseDailyCost': 2500.0,
    'distanceKm': 590.0,
    'itinerary': {
      1: {'title': 'Arrive & Hit the Beach', 'activities': ['Check into your hotel', 'Visit Baga Beach in the evening', 'Enjoy fresh seafood dinner at a beach shack', 'Explore Tito\'s Lane nightlife']},
      2: {'title': 'North Goa Highlights', 'activities': ['Morning at Anjuna Beach flea market', 'Visit Chapora Fort (Dil Chahta Hai fort!)', 'Lunch at Vagator', 'Evening water sports at Calangute']},
      3: {'title': 'Heritage & History', 'activities': ['Visit Basilica of Bom Jesus (UNESCO World Heritage)', 'Explore Se Cathedral & Old Goa churches', 'Spice Plantation tour with lunch', 'Sunset cruise on Mandovi River']},
      4: {'title': 'South Goa & Waterfalls', 'activities': ['Drive to Dudhsagar Falls', 'Stop at Colva Beach on return', 'Evening at Palolem Beach', 'Farewell dinner']},
    },
  },
  'kerala': {
    'description': 'Kerala, "God\'s Own Country", is renowned for its backwaters, lush tea gardens, Ayurveda retreats, and diverse wildlife.',
    'image': 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=800&q=80',
    'topAttractions': ['Alleppey Backwaters', 'Munnar Tea Gardens', 'Periyar Wildlife Sanctuary', 'Varkala Beach', 'Fort Kochi', 'Athirappilly Waterfalls', 'Thekkady', 'Kovalam Beach', 'Wayanad', 'Bekal Fort'],
    'nearbyPlaces': ['Kochi', 'Thiruvananthapuram', 'Thrissur', 'Kozhikode', 'Kollam'],
    'packingTips': ['Light cotton clothes', 'Umbrella or raincoat', 'Mosquito repellent', 'Comfortable walking shoes', 'Modest clothing for temples', 'Camera with waterproof case'],
    'bestSeason': 'September to March',
    'weatherTip': 'Best visited from September to March. Monsoon (June–August) makes backwaters lush but some roads flood.',
    'famousFor': 'Backwaters, Ayurveda, Tea Gardens, Wildlife',
    'baseDailyCost': 2000.0,
    'distanceKm': 1300.0,
    'itinerary': {
      1: {'title': 'Arrive in Kochi', 'activities': ['Explore Fort Kochi & Chinese Fishing Nets', 'Visit Mattancherry Palace', 'Kerala Kathakali show in evening', 'Dinner with traditional Kerala Sadya']},
      2: {'title': 'Alleppey Backwaters', 'activities': ['Board a houseboat in Alleppey', 'Cruise through scenic backwater canals', 'Fish from the boat deck', 'Overnight stay on houseboat']},
      3: {'title': 'Munnar Tea Country', 'activities': ['Drive up to Munnar hill station', 'Visit Eravikulam National Park', 'Tea plantation tour & tasting', 'Sunset at Top Station viewpoint']},
      4: {'title': 'Periyar Wildlife', 'activities': ['Morning jungle safari in Periyar', 'Boat ride on Periyar Lake', 'Spice garden walk in Thekkady', 'Ayurvedic massage experience']},
    },
  },
  'paris': {
    'description': 'Paris, the City of Light, is the world\'s most romantic destination — iconic landmarks, world-class art, haute cuisine and chic boulevards.',
    'image': 'https://images.unsplash.com/photo-1502602881469-4478ae4b693e?auto=format&fit=crop&w=800&q=80',
    'topAttractions': ['Eiffel Tower', 'The Louvre', 'Notre-Dame Cathedral', 'Champs-Élysées', 'Arc de Triomphe', 'Musée d\'Orsay', 'Sacré-Cœur', 'Palace of Versailles', 'Seine River Cruise', 'Montmartre'],
    'nearbyPlaces': ['Versailles', 'Giverny', 'Fontainebleau', 'Épernay', 'Lyon'],
    'packingTips': ['Comfortable walking shoes', 'Light layers for evening', 'Universal power adapter', 'Pocket phrase book', 'Camera', 'Scarf (dress code for churches)'],
    'bestSeason': 'April to June, September to November',
    'weatherTip': 'Spring (April–June) is magical with blooming flowers. Avoid July–August peak tourist crowds. Carry layers for evenings.',
    'famousFor': 'Eiffel Tower, Art, Romance, Fashion, Cuisine',
    'baseDailyCost': 9000.0,
    'distanceKm': 7900.0,
    'itinerary': {
      1: {'title': 'Icons of Paris', 'activities': ['Morning at the Eiffel Tower (book tickets!)', 'Lunch at a Parisian café', 'Explore the Louvre Museum', 'Evening Seine River cruise with dinner']},
      2: {'title': 'Art & Culture', 'activities': ['Visit Musée d\'Orsay (Impressionist masterpieces)', 'Walk Champs-Élysées to Arc de Triomphe', 'Explore Le Marais district', 'Dinner in a traditional brasserie']},
      3: {'title': 'Montmartre & Versailles', 'activities': ['Morning in Montmartre & Sacré-Cœur', 'Artists\' Square at Place du Tertre', 'Afternoon at Palace of Versailles', 'Return to Paris for nightlife']},
    },
  },
  'tokyo': {
    'description': 'Tokyo is a city where ancient temples sit beside neon-lit skyscrapers — a mind-blowing blend of tradition, technology, anime culture, and world-class food.',
    'image': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=800&q=80',
    'topAttractions': ['Shibuya Crossing', 'Senso-ji Temple', 'Shinjuku Gyoen', 'Akihabara', 'Tokyo Skytree', 'Harajuku', 'Tsukiji Fish Market', 'Odaiba', 'Meiji Shrine', 'DisneySea'],
    'nearbyPlaces': ['Nikko', 'Kamakura', 'Hakone (Mt. Fuji view)', 'Kyoto', 'Yokohama'],
    'packingTips': ['IC transit card (Suica)', 'Pocket WiFi', 'Comfortable walking shoes', 'Cash (Japan is cash-heavy)', 'Chopstick etiquette guide', 'Lightweight rain jacket'],
    'bestSeason': 'March–April (Cherry Blossom), October–November (Autumn)',
    'weatherTip': 'Cherry blossom season (late March–early April) is spectacular but crowded. Autumn foliage (Oct–Nov) is equally beautiful.',
    'famousFor': 'Technology, Sushi, Anime, Culture, Cherry Blossoms',
    'baseDailyCost': 8500.0,
    'distanceKm': 5900.0,
    'itinerary': {
      1: {'title': 'Arrival & Shibuya Buzz', 'activities': ['Drop bags at hotel, explore Shinjuku', 'Famous Shibuya Scramble Crossing at rush hour', 'Explore Harajuku Takeshita Street', 'Ramen dinner in Roppongi']},
      2: {'title': 'Old Tokyo & Temples', 'activities': ['Morning at Senso-ji Temple in Asakusa', 'Traditional rickshaw ride', 'Akihabara Electronics/Anime district', 'Tokyo Skytree observation deck']},
      3: {'title': 'Tsukiji & Day Trip', 'activities': ['Sunrise tuna auction at Toyosu Market', 'Sushi breakfast at Tsukiji Outer Market', 'Day trip to Kamakura (Giant Buddha)', 'Yakitori dinner in Yurakucho']},
    },
  },
  'bali': {
    'description': 'Bali is Indonesia\'s island of the gods — a paradise of rice terraces, volcanic mountains, pristine beaches, ancient temples, and warm Balinese culture.',
    'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=800&q=80',
    'topAttractions': ['Uluwatu Temple', 'Tegallalang Rice Terraces', 'Sacred Monkey Forest', 'Kuta Beach', 'Mount Batur Sunrise Trek', 'Tanah Lot Temple', 'Seminyak', 'Nusa Penida Island', 'Ubud Palace', 'GWK Cultural Park'],
    'nearbyPlaces': ['Ubud', 'Seminyak', 'Canggu', 'Nusa Dua', 'Lombok Island'],
    'packingTips': ['Sarong (required at temples)', 'High SPF sunscreen', 'Mosquito repellent (DEET)', 'Motion sickness tablets for winding roads', 'Waterproof sandals', 'Snorkel gear'],
    'bestSeason': 'April to October (Dry Season)',
    'weatherTip': 'Dry season (April–October) is best. November–March is wet season with lush greenery but heavy rains.',
    'famousFor': 'Beaches, Temples, Rice Terraces, Surfing, Spirituality',
    'baseDailyCost': 3500.0,
    'distanceKm': 5800.0,
    'itinerary': {
      1: {'title': 'Arrive & Beach Vibes', 'activities': ['Check into villa in Seminyak', 'Relax at Kuta Beach', 'Watch sunset at Tanah Lot Temple', 'Jimbaran Beach seafood BBQ dinner']},
      2: {'title': 'Ubud Culture Day', 'activities': ['Tegallalang Rice Terrace visit', 'Sacred Monkey Forest Sanctuary', 'Ubud Palace & traditional dance show', 'Ubud night market for local food']},
      3: {'title': 'Adventure Day', 'activities': ['Mount Batur sunrise trek (3am start!)', 'Breakfast with crater view', 'Afternoon at Tirta Empul holy springs', 'Sunset at Uluwatu Temple with Kecak fire dance']},
      4: {'title': 'Island Escape', 'activities': ['Fast boat to Nusa Penida island', 'Kelingking Beach (T-Rex Cliff)', 'Crystal Bay snorkeling with Manta Rays', 'Return to Bali, final sunset at Seminyak']},
    },
  },
  'ooty': {
    'description': 'Ooty (Udhagamandalam) is the "Queen of Hill Stations" — a serene escape in the Nilgiri Hills with tea gardens, botanical gardens, and a famous toy train.',
    'image': 'https://images.unsplash.com/photo-1590136971977-04d31af98de0?auto=format&fit=crop&w=800&q=80',
    'topAttractions': ['Ooty Lake', 'Nilgiri Mountain Railway', 'Government Botanical Garden', 'Doddabetta Peak', 'Rose Garden', 'Pykara Lake', 'Avalanche Lake', 'Toda Huts', 'Mudumalai National Park', 'Kodanad Elephant Camp'],
    'nearbyPlaces': ['Coonoor', 'Kotagiri', 'Gudalur', 'Mettupalayam', 'Mysore'],
    'packingTips': ['Warm jackets & woollens', 'Comfortable trekking shoes', 'Umbrella (heavy showers possible)', 'Hot beverages thermos', 'Camera for scenic views', 'Light layers for daytime'],
    'bestSeason': 'October to June',
    'weatherTip': 'Peak season is April–June. December is cold but beautiful. Avoid July–September monsoon. Always carry a jacket — temperatures drop at night.',
    'famousFor': 'Tea Gardens, Toy Train, Hill Station, Botanical Gardens',
    'baseDailyCost': 1800.0,
    'distanceKm': 540.0,
    'itinerary': {
      1: {'title': 'Arrive & Explore Town', 'activities': ['Check into a heritage hotel', 'Visit Botanical Garden', 'Boat ride on Ooty Lake', 'Shop for homemade chocolate & tea on Commercial Street']},
      2: {'title': 'Nature & Heights', 'activities': ['Sunrise trek to Doddabetta Peak (highest in Nilgiris)', 'Tea factory visit & tasting in the morning', 'Pykara Lake & Waterfalls afternoon', 'Evening at Rose Garden']},
      3: {'title': 'Toy Train & Coonoor', 'activities': ['Iconic Nilgiri Mountain Railway (UNESCO) to Coonoor', 'Lamb\'s Rock viewpoint', 'Sim\'s Park botanical garden', 'Return by toy train or road — both equally beautiful']},
    },
  },
  'maldives': {
    'description': 'The Maldives is the world\'s ultimate luxury escape — a string of 1,200 coral islands with crystal-clear lagoons, overwater bungalows, and the world\'s best dive sites.',
    'image': 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=800&q=80',
    'topAttractions': ['Overwater Bungalow Stay', 'Scuba Diving at Maaya Thila', 'Whale Shark Snorkeling in Hanifaru Bay', 'Male City Tour', 'Bioluminescent Beach Night Walk', 'Dolphin Cruise', 'Submarine Tour', 'Manta Ray Diving', 'Local Island Hopping', 'Sunset Fishing'],
    'nearbyPlaces': ['Malé', 'Hulhumale', 'Maafushi', 'Guraidhoo', 'Thulusdhoo'],
    'packingTips': ['Reef-safe sunscreen only', 'Underwater camera', 'Modest clothing for local islands', 'Seasickness tablets for ferry rides', 'Light linen clothes', 'Snorkel gear (or rent on-site)'],
    'bestSeason': 'November to April (Dry Season)',
    'weatherTip': 'Dry season (Nov–April) with calm seas is perfect. May–October is wetter but cheaper with bigger waves for surfing.',
    'famousFor': 'Luxury Resorts, Crystal Water, Scuba Diving, Overwater Bungalows',
    'baseDailyCost': 18000.0,
    'distanceKm': 2700.0,
    'itinerary': {
      1: {'title': 'Paradise Arrival', 'activities': ['Speedboat to resort island', 'Check into overwater bungalow', 'Snorkeling in the house reef', 'Sunset cocktail on your private deck']},
      2: {'title': 'Underwater Wonders', 'activities': ['Scuba dive at the coral reef (beginner courses available)', 'Whale shark snorkeling excursion', 'Relaxing at the infinity pool', 'Candlelit beach dinner']},
      3: {'title': 'Island Hopping', 'activities': ['Speedboat to a local Maldivian island', 'Fresh seafood lunch with locals', 'Deserted sandbank picnic', 'Bioluminescent beach experience at night']},
    },
  },
};

String _getGenericDescription(String destination) =>
    '$destination is a wonderful travel destination known for its unique culture, scenic beauty, and warm hospitality. Here is your smart AI-generated trip plan.';

// ─────────────────────────────────────────────
// SERVICE CLASS
// ─────────────────────────────────────────────
class AITravelService {

  TripPlan generateTripPlan(String destination, int days) {
    final key = destination.toLowerCase().trim();
    final db = _destinationDB[key];

    if (db != null) {
      // Build day plans from curated DB
      final itineraryMap = db['itinerary'] as Map<int, Map<String, dynamic>>;
      final List<DayPlan> plans = [];
      for (int i = 1; i <= days; i++) {
        final d = itineraryMap[i] ?? itineraryMap[((i - 1) % itineraryMap.length) + 1]!;
        plans.add(DayPlan(
          day: i,
          title: d['title'],
          activities: List<String>.from(d['activities']),
        ));
      }
      return TripPlan(
        destination: destination,
        description: db['description'],
        imageUrl: db['image'],
        topAttractions: List<String>.from(db['topAttractions']),
        nearbyPlaces: List<String>.from(db['nearbyPlaces']),
        packingTips: List<String>.from(db['packingTips']),
        bestSeason: db['bestSeason'],
        weatherTip: db['weatherTip'],
        itinerary: plans,
        baseDailyCost: db['baseDailyCost'],
        distanceKm: db['distanceKm'],
        famousFor: db['famousFor'],
      );
    }

    // Generic fallback for unknown destinations
    return TripPlan(
      destination: destination,
      description: _getGenericDescription(destination),
      imageUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=800&q=80',
      topAttractions: ['City Centre', 'Local Market', 'Historic Fort', 'Scenic Viewpoint', 'Cultural Museum', 'Famous Temple', 'Waterfront', 'Night Market', 'Art Gallery', 'Botanical Garden'],
      nearbyPlaces: ['Old Town', 'Airport District', 'Riverside Area', 'Hill Station Nearby', 'Beach Nearby'],
      packingTips: ['Comfortable walking shoes', 'Sunscreen', 'Universal adapter', 'Light jacket', 'Camera', 'Cash & cards'],
      bestSeason: 'October to March',
      weatherTip: 'October to March is generally ideal for travel in India. Always carry a light jacket for evenings.',
      itinerary: List.generate(days, (i) => DayPlan(
        day: i + 1,
        title: 'Explore $destination — Day ${i + 1}',
        activities: [
          'Morning: Breakfast at a local popular café',
          'Mid-day: Visit the top historical attractions & museums',
          'Afternoon: Local market exploration & street food',
          'Evening: Scenic viewpoint or waterfront for sunset',
          'Dinner: Popular local restaurant with authentic cuisine',
        ],
      )),
      baseDailyCost: 2000.0,
      distanceKm: 1000.0,
      famousFor: 'Culture, History, Scenic Beauty',
    );
  }

  List<BudgetEstimate> calculateBudgetTiers({
    required int days,
    required int travelers,
    required double baseDailyCost,
    required double distanceKm,
  }) {
    double transportPerPerson = distanceKm * 0.08; // Round trip flight/train
    double baseTrip = (baseDailyCost * days + transportPerPerson) * travelers;

    return [
      _makeTier('Budget 🎒', baseTrip * 1.0, days, travelers),
      _makeTier('Medium 🏨', baseTrip * 2.5, days, travelers),
      _makeTier('Luxury ✨', baseTrip * 5.0, days, travelers),
    ];
  }

  BudgetEstimate _makeTier(String tier, double total, int days, int travelers) {
    return BudgetEstimate(
      tier: tier,
      total: total,
      hotel: total * 0.40,
      food: total * 0.25,
      transport: total * 0.20,
      activities: total * 0.15,
    );
  }

  String getSeasonTip(String destination, DateTime date) {
    final key = destination.toLowerCase().trim();
    final db = _destinationDB[key];
    if (db != null) return db['weatherTip'];
    final month = date.month;
    if (month >= 11 || month <= 2) return 'Winter travel — carry warm layers and jackets.';
    if (month >= 3 && month <= 5) return 'Summer travel — light cotton clothes and sunscreen essential.';
    return 'Monsoon season — carry umbrella/raincoat. Some scenic waterfalls are active now!';
  }

  List<String> getPackingList(String destination) {
    final key = destination.toLowerCase().trim();
    return (_destinationDB[key]?['packingTips'] as List<String>?) ??
        ['Comfortable shoes', 'Sunscreen', 'Camera', 'Universal adapter', 'Cash & cards', 'First aid kit'];
  }
}
