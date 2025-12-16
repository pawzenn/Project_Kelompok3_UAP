import 'package:get/get.dart';

import '../../core/local/local_prefs_services.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository;

  ProfileController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final isLoading = false.obs;
  final profile = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final data = await _authRepository.getCurrentProfile();
      profile.value = data;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    await LocalPrefsService.clearOnLogout();
    Get.offAllNamed(AppRoutes.login);
  }
}
