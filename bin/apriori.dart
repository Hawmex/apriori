import 'dart:convert';
import 'dart:io';

import 'package:apriori/apriori.dart';

void main(final List<String> arguments) {
  const decoder = JsonEncoder.withIndent('  ');

  final rules = <Map<String, dynamic>>[];

  final optionsFilePath = arguments.single;
  final optionsFile = File(optionsFilePath);
  final rawOptions = optionsFile.readAsStringSync();
  final options = Options.fromJson(jsonDecode(rawOptions));

  final transactionsFilePath =
      '${optionsFile.parent.path}/${options.transactionsPath}';

  final transactionsFile = File(transactionsFilePath);
  final rawTransactions = transactionsFile.readAsStringSync();
  final transactions = jsonDecode(rawTransactions);

  final apriori = Apriori(
    transactions: (transactions as List)
        .map((final transaction) => (transaction as List).cast<String>())
        .toList(),
    minSupport: options.minSupport,
    minConfidence: options.minConfidence,
    maxAntecedentsLength: options.maxAntecedentsLength,
  );

  for (final rule in apriori.rules) {
    final currentRule = <String, dynamic>{};

    rule.forEach((final key, final value) {
      currentRule[key] = value is Set ? value.toList() : value;
    });

    rules.add(currentRule);
  }

  rules.sort(
    (final a, final b) =>
        (b['lift'] as double).compareTo((a['lift'] as double)),
  );

  final outputFilePath = '${arguments[0]}/../${options.rulesPath}';
  final outputFile = File(outputFilePath);

  outputFile.writeAsStringSync(decoder.convert(rules));
}
