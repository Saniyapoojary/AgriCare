import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Native FFI implementation for TFLite Interpreter (Android, iOS, Windows, macOS, Linux)
class AppTFLiteInterpreter {
  final Interpreter _interpreter;

  AppTFLiteInterpreter._(this._interpreter);

  static Future<AppTFLiteInterpreter?> loadModel(String assetPath) async {
    try {
      final interpreter = await Interpreter.fromAsset(assetPath);
      return AppTFLiteInterpreter._(interpreter);
    } catch (e) {
      debugPrint('Native TFLite asset load exception: $e');
      return null;
    }
  }

  /// Runs a single image classification pass.
  ///
  /// [pixels] is a flat, row-major RGB float buffer already normalized to
  /// [0, 1], of length [inputSize] * [inputSize] * 3. Returns the raw
  /// softmax output of length [numClasses].
  List<double> classify(List<double> pixels, int inputSize, int numClasses) {
    final input = [
      List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final base = (y * inputSize + x) * 3;
            return [pixels[base], pixels[base + 1], pixels[base + 2]];
          },
        ),
      ),
    ];
    final output = [List<double>.filled(numClasses, 0)];
    _interpreter.run(input, output);
    return output[0];
  }
}
