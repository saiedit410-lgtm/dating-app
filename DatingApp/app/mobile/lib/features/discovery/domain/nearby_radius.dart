/// User-selectable search radius for the nearby tab.
///
/// Values are tuned to the geohash precision-5 cell (≈5km × 5km): 5km stays
/// inside one cell, 50km reaches a 9-cell neighborhood.
enum NearbyRadius {
  five(5, '5 km'),
  ten(10, '10 km'),
  twentyFive(25, '25 km'),
  fifty(50, '50 km');

  const NearbyRadius(this.km, this.label);

  final int km;
  final String label;

  static NearbyRadius fromKm(int km) {
    return NearbyRadius.values.firstWhere(
      (NearbyRadius r) => r.km == km,
      orElse: () => NearbyRadius.ten,
    );
  }
}
