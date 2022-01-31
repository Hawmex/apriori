class Options {
  final String transactionsPath;
  final String rulesPath;

  final double minSupport;
  final double minConfidence;
  final int? maxAntecedentsLength;

  const Options({
    required this.transactionsPath,
    required this.rulesPath,
    required this.minSupport,
    required this.minConfidence,
    this.maxAntecedentsLength,
  });

  factory Options.fromJson(final Map<String, dynamic> json) {
    return Options(
      transactionsPath: json['transactionsPath'],
      rulesPath: json['rulesPath'],
      minSupport: json['minSupport'],
      minConfidence: json['minConfidence'],
    );
  }
}
