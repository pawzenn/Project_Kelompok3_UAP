import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_application_1/data/providers/cart_remote_provider.dart';

/// Dipakai untuk mewakili kondisi offline
class OfflineException implements Exception {
  final String message;
  OfflineException([this.message = 'Fitur ini memerlukan koneksi internet']);
}

class CartRepository {
  final CartRemoteProvider cartRemoteProvider;

  CartRepository({required this.cartRemoteProvider});

  /// Cek koneksi internet.
  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Tambah / update item di keranjang (upsert).
  ///
  /// - Hanya boleh saat online.
  /// - Jika offline → lempar [OfflineException].
  Future<void> upsertCartItem({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    if (!await _isOnline()) {
      throw OfflineException('Menambah ke keranjang hanya bisa saat online');
    }

    await cartRemoteProvider.upsertCartItem(
      userId: userId,
      productId: productId,
      quantity: quantity,
    );
  }

  /// Ambil isi keranjang user dari Supabase.
  ///
  /// Dipakai oleh CartController._loadCartFromServer() untuk sync antar perangkat.
  /// - Hanya boleh saat online.
  /// - Jika offline → lempar [OfflineException].
  Future<List<Map<String, dynamic>>> getCartItems({
    required String userId,
  }) async {
    if (!await _isOnline()) {
      throw OfflineException('Melihat keranjang hanya bisa saat online');
    }

    return await cartRemoteProvider.getCartItems(userId);
  }

  /// (Opsional) Alias lama kalau di tempat lain masih memanggil `getCart`.
  /// Boleh dibiarkan, nanti tinggal panggil `getCartItems`.
  Future<List<Map<String, dynamic>>> getCart(String userId) {
    return getCartItems(userId: userId);
  }

  /// Hapus 1 item dari keranjang.
  ///
  /// - Hanya boleh saat online.
  /// - Jika offline → lempar [OfflineException].
  Future<void> removeFromCart({
    required String userId,
    required String productId,
  }) async {
    if (!await _isOnline()) {
      throw OfflineException('Menghapus item keranjang hanya bisa saat online');
    }

    await cartRemoteProvider.deleteCartItem(
      userId: userId,
      productId: productId,
    );
  }

  /// Kosongkan seluruh keranjang user.
  ///
  /// - Dipakai setelah checkout berhasil.
  /// - Hanya boleh saat online.
  Future<void> clearCart(String userId) async {
    if (!await _isOnline()) {
      throw OfflineException('Kosongkan keranjang hanya bisa saat online');
    }

    await cartRemoteProvider.clearCart(userId);
  }
}
