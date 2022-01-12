import 'dart:convert';
import 'dart:io';

import 'package:apriori/apriori.dart';
import 'package:apriori/src/options.dart';

void main(final List<String> arguments) {
  const decoder = JsonEncoder.withIndent('  ');

  final options = Options.fromJson(
    jsonDecode(
      File(arguments[0]).readAsStringSync(),
    ),
  );

  final rules = <Map<String, dynamic>>[];

  final transactionsRaw = File(
    '${arguments[0]}/../${options.transactionsPath}',
  ).readAsStringSync();

  final transactions = (jsonDecode(transactionsRaw) as List)
      .map((final transaction) => (transaction as List).cast<String>())
      .toList()
      .cast<List<String>>();

  final apriori = Apriori(
    transactions: transactions,
    minSupport: options.minSupport,
    minConfidence: options.minConfidence,
    maxAntecedentsLength: options.maxAntecedentsLength,
    log: true,
  );

  for (final rule in apriori.rules) {
    final currentRule = <String, dynamic>{};

    rule.forEach(
      (final key, final value) =>
          currentRule[key] = value is Set ? value.toList() : value,
    );

    rules.add(currentRule);
  }

  rules.sort((final a, final b) =>
      (b['lift'] as double).compareTo((a['lift'] as double)));

  File('${arguments[0]}/../${options.rulesPath}').writeAsStringSync(
    decoder.convert(rules),
  );
}
