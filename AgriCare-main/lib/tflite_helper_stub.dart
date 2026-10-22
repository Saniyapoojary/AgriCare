import 'package:flutter/foundation.dart';

/// Web/Non-FFI stub implementation for TFLite Interpreter
class AppTFLiteInterpreter {
  static Future<AppTFLiteInterpreter?> loadModel(String assetPath) async {
    debugPrint('Web/Non-FFI platform active: TFLite native binary skipped, fallback engine running.');
    return null;
  }

  /// Never called: [loadModel] always returns null on this platform, so no
  /// instance exists to call [classify] on.
  List<double> classify(List<double> pixels, int inputSize, int numClasses) {
    throw UnsupportedError('TFLite inference is not available on this platform.');
  }
}
