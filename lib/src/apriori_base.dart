import 'dart:developer';

class Apriori {
  final int _startTime = (Timeline.now / 1000).round();

  final List<List<String>> transactions;
  final double minSupport;
  final double minConfidence;
  final int? maxAntecedentsLength;
  final bool log;

  final Set<String> items;
  final Map<Set<String>, double> supports = {};
  final Set<Map<String, dynamic>> rules = {};

  Apriori({
    required this.transactions,
    required this.minSupport,
    required this.minConfidence,
    this.maxAntecedentsLength,
    this.log = false,
  }) : items = transactions.expand((final transaction) => transaction).toSet() {
    if (log) print('Extracted ${items.length} items.');

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

      for (final itemset in itemsets) {
        final support = _getSupport(itemset);

        if (support >= minSupport) supports[itemset] = support;
      }

      final shouldBreak =
          !supports.keys.any((final itemset) => itemset.length == maxLength);

      if (shouldBreak) break;
    }

    maxLength -= 1;

    final finalItemsets = supports.keys
        .where((final itemset) => itemset.length == maxLength)
        .toSet();

    if (log) print('Calculated ${finalItemsets.length} common itemsets.');

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

        final lift = _getLift(
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

    if (log) {
      print('Generated ${rules.length} association rules.');
      print('Done in ${(Timeline.now / 1000).round() - _startTime}ms!');
    }
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
