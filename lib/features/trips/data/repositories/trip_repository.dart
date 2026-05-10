import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_storage_service.dart';
import '../models/trip_model.dart';

class TripRepository {
  List<TripModel> getAllTrips() {
    return localStorageService
        .getAllTrips()
        .map(TripModel.fromMap)
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  TripModel? getTrip(String id) {
    final map = localStorageService.getTrip(id);
    return map == null ? null : TripModel.fromMap(map);
  }

  Future<TripModel> saveTrip(TripModel trip) async {
    localStorageService.saveTrip(trip.toMap());
    return trip;
  }

  Future<void> deleteTrip(String id) async {
    localStorageService.deleteTrip(id);
  }

  Future<TripModel> addActivity(
      String tripId, Map<String, dynamic> activity) async {
    final trip = getTrip(tripId);
    if (trip == null) throw Exception('Trip not found');
    final updated = TripModel(
      id: trip.id,
      name: trip.name,
      destination: trip.destination,
      startDate: trip.startDate,
      endDate: trip.endDate,
      type: trip.type,
      budget: trip.budget,
      spent: trip.spent + ((activity['cost'] as num?) ?? 0).toDouble(),
      activities: [...trip.activities, activity],
    );
    localStorageService.saveTrip(updated.toMap());
    return updated;
  }
}

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository();
});

// ─── Trips State Notifier ──────────────────────────────────────
class TripsNotifier extends StateNotifier<AsyncValue<List<TripModel>>> {
  final TripRepository _repo;

  TripsNotifier(this._repo) : super(const AsyncLoading()) {
    load();
  }

  void load() {
    state = AsyncData(_repo.getAllTrips());
  }

  Future<void> addTrip(TripModel trip) async {
    await _repo.saveTrip(trip);
    load();
  }

  Future<void> deleteTrip(String id) async {
    await _repo.deleteTrip(id);
    load();
  }
}

final tripsProvider =
    StateNotifierProvider<TripsNotifier, AsyncValue<List<TripModel>>>((ref) {
  return TripsNotifier(ref.watch(tripRepositoryProvider));
});
