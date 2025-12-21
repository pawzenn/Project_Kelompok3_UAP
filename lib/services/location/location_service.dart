import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static Future<Position> getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location service tidak aktif');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen (deniedForever)');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Reverse geocode tanpa geocoding package:
  /// pakai Nominatim (OpenStreetMap)
  static Future<String> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng',
    );

    final client = HttpClient();
    try {
      final req = await client.getUrl(uri);
      // User-Agent wajib (policy Nominatim)
      req.headers
          .set('User-Agent', 'LalapanApp/1.0 (contact: you@example.com)');
      final res = await req.close();

      if (res.statusCode != 200) return '$lat, $lng';

      final body = await res.transform(utf8.decoder).join();
      final map = json.decode(body) as Map<String, dynamic>;
      final displayName = (map['display_name'] ?? '').toString().trim();

      return displayName.isNotEmpty ? displayName : '$lat, $lng';
    } finally {
      client.close(force: true);
    }
  }

  /// Ambil rute dari user -> resto (polyline points) pakai OSRM public.
  /// Return list LatLng, kalau gagal fallback garis lurus [from,to].
  static Future<List<LatLng>> fetchRouteOSRM({
    required LatLng from,
    required LatLng to,
  }) async {
    // OSRM expects lon,lat
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
      '?overview=full&geometries=geojson',
    );

    final client = HttpClient();
    try {
      final req = await client.getUrl(uri);
      req.headers
          .set('User-Agent', 'LalapanApp/1.0 (contact: you@example.com)');
      final res = await req.close();
      if (res.statusCode != 200) return [from, to];

      final body = await res.transform(utf8.decoder).join();
      final map = json.decode(body) as Map<String, dynamic>;

      final routes = (map['routes'] as List?) ?? [];
      if (routes.isEmpty) return [from, to];

      final route0 = routes.first as Map<String, dynamic>;
      final geometry = route0['geometry'] as Map<String, dynamic>?;
      final coords = (geometry?['coordinates'] as List?) ?? [];

      final pts = <LatLng>[];
      for (final c in coords) {
        if (c is List && c.length >= 2) {
          final lon = (c[0] as num).toDouble();
          final lat = (c[1] as num).toDouble();
          pts.add(LatLng(lat, lon));
        }
      }

      return pts.isNotEmpty ? pts : [from, to];
    } finally {
      client.close(force: true);
    }
  }
}
