class AnamnesisResult {
  final String linkId;
  final String questionText;
  final String answer;

  AnamnesisResult({
    required this.linkId,
    required this.questionText,
    required this.answer,
  });

  Map<String, dynamic> toMap() {
    return {
      'linkId': linkId,
      'questionText': questionText,
      'answer': answer,
    };
  }
}