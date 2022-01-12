import 'package:test/scaffolding.dart';

import '../bin/apriori.dart' as app;

void main() {
  test(
    'App Runs With Exit Code 0',
    () => app.main(['test/options.json']),
  );
}
