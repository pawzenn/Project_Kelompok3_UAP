import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Jalankan ini kapan saja (misal dari main() atau dari tombol),
/// hasilnya cuma muncul di Debug Console / Logcat.
Future<void> runStorageBenchmark() async {
  debugPrint('======================');
  debugPrint('🔬 MULAI UJI STORAGE...');
  debugPrint('======================');

  final hive = await _runHiveBenchmark();
  final prefs = await _runPrefsBenchmark();
  final supa = await _runSupabaseBenchmark();

  debugPrint('----------------------');
  debugPrint('✅ HASIL AKHIR UJI STORAGE');
  debugPrint(hive);
  debugPrint(prefs);
  debugPrint(supa);
  debugPrint('======================');
}

/// Uji kecepatan baca/tulis Hive (local DB)
Future<String> _runHiveBenchmark() async {
  const boxName = 'benchmark_box';

  if (!Hive.isBoxOpen(boxName)) {
    await Hive.openBox<String>(boxName);
  }
  final Box<String> box = Hive.box<String>(boxName);

  const int itemCount = 1000;

  final writeWatch = Stopwatch()..start();
  for (int i = 0; i < itemCount; i++) {
    await box.put('key_$i', 'value_$i');
  }
  writeWatch.stop();

  final readWatch = Stopwatch()..start();
  for (int i = 0; i < itemCount; i++) {
    final _ = box.get('key_$i');
  }
  readWatch.stop();

  final msg =
      'Hive → tulis $itemCount item: ${writeWatch.elapsedMilliseconds} ms, '
      'baca $itemCount item: ${readWatch.elapsedMilliseconds} ms';

  debugPrint(msg);
  return msg;
}

/// Uji kecepatan baca/tulis SharedPreferences
Future<String> _runPrefsBenchmark() async {
  final prefs = await SharedPreferences.getInstance();
  const int itemCount = 1000;

  final writeWatch = Stopwatch()..start();
  for (int i = 0; i < itemCount; i++) {
    await prefs.setString('prefs_key_$i', 'prefs_value_$i');
  }
  writeWatch.stop();

  final readWatch = Stopwatch()..start();
  for (int i = 0; i < itemCount; i++) {
    final _ = prefs.getString('prefs_key_$i');
  }
  readWatch.stop();

  final msg =
      'SharedPreferences → tulis $itemCount item: ${writeWatch.elapsedMilliseconds} ms, '
      'baca $itemCount item: ${readWatch.elapsedMilliseconds} ms';

  debugPrint(msg);
  return msg;
}

/// Uji kecepatan fetch data dari Supabase (cloud)
Future<String> _runSupabaseBenchmark() async {
  try {
    final client = Supabase.instance.client;

    final watch = Stopwatch()..start();

    // ⚠️ GANTI 'products' DENGAN NAMA TABEL PUNYAMU
    final List<dynamic> rows = await client
        .from('products') // misal: 'menus' atau 'katalog'
        .select('*')
        .limit(20);

    watch.stop();

    final msg =
        'Supabase (cloud) → fetch ${rows.length} row: ${watch.elapsedMilliseconds} ms';

    debugPrint(msg);
    return msg;
  } catch (e, st) {
    debugPrint('❌ Supabase benchmark error: $e');
    debugPrint(st.toString());
    return 'Supabase (cloud) → ERROR: $e';
  }
}
