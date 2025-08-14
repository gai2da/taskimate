import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String> getTemporaryPath() async {
    return '/tmp';
  }

  @override
  Future<String> getApplicationDocumentsPath() async {
    return '/tmp';
  }

  @override
  Future<String> getApplicationSupportPath() async {
    return '/tmp';
  }
}
