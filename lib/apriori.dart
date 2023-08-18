library;

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

  Options.fromJson(final dynamic json)
      : transactionsPath = json['transactionsPath'] as String,
        rulesPath = json['rulesPath'] as String,
        minSupport = json['minSupport'] as double,
        minConfidence = json['minConfidence'] as double,
        maxAntecedentsLength = json['maxAntecedentsLength'] as int?;
}

class Apriori {
  final List<List<String>> transactions;
  final double minSupport;
  final double minConfidence;
  final int? maxAntecedentsLength;

  late final items =
      transactions.expand((final transaction) => transaction).toSet();

  final supports = <Set<String>, double>{};
  final rules = <Map<String, dynamic>>{};

  Apriori({
    required this.transactions,
    required this.minSupport,
    required this.minConfidence,
    this.maxAntecedentsLength,
  }) {
    final stopwatch = Stopwatch()..start();

    print('Extracted ${items.length} items.');

    int maxLength = 1;

    for (; maxLength <= items.length; maxLength++) {
      final itemsets = _getItemsets(
        items: maxLength == 1
            ? items
            : supports.keys
                .where((final itemset) => itemset.length == maxLength - 1)
                .expand((final itemset) => itemset)
                .toSet(),
        length: maxLength,
      );

      final newSupports = <Set<String>, double>{};

      for (final itemset in itemsets) {
        final support = _getSupport(itemset);

        if (support >= minSupport) newSupports[itemset] = support;
      }

      supports.addAll(newSupports);

      if (newSupports.isEmpty) break;
    }

    maxLength -= 1;

    final finalItemsets = supports.keys
        .where((final itemset) => itemset.length == maxLength)
        .toSet();

    print('Calculated ${finalItemsets.length} common itemsets.');

    for (final finalItemset in finalItemsets) {
      final allAntecedents = supports.keys
          .where(
            (final itemset) =>
                itemset.length <=
                    (maxAntecedentsLength ?? finalItemset.length - 1) &&
                itemset.every(finalItemset.contains),
          )
          .toSet();

      for (final antecedents in allAntecedents) {
        final consequents = supports.keys.singleWhere(
          (final itemset) =>
              itemset.length == finalItemset.length - antecedents.length &&
              finalItemset.every(itemset.union(antecedents).contains),
        );

        final confidence = _getConfidence(
          finalItemset: finalItemset,
          antecedents: antecedents,
        );

        final lift = _getLift(confidence: confidence, consequents: consequents);

        if (confidence >= minConfidence && lift > 1) {
          rules.add({
            'antecedents': antecedents,
            'consequents': consequents,
            'confidence': confidence,
            'lift': lift
          });
        }
      }
    }

    stopwatch.stop();

    print(
      'Generated ${rules.length} association rules.\n'
      'Done in ${stopwatch.elapsedMilliseconds}ms!',
    );
  }

  Set<Set<String>> _getItemsets({
    required final Set<String> items,
    required final int length,
  }) {
    if (items.length == length) {
      return {items};
    } else if (length == 0) {
      return {{}};
    } else {
      final remainedItems = {...items};
      final itemsets = <Set<String>>{};

      for (final item in items) {
        remainedItems.remove(item);

        final smallerItemsets =
            _getItemsets(items: remainedItems, length: length - 1);

        for (final smallerItemset in smallerItemsets) {
          itemsets.add({item, ...smallerItemset});
        }
      }

      return itemsets;
    }
  }

  double _getSupport(final Set<String> itemset) {
    final transactionsContainingItemset = transactions
        .where((final transaction) => itemset.every(transaction.contains))
        .toList();

    return transactionsContainingItemset.length / transactions.length;
  }

  double _getConfidence({
    required final Set<String> finalItemset,
    required final Set<String> antecedents,
  }) =>
      supports[finalItemset]! / supports[antecedents]!;

  double _getLift({
    required final double confidence,
    required final Set<String> consequents,
  }) =>
      confidence / supports[consequents]!;
}
