// lib/screens/anamnesis_screen.dart
import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import '../models/anamnesis_result.dart';
import '../utils/csv_exporter.dart';
// Correct import: now importing the QuestionnaireService class
import '../data/questionnaire_data.dart';

class AnamnesisScreen extends StatefulWidget {
  // FIX: use_key_in_widget_constructors
  // Added 'super.key' to the constructor for proper widget identification and state management.
  const AnamnesisScreen({super.key});

  @override
    // FIX: library_private_types_in_public_api
  // Ignored this lint here as it's a standard Flutter pattern to have a private State class
  // for a public StatefulWidget. The State class (_AnamnesisScreenState) is intentionally
  // private to the library, but its type is exposed by createState().
  // ignore: library_private_types_in_public_api
  _AnamnesisScreenState createState() => _AnamnesisScreenState();
}

class _AnamnesisScreenState extends State<AnamnesisScreen> {
  final TextEditingController _transcriptController = TextEditingController();
  final OpenAIService _openAIService = OpenAIService();
  final CSVExporter _csvExporter = CSVExporter();
  // Instantiate QuestionnaireService here
  final QuestionnaireService _questionnaireService = QuestionnaireService();

  List<AnamnesisResult> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _analyzeTranscript() async {
    if (_transcriptController.text.trim().isEmpty) {
      _showSnackBar('Bitte geben Sie ein Transkript ein.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _results.clear();
    });

    try {
      // Call the loadQuestionnaire method on the instance of QuestionnaireService
      final Map<String, dynamic> loadedQuestionnaire =
          await _questionnaireService.loadQuestionnaire();

      final results = await _openAIService.analyzeTranscript(
        _transcriptController.text.trim(),
        loadedQuestionnaire, // Pass the loaded Map here
      );

      setState(() {
        _results = results;
        _isLoading = false;
      });

      _showSnackBar('Analyse erfolgreich abgeschlossen!');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Fehler bei der Analyse: ${e.toString()}';
      });
      _showSnackBar(_errorMessage!);
    }
  }

  Future<void> _exportToCsv() async {
    if (_results.isEmpty) {
      _showSnackBar('Keine Ergebnisse zum Exportieren vorhanden.');
      return;
    }

    try {
      await _csvExporter.exportResults(_results);
      _showSnackBar('CSV-Datei erfolgreich geteilt!');
    } catch (e) {
      _showSnackBar('Fehler beim Export: ${e.toString()}');
      print('Fehler beim Export: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // FIX: prefer_const_constructors
        // Added 'const' as Text is immutable.
        title: const Text('AI Anamnese Dokumentation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _isLoading ? null : _analyzeTranscript,
            tooltip: 'Analysieren',
          ),
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _exportToCsv,
              tooltip: 'Als CSV teilen',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Transcript Input Field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patienten-Interview Transkript',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _transcriptController,
                        maxLines: null, // Allows for multi-line input
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: 'Transkript hier einfügen...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(12),
                        ),
                        minLines: 5,
                      ),
                    ],
                  ),
                ),
              ),
               // FIX: prefer_const_constructors
               // Added 'const' as SizedBox is immutable.
              const SizedBox(height: 16),

              // Analyze Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _analyzeTranscript,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.analytics),
                label: Text(_isLoading ? 'Analysiere...' : 'Transkript analysieren'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              const SizedBox(height: 16),

              // Results Section
              _buildResultsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_isLoading) {
      // FIX: prefer_const_constructors, prefer_const_literals_to_create_immutables
      // Added 'const' to Center, Column, CircularProgressIndicator, SizedBox, Text.
      
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analysiere Transkript...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _analyzeTranscript,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Keine Ergebnisse vorhanden',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Fügen Sie ein Transkript ein und klicken Sie auf "Analysieren"',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Analyseergebnisse (${_results.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: _exportToCsv,
              icon: const Icon(Icons.file_download),
              label: const Text('CSV Export'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final result = _results[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.questionText,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result.answer,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${result.linkId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}