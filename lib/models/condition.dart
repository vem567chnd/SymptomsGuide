class Condition {
  final String id;
  final String name;
  final String bodyPart;
  final String description;
  final List<String> symptoms;
  final List<String> recommendations;
  final String imageUrl;
  final String severity; // 'mild', 'moderate', 'severe'
  final int consensusScore; // 1–5
  final List<String> sources;

  const Condition({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.description,
    required this.symptoms,
    required this.recommendations,
    required this.imageUrl,
    required this.severity,
    required this.consensusScore,
    required this.sources,
  });

  String get consensusLabel {
    switch (consensusScore) {
      case 5: return 'WHO / ICD Standard';
      case 4: return 'Clinically Established';
      case 3: return 'Broadly Accepted';
      case 2: return 'Commonly Reported';
      default: return 'Anecdotal';
    }
  }
}

class BodyPart {
  final String id;
  final String name;
  final String emoji;
  final List<Condition> conditions;

  const BodyPart({
    required this.id,
    required this.name,
    required this.emoji,
    required this.conditions,
  });
}
