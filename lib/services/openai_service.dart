import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/anamnesis_result.dart';
// import '../data/questionnaire_data.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  String? get _apiKey => dotenv.env['OPENAI_API_KEY'];

  Future<List<AnamnesisResult>> analyzeTranscript(
    String transcript,
    Map<String, dynamic> questionnaire,
  ) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('OpenAI API Key nicht gefunden. Bitte überprüfen Sie die .env Datei.');
    }

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final userMessage = '''Bitte analysiere, welche Fragen aus dem JSON ausgewertet wurden und was die Antworten sind. Für einige Fragen gibt das JSON eine Reihe von Antwortmöglichkeiten vor. In diesem Fall wähle eine der Antworten aus. Gebe deine Antworten als ein einfaches JSON file zurück, das eine Liste enthält mit jeweils der linkId der Frage und deine Antwort. Gebe keine weitere Begründung für deine Antwort.

Transcript:
$transcript

Questionnaire:
${jsonEncode(questionnaire)}''';

    final body = {
      'model': 'gpt-4-turbo',
      'messages': [
        {
          'role': 'system',
          'content': 'Du bist eine ausgebildete Pflegekraft in einem Krankenhaus. Insbesondere bist Du darin ausgebildet Patienten während einer Anamnese zu befragen.'
        },
        {
          'role': 'user',
          'content': userMessage
        }
      ],
      'temperature': 0.3,
      'max_tokens': 2000,
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
       
        
        return _parseApiResponse(content, questionnaire);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('API Fehler (${response.statusCode}): ${errorData['error']['message']}');
      }
    } catch (e) {
      if (e.toString().contains('API Fehler')) {
        rethrow;
      }
      throw Exception('Netzwerkfehler: ${e.toString()}');
    }
  }

  List<AnamnesisResult> _parseApiResponse(
    String content,
    Map<String, dynamic> questionnaire,
  ) {
    try {
      //  print('OpenAI API Content: $content');     // for debugging
      // Extract JSON from the content (sometimes GPT wraps it in markdown)
      String jsonString = content.trim();
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }
      jsonString = jsonString.trim();

      final responseData = jsonDecode(jsonString);
      final List<AnamnesisResult> results = [];

      if (responseData is List) {
        for (final item in responseData) {
          if (item is Map<String, dynamic> && 
              item.containsKey('linkId') && 
              item.containsKey('answer')) {
            
            final linkId = item['linkId'].toString();
            final answer = item['answer'].toString();
            final questionText = _findQuestionText(linkId, questionnaire);
            
            results.add(AnamnesisResult(
              linkId: linkId,
              questionText: questionText,
              answer: answer,
            ));
          }
        }
      }

      if (results.isEmpty) {
        throw Exception('Keine gültigen Antworten in der API-Antwort gefunden');
      }

      return results;
    } catch (e) {
      throw Exception('Fehler beim Parsen der API-Antwort: ${e.toString()}');
    }
  }

   // UPDATED METHOD: _findQuestionText
  String _findQuestionText(String linkId, Map<String, dynamic> questionnaire) {
    // Correctly access the 'items' array within the nested structure
    // questionnaire -> 'properties' -> 'item' -> 'items' (which is the array of questions)
    final List<dynamic>? items = questionnaire['properties']?['item']?['items'];

    if (items != null) {
      for (var item in items) {
        // Ensure the item is a Map and has the linkId
        if (item is Map<String, dynamic> && item['linkId'] == linkId) {
          // Return the 'text' field if it exists, otherwise a fallback message
          return item['text'] ?? 'Unbekannte Frage (Textfeld fehlt)';
        }
      }
    }
    // Fallback if the linkId is not found or structure is unexpected
    return 'Frage mit ID: $linkId';
  }
}