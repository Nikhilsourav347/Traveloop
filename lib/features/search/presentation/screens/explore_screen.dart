import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const List<Map<String, dynamic>> _destinations = [
    {
      'name': 'Goa',
      'country': 'India',
      'tags': '🏖️ Beaches • Nightlife • Seafood',
      'budget': '₹2,500/day',
      'rating': '4.7',
      'image': 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=600&q=80',
      'color': 0xFF1E88E5,
    },
    {
      'name': 'Kerala',
      'country': 'India',
      'tags': '🌿 Backwaters • Ayurveda • Nature',
      'budget': '₹2,000/day',
      'rating': '4.8',
      'image': 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=600&q=80',
      'color': 0xFF43A047,
    },
    {
      'name': 'Ooty',
      'country': 'India',
      'tags': '🍃 Hill Station • Tea Gardens • Toy Train',
      'budget': '₹1,800/day',
      'rating': '4.6',
      'image': 'https://images.unsplash.com/photo-1590136971977-04d31af98de0?auto=format&fit=crop&w=600&q=80',
      'color': 0xFF00897B,
    },
    {
      'name': 'Paris',
      'country': 'France',
      'tags': '🏰 Romance • Art • Fashion • Cuisine',
      'budget': '₹9,000/day',
      'rating': '4.9',
      'image': 'https://images.unsplash.com/photo-1502602881469-4478ae4b693e?auto=format&fit=crop&w=600&q=80',
      'color': 0xFF8E24AA,
    },
    {
      'name': 'Tokyo',
      'country': 'Japan',
      'tags': '🏯 Technology • Anime • Temples • Sushi',
      'budget': '₹8,500/day',
      'rating': '4.9',
      'image': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=600&q=80',
      'color': 0xFFE53935,
    },
    {
      'name': 'Bali',
      'country': 'Indonesia',
      'tags': '🌺 Beaches • Temples • Rice Terraces • Surfing',
      'budget': '₹3,500/day',
      'rating': '4.8',
      'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=600&q=80',
      'color': 0xFFF4511E,
    },
    {
      'name': 'Maldives',
      'country': 'Maldives',
      'tags': '🤿 Luxury • Coral Reefs • Overwater Bungalows',
      'budget': '₹18,000/day',
      'rating': '4.9',
      'image': 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=600&q=80',
      'color': 0xFF00ACC1,
    },
  ];

  List<Map<String, dynamic>> get _filtered => _query.isEmpty
      ? _destinations
      : _destinations.where((d) =>
          d['name'].toString().toLowerCase().contains(_query.toLowerCase()) ||
          d['country'].toString().toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar with Search ──────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Text('Explore Destinations'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search Goa, Paris, Tokyo…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => _query = ''); })
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ),
            ),

            // ── Custom Search Result ─────────────────
            if (_query.isNotEmpty && _filtered.isEmpty)
              SliverToBoxAdapter(
                child: _CustomDestinationTile(destination: _query, theme: theme),
              ),

            // ── Destination Cards ────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _DestinationCard(dest: _filtered[i]),
                  childCount: _filtered.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Destination (not in DB) ─────────────────────
class _CustomDestinationTile extends StatelessWidget {
  final String destination;
  final ThemeData theme;
  const _CustomDestinationTile({required this.destination, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: const Icon(Icons.travel_explore),
          ),
          title: Text('Plan a trip to "$destination"', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Tap to get AI travel suggestions'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => context.push('/destination/$destination'),
        ),
      ),
    );
  }
}

// ─── Destination Card ────────────────────────────────────
class _DestinationCard extends StatelessWidget {
  final Map<String, dynamic> dest;
  const _DestinationCard({required this.dest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push('/destination/${dest['name']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              SizedBox(
                height: 200,
                child: CachedNetworkImage(
                  imageUrl: dest['image'],
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white, height: 200),
                  ),
                  errorWidget: (c, u, e) => Container(
                    height: 200,
                    color: Color(dest['color'] as int).withValues(alpha: 0.3),
                    child: const Icon(Icons.landscape, size: 64, color: Colors.white54),
                  ),
                ),
              ),
              // Info
              Container(
                color: theme.colorScheme.surface,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${dest['name']}, ${dest['country']}',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        Row(children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(dest['rating'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(dest['tags'], style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Text('~${dest['budget']}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.push('/destination/${dest['name']}'),
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text('AI Trip Planner'),
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
