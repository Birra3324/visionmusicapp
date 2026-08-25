class MusicAssistantResult {
  final String productionPrompt;
  final List<String> arrangement;
  final List<String> instrumentation;
  final String productionDirection;

  const MusicAssistantResult({
    required this.productionPrompt,
    required this.arrangement,
    required this.instrumentation,
    required this.productionDirection,
  });

  factory MusicAssistantResult.fromJson(Map<String, dynamic> json) {
    return MusicAssistantResult(
      productionPrompt:
          (json['productionPrompt'] as String?)?.trim() ?? '',
      arrangement: _toStringList(json['arrangement']),
      instrumentation: _toStringList(json['instrumentation']),
      productionDirection:
          (json['productionDirection'] as String?)?.trim() ?? '',
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  bool get isValid =>
      productionPrompt.isNotEmpty &&
      arrangement.isNotEmpty &&
      instrumentation.isNotEmpty;
}
