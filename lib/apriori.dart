import 'dart:developer';

class Apriori {
  final int _start = (Timeline.now / 1000).round();

  final List<List<String>> transactions;
  final double minSupport;
  final double minConfidence;
  final int? maxAntecedentsLength;
  final bool logger;

  final Set<String> items;
  final Map<Set<String>, double> supports = {};
  final Set<Map<String, dynamic>> rules = {};

  Apriori({
    required this.transactions,
    required this.minSupport,
    required this.minConfidence,
    this.maxAntecedentsLength,
    this.logger = false,
  }) : items = transactions.expand((transaction) => transaction).toSet() {
    if (logger) print('Extracted items from transactions...');

    int maxLength = 1;

    for (; maxLength <= items.length; maxLength++) {
      final Set<Set<String>> itemsets = _getItemsets(
        items: maxLength == 1
            ? items
            : supports.keys
                .where((itemset) => itemset.length == maxLength - 1)
                .expand((itemset) => itemset)
                .toSet(),
        length: maxLength,
      );

      for (final Set<String> itemset in itemsets) {
        final double support = _getSupport(itemset);

        if (support >= minSupport) supports[itemset] = support;
      }

      final bool shouldBreak = !supports.keys.any(
        (itemset) => itemset.length == maxLength,
      );

      if (shouldBreak) break;
    }

    maxLength -= 1;

    final Set<Set<String>> finalItemsets = supports.keys
        .where(
          (itemset) => itemset.length == maxLength,
        )
        .toSet();

    if (logger) print('Calculated common itemsets of items...');

    for (final Set<String> finalItemset in finalItemsets) {
      final Set<Set<String>> allAntecedents = supports.keys
          .where(
            (itemset) =>
                itemset.length <=
                    (maxAntecedentsLength ?? finalItemset.length - 1) &&
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

    if (logger) {
      print('Generated valid association rules from common itemsets...');
      print('Done in ${(Timeline.now / 1000).round() - _start}ms!');
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

        final Set<Set<String>> smallerItemsets = _getItemsets(
          items: remainedItems,
          length: length - 1,
        );

        for (final Set<String> smallerItemset in smallerItemsets) {
          itemsets.add({item, ...smallerItemset});
        }
      }

      return itemsets;
    }
  }

  double _getSupport(Set<String> itemset) {
    final List<List<String>> transactionsContainingItemset = transactions
        .where(
          (transaction) => itemset.every(transaction.contains),
        )
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
