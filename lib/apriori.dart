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
    if (logger) print('Extracted ${items.length} items.');

    int maxLength = 1;

    for (; maxLength <= items.length; maxLength++) {
      final itemsets = _getItemsets(
        items: maxLength == 1
            ? items
            : supports.keys
                .where((itemset) => itemset.length == maxLength - 1)
                .expand((itemset) => itemset)
                .toSet(),
        length: maxLength,
      );

      for (final itemset in itemsets) {
        final support = _getSupport(itemset);

        if (support >= minSupport) supports[itemset] = support;
      }

      final shouldBreak = !supports.keys.any(
        (itemset) => itemset.length == maxLength,
      );

      if (shouldBreak) break;
    }

    maxLength -= 1;

    final finalItemsets =
        supports.keys.where((itemset) => itemset.length == maxLength).toSet();

    if (logger) print('Calculated ${finalItemsets.length} common itemsets.');

    for (final finalItemset in finalItemsets) {
      final allAntecedents = supports.keys
          .where(
            (itemset) =>
                itemset.length <=
                    (maxAntecedentsLength ?? finalItemset.length - 1) &&
                itemset.every(finalItemset.contains),
          )
          .toSet();

      for (final antecedents in allAntecedents) {
        final consequents = supports.keys.singleWhere(
          (itemset) =>
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

    if (logger) {
      print('Generated ${rules.length} association rules.');
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
      final remainedItems = {...items};
      final itemsets = <Set<String>>{};

      for (final item in items) {
        remainedItems.remove(item);

        final smallerItemsets = _getItemsets(
          items: remainedItems,
          length: length - 1,
        );

        for (final smallerItemset in smallerItemsets) {
          itemsets.add({item, ...smallerItemset});
        }
      }

      return itemsets;
    }
  }

  double _getSupport(Set<String> itemset) {
    final transactionsContainingItemset = transactions
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
