int _counter = 0;

/// Generates a short, unique-enough id for demo/in-memory records.
String generateId(String prefix) {
  _counter += 1;
  final ts = DateTime.now().microsecondsSinceEpoch;
  return '$prefix-$ts-$_counter';
}
