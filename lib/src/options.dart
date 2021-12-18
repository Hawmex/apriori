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

  Options.fromDecodedJson(Map<String, dynamic> data)
      : transactionsPath = data['transactionsPath'],
        rulesPath = data['rulesPath'],
        minSupport = data['minSupport'],
        minConfidence = data['minConfidence'],
        maxAntecedentsLength = data['maxAntecedentsLength'];
}
