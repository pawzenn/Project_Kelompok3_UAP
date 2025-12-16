import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Pastikan permission lokasi diizinkan.
  /// return: true jika granted, false jika ditolak.
  Future<bool> ensurePermission() async {
    // cek permission while-in-use
    final status = await Permission.locationWhenInUse.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await Permission.locationWhenInUse.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Cek apakah Location Service (GPS) nyala.
  Future<bool> isServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Ambil posisi sekali (single reading).
  /// useGps = true → akurasi tinggi (GPS),
  /// useGps = false → akurasi lebih santai (anggap Network).
  Future<Position> getCurrentPosition({required bool useGps}) async {
    final hasPermission = await ensurePermission();
    if (!hasPermission) {
      throw Exception('Permission lokasi tidak diizinkan.');
    }

    final enabled = await isServiceEnabled();
    if (!enabled) {
      throw Exception('Location service (GPS) tidak aktif.');
    }

    final accuracy = useGps ? LocationAccuracy.high : LocationAccuracy.low;

    return Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
  }

  /// Stream posisi realtime (untuk Live Location).
  Stream<Position> getPositionStream({required bool useGps}) {
    final accuracy = useGps ? LocationAccuracy.high : LocationAccuracy.low;

    const distanceFilter = 5.0; // update setiap pindah ~5 meter

    final settings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter.toInt(),
    );

    return Geolocator.getPositionStream(locationSettings: settings);
  }
}
