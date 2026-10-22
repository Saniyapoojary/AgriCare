enum UserRole { farmer, worker }

class AppUser {
  final String id;
  String name;
  final String phone;
  UserRole role;
  double locationLat;
  double locationLng;
  String address;
  double walletBalance;

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.locationLat,
    required this.locationLng,
    required this.address,
    this.walletBalance = 1000,
  });
}
