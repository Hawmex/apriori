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

  Options.fromJson(final Map<String, dynamic> json)
      : transactionsPath = json['transactionsPath'] as String,
        rulesPath = json['rulesPath'] as String,
        minSupport = json['minSupport'] as double,
        minConfidence = json['minConfidence'] as double,
        maxAntecedentsLength = json['maxAntecedentsLength'] as int?;
}
