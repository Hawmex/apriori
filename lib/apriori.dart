class Apriori {
  final List<List<String>> transactions;
  final double minSupport;
  final double minConfidence;

  final int? maxAntecedentsLength;

  final Set<String> items;
  final Map<Set<String>, double> supports = {};
  final Set<Map<String, dynamic>> rules = {};

  Apriori({
    required this.transactions,
    required this.minSupport,
    required this.minConfidence,
    this.maxAntecedentsLength,
  }) : items = transactions.expand((transaction) => transaction).toSet() {
    int currentItemsetsLength = 1;

    for (currentItemsetsLength;
        currentItemsetsLength <
            (maxAntecedentsLength != null
                ? maxAntecedentsLength! + 2
                : items.length + 1);
        currentItemsetsLength++) {
      final Set<Set<String>> itemsets = _getItemsets(
        items: currentItemsetsLength == 1
            ? items
            : supports.keys
                .where((itemset) => itemset.length == currentItemsetsLength - 1)
                .expand((itemset) => itemset)
                .toSet(),
        length: currentItemsetsLength,
      );

      for (final Set<String> itemset in itemsets) {
        final double support = _getSupport(itemset);

        if (support >= minSupport) supports[itemset] = support;
      }

      if (!supports.keys.any(
        (itemset) => itemset.length == currentItemsetsLength,
      )) break;
    }

    currentItemsetsLength -= 1;

    final Set<Set<String>> finalItemsets = supports.keys
        .where((itemset) => itemset.length == currentItemsetsLength)
        .toSet();

    for (final Set<String> finalItemset in finalItemsets) {
      final Set<Set<String>> allAntecedents = supports.keys
          .where(
            (itemset) =>
                itemset.length < finalItemset.length &&
                itemset.every(finalItemset.contains),
          )
          .toSet();

      for (final Set<String> antecedents in allAntecedents) {
        final Set<String> consequents = supports.keys.singleWhere(
          (itemset) =>
              itemset.length == finalItemset.length - antecedents.length &&
              finalItemset.every(itemset.union(antecedents).contains),
        );

        final double confidence = _getConfidence(
          finalItemset: finalItemset,
          antecedents: antecedents,
        );

        final double lift = _getLift(
          confidence: confidence,
          consequents: consequents,
        );

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
  }

  Set<Set<String>> _getItemsets({
    required Set<String> items,
    required int length,
  }) {
    if (items.length == length) {
      return {items};
    } else if (length == 0) {
      return {{}};
    } else {
      final Set<String> remainedItems = {...items};
      final Set<Set<String>> itemsets = {};

      for (final String item in items) {
        remainedItems.remove(item);

        final Set<Set<String>> smallerItemsets =
            _getItemsets(items: remainedItems, length: length - 1);

        for (final Set<String> smallerItemset in smallerItemsets) {
          itemsets.add({item, ...smallerItemset});
        }
      }

      return itemsets;
    }
  }

  double _getSupport(Set<String> itemset) {
    final List<List<String>> transactionsContainingItemset = transactions
        .where((transaction) => itemset.every(transaction.contains))
        .toList();

    return transactionsContainingItemset.length / transactions.length;
  }

  double _getConfidence({
    required Set<String> finalItemset,
    required Set<String> antecedents,
  }) =>
      supports[finalItemset]! / supports[antecedents]!;

  double _getLift({
    required double confidence,
    required Set<String> consequents,
  }) =>
      confidence / supports[consequents]!;
}
