import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/anamnesis_result.dart';

class CSVExporter {
  Future<void> exportResults(List<AnamnesisResult> results) async {
    try {
      // Create CSV data
      List<List<String>> csvData = [
        ['Question ID', 'Question Text', 'Answer'], // Headers
      ];

      for (final result in results) {
        csvData.add([
          result.linkId,
          result.questionText,
          result.answer,
        ]);
      }

      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);

      // Get temporary directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/anamnesis_report.csv');

      // Write CSV file
      await file.writeAsString(csvString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Anamnese Auswertung',
        subject: 'Anamnese Report - ${DateTime.now().toString().split(' ')[0]}',
      );
    } catch (e) {
      throw Exception('Fehler beim CSV-Export: ${e.toString()}');
    }
  }
}