import 'dart:convert';
import 'dart:io';

import 'package:apriori/apriori.dart';
import 'package:apriori/src/options.dart';

void main(final List<String> arguments) {
  final Options options = Options.fromDecodedJson(
    jsonDecode(
      File(arguments[0]).readAsStringSync(),
    ),
  );

  final List<Map<String, dynamic>> rules = [];

  final List<List<String>> transactions = (jsonDecode(
    File('${arguments[0]}/../${options.transactionsPath}').readAsStringSync(),
  ) as List)
      .map((transaction) => (transaction as List).cast<String>())
      .toList()
      .cast<List<String>>();

  final Apriori apriori = Apriori(
    transactions: transactions,
    minSupport: options.minSupport,
    minConfidence: options.minConfidence,
    maxAntecedentsLength: options.maxAntecedentsLength,
    logger: true,
  );

  for (final Map<String, dynamic> rule in apriori.rules) {
    final Map<String, dynamic> currentRule = {};

    rule.forEach((key, value) {
      currentRule[key] = value is Set ? value.toList() : value;
    });

    rules.add(currentRule);
  }

  rules.sort((a, b) => (b['lift'] as double).compareTo((a['lift'] as double)));

  File('${arguments[0]}/../${options.rulesPath}').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(rules),
  );
}
