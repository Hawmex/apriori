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
      : transactionsPath = json['transactionsPath'],
        rulesPath = json['rulesPath'],
        minSupport = json['minSupport'],
        minConfidence = json['minConfidence'],
        maxAntecedentsLength = json['maxAntecedentsLength'];
}
