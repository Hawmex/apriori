import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:apriori/apriori.dart';
import 'package:apriori/src/options.dart';

void main(List<String> arguments) {
  final int start = (Timeline.now / 1000).round();

  transformRules();
  sortRules();
  writeRules();

  final int end = (Timeline.now / 1000).round();

  print('Done in ${end - start}ms!');
}

final List<Map<String, dynamic>> rules = [];

final Options options = Options.fromDecodedJson(
  jsonDecode(File('./options.json').readAsStringSync()),
);

final List<List<String>> transactions =
    (jsonDecode(File(options.transactionsPath).readAsStringSync()) as List)
        .map((transaction) => (transaction as List).cast<String>())
        .toList()
        .cast<List<String>>();

final Apriori apriori = Apriori(
  transactions: transactions,
  minSupport: options.minSupport,
  minConfidence: options.minConfidence,
  maxAntecedentsLength: options.maxAntecedentsLength,
);

void transformRules() {
  for (final Map<String, dynamic> rule in apriori.rules) {
    final Map<String, dynamic> currentRule = {};

    rule.forEach(
      (key, value) {
        currentRule[key] = value is Set ? value.toList() : value;
      },
    );

    rules.add(currentRule);
  }
}

void sortRules() {
  rules.sort((a, b) => (b['lift'] as double).compareTo((a['lift'] as double)));
}

void writeRules() {
  File(options.rulesPath).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(rules),
  );
}
