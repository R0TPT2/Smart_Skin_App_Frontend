import 'dart:io';
import 'dart:math' as math;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class SkinLesionAnalyzer {
  Interpreter? _applicabilityModel;
  Interpreter? _primaryModel;
  Interpreter? _benignModel;
  Interpreter? _malignantModel;
  bool _modelsLoaded = false;

  static const String _applicabilityModelPath = 'assests/models/applicability_model.tflite';
  static const String _primaryModelPath = 'assests/models/First_Diagnosis.tflite';
  static const String _benignModelPath = 'assests/models/Benign_Diagnosis.tflite';
  static const String _malignantModelPath = 'assests/models/Maliganant_Diagnosis.tflite';

  Future<void> loadModels() async {
    if (_modelsLoaded) return;
    try {
      _applicabilityModel = await Interpreter.fromAsset(_applicabilityModelPath);
      _primaryModel = await Interpreter.fromAsset(_primaryModelPath);
      _benignModel = await Interpreter.fromAsset(_benignModelPath);
      _malignantModel = await Interpreter.fromAsset(_malignantModelPath);
      _modelsLoaded = true;
      print("Models loaded successfully!");
    } catch (e) {
      print("Error loading models: $e");
      rethrow;
    }
  }

  void resetInterpreters() {
    try {
      _applicabilityModel?.close();
      _primaryModel?.close();
      _benignModel?.close();
      _malignantModel?.close();
      _applicabilityModel = null;
      _primaryModel = null;
      _benignModel = null;
      _malignantModel = null;
      _modelsLoaded = false;
      print("Interpreters successfully reset and closed");
    } catch (e) {
      print("Error resetting interpreters: $e");
    }
  }

  double _sigmoid(double x) {
    return 1.0 / (1.0 + math.exp(-x));
  }

  List<double> _softmax(List<double> logits) {
    double maxLogit = logits.reduce(math.max);
    List<double> expShifted = logits.map((x) => math.exp(x - maxLogit)).toList();
    double sumExp = expShifted.reduce((a, b) => a + b);
    return expShifted.map((expVal) => expVal / sumExp).toList();
  }

  Future<Map<String, dynamic>> analyze(File imageFile) async {
    if (!_modelsLoaded) await loadModels();
    Map<String, dynamic> result;
    try {
      var preprocessedImage = _preprocessImage(imageFile);
      var appInputShape = _applicabilityModel!.getInputTensor(0).shape;
      var appInput = _reshapeImageToModel(preprocessedImage, appInputShape);
      var appOutputTensor = _applicabilityModel!.getOutputTensor(0);
      var appOutputShape = appOutputTensor.shape;
      var appOutput = List<dynamic>.filled(appOutputShape.reduce((a, b) => a * b), 0.0).reshape(appOutputShape);
      _applicabilityModel!.run(appInput, appOutput);
      double logitValue = _extractScalar(appOutput);
      double applicabilityScore = _sigmoid(logitValue);
      print("Applicability logit: $logitValue, probability: $applicabilityScore");
      bool isApplicable = applicabilityScore > 0.7;
      if (!isApplicable) {
        result = {
          'status': 'error',
          'message': 'Image not suitable for skin lesion analysis',
          'applicability_score': applicabilityScore
        };
        return result;
      }
      var primaryInputShape = _primaryModel!.getInputTensor(0).shape;
      var primaryInput = _reshapeImageToModel(preprocessedImage, primaryInputShape);
      var primaryOutputShape = _primaryModel!.getOutputTensor(0).shape;
      var primaryOutput = List<dynamic>.filled(primaryOutputShape.reduce((a, b) => a * b), 0.0).reshape(primaryOutputShape);
      _primaryModel!.run(primaryInput, primaryOutput);
      double primaryLogit = _extractScalar(primaryOutput);
      double primaryScore = _sigmoid(primaryLogit);
      print("Primary logit: $primaryLogit, probability: $primaryScore");
      bool isMalignant = primaryScore > 0.526;
      if (isMalignant) {
        var malInputShape = _malignantModel!.getInputTensor(0).shape;
        var malInput = _reshapeImageToModel(preprocessedImage, malInputShape);
        var malOutputShape = _malignantModel!.getOutputTensor(0).shape;
        var malOutput = List<dynamic>.filled(malOutputShape.reduce((a, b) => a * b), 0.0).reshape(malOutputShape);
        _malignantModel!.run(malInput, malOutput);
        var logits = _flattenOutput(malOutput);
        var probabilities = _softmax(logits);
        print("Malignant model outputs (after softmax): $probabilities");
        var parsedResult = _parseMalignant(probabilities);
        int priority = _calculatePriority(isMalignant, primaryScore, parsedResult['max_score']);
        result = {
          'status': 'success',
          'diagnosis': 'MALIGNANT',
          'primary_score': primaryScore,
          'secondary_score': parsedResult['max_score'],
          'lesion_type': parsedResult['class'],
          'priority': priority,
          'all_probabilities': parsedResult['all_probabilities'],
          'applicability_score': applicabilityScore
        };
      } else {
        var benInputShape = _benignModel!.getInputTensor(0).shape;
        var benInput = _reshapeImageToModel(preprocessedImage, benInputShape);
        var benOutputShape = _benignModel!.getOutputTensor(0).shape;
        var benOutput = List<dynamic>.filled(benOutputShape.reduce((a, b) => a * b), 0.0).reshape(benOutputShape);
        _benignModel!.run(benInput, benOutput);
        var logits = _flattenOutput(benOutput);
        var probabilities = _softmax(logits);
        print("Benign model outputs (after softmax): $probabilities");
        var parsedResult = _parseBenign(probabilities);
        int priority = _calculatePriority(isMalignant, primaryScore, parsedResult['max_score']);
        result = {
          'status': 'success',
          'diagnosis': 'BENIGN',
          'primary_score': primaryScore,
          'secondary_score': parsedResult['max_score'],
          'lesion_type': parsedResult['class'],
          'priority': priority,
          'all_probabilities': parsedResult['all_probabilities'],
          'applicability_score': applicabilityScore
        };
      }
      return result;
    } finally {
      resetInterpreters();
    }
  }

  double _extractScalar(dynamic output) {
    if (output is List) {
      if (output.isEmpty) {
        return 0.0;
      } else if (output.first is List) {
        return _extractScalar(output.first);
      } else if (output.first is num) {
        return output.first.toDouble();
      }
    } else if (output is num) {
      return output.toDouble();
    }
    return 0.0;
  }

  List<double> _flattenOutput(dynamic output) {
    if (output is List) {
      if (output.isEmpty) {
        return [];
      } else if (output.first is List) {
        return _flattenOutput(output.first);
      } else if (output.first is num) {
        return output.map<double>((value) => value.toDouble()).toList();
      }
    }
    return [0.0];
  }

  int _calculatePriority(bool isMalignant, double primaryScore, double secondaryScore) {
    if (isMalignant) {
      if (primaryScore > 0.75 && secondaryScore > 0.6) {
        return 2;
      } else {
        return 1;
      }
    } else {
      if (primaryScore > 0.4) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  img.Image _preprocessImage(File imageFile) {
    try {
      img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
      if (image == null) throw Exception('Failed to decode image');
      image = img.adjustColor(
        image,
        contrast: 1.1,
        saturation: 1.1,
      );
      return image;
    } catch (e) {
      print("Error preprocessing image: $e");
      rethrow;
    }
  }

  List<List<List<List<double>>>> _reshapeImageToModel(img.Image image, List<int> targetShape) {
    int height = targetShape[1];
    int width = targetShape[2];
    img.Image resized = img.copyResize(image, width: width, height: height);
    List<List<List<List<double>>>> input = List.generate(
      targetShape[0],
      (batch) => List.generate(
        height,
        (y) => List.generate(
          width,
          (x) => List.generate(
            targetShape[3],
            (c) {
              final pixel = resized.getPixel(x, y);
              return pixel[c] / 255.0;
            },
          ),
        ),
      ),
    );
    return input;
  }

  Map<String, dynamic> _parseMalignant(List<double> outputs) {
    List<String> classes = [
      'actinic keratosis',
      'basal cell carcinoma',
      'melanoma',
      'squamous cell carcinoma'
    ];
    double maxScore = 0.0;
    int maxIndex = 0;
    for (int i = 0; i < outputs.length && i < classes.length; i++) {
      if (outputs[i] > maxScore) {
        maxScore = outputs[i];
        maxIndex = i;
      }
    }
    Map<String, double> allProbabilities = {};
    for (int i = 0; i < outputs.length && i < classes.length; i++) {
      allProbabilities[classes[i]] = outputs[i];
    }
    return {
      'class': classes[maxIndex],
      'max_score': maxScore,
      'all_probabilities': allProbabilities
    };
  }

  Map<String, dynamic> _parseBenign(List<double> outputs) {
    List<String> classes = [
      'dermatofibroma',
      'nevus',
      'pigmented benign keratosis',
      'seborrheic keratosis',
      'solar lentigo',
      'vascular lesion'
    ];
    double maxScore = 0.0;
    int maxIndex = 0;
    for (int i = 0; i < outputs.length && i < classes.length; i++) {
      if (outputs[i] > maxScore) {
        maxScore = outputs[i];
        maxIndex = i;
      }
    }
    Map<String, double> allProbabilities = {};
    for (int i = 0; i < outputs.length && i < classes.length; i++) {
      allProbabilities[classes[i]] = outputs[i];
    }
    return {
      'class': classes[maxIndex],
      'max_score': maxScore,
      'all_probabilities': allProbabilities
    };
  }
}