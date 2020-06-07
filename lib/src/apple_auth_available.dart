import 'package:apple_sign_in/apple_sign_in.dart';

class AppleAuthAvailable {
  final bool isAvailable;

  AppleAuthAvailable(this.isAvailable);

  static Future<AppleAuthAvailable> check() async {
    return AppleAuthAvailable(await AppleSignIn.isAvailable());
  }
}
