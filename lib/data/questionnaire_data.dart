import 'dart:convert'; // Required for json.decode
import 'package:flutter/services.dart' show rootBundle; // Required for rootBundle

/// A service class to load the questionnaire data from a JSON asset file.
class QuestionnaireService {
  /// The path to the JSON questionnaire file within the assets.
  static const String _questionnairePath =
      'assets/data/2025-03-26 NursIT Anamnesis FHIR Questionnaire with detailed descriptions.json';

  /// Loads and parses the questionnaire data from the JSON asset.
  ///
  /// Returns a [Future] that completes with a [Map<String, dynamic>]
  /// representing the parsed questionnaire data.
  /// Throws an [Exception] if the file cannot be loaded or parsed.
  Future<Map<String, dynamic>> loadQuestionnaire() async {
    try {
      // Load the JSON string from the asset file
      String jsonString = await rootBundle.loadString(_questionnairePath);

      // Parse the JSON string into a Dart Map
      Map<String, dynamic> questionnaireData = json.decode(jsonString);

      return questionnaireData;
    } catch (e) {
      // Print the error for debugging purposes
      // print('Error loading questionnaire: $e');     // for debugging
      // Re-throw the exception or return a default/empty map as appropriate for your app
      throw Exception('Failed to load questionnaire: $e');
    }
  }
}