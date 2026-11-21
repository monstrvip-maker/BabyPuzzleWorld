import 'package:flutter_test/flutter_test.dart';
import 'package:baby_puzzle_world/character_assets.dart';

void main() {
  test('all bundled character assets have a non-empty emoji value', () {
    expect(characterAssets, isNotEmpty);
    for (final entry in characterAssets.entries) {
      expect(entry.key, isNotEmpty);
      expect(entry.value, isNotEmpty);
    }
  });
}
