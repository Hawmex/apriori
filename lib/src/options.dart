class Options {
  final String transactionsPath;
  final String rulesPath;

  final double minSupport;
  final double minConfidence;
  final int? maxAntecedentsLength;

  const Options({
    required final this.transactionsPath,
    required final this.rulesPath,
    required final this.minSupport,
    required final this.minConfidence,
    final this.maxAntecedentsLength,
  });

  Options.fromDecodedJson(final Map<String, dynamic> data)
      : transactionsPath = data['transactionsPath'],
        rulesPath = data['rulesPath'],
        minSupport = data['minSupport'],
        minConfidence = data['minConfidence'],
        maxAntecedentsLength = data['maxAntecedentsLength'];
}
