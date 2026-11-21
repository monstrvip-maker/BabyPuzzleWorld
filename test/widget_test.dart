import 'package:flutter_test/flutter_test.dart';
import 'package:baby_puzzle_world/main.dart';

void main() {
  testWidgets('home screen displays the game title', (tester) async {
    await tester.pumpWidget(const BabyPuzzleApp());
    expect(find.text('Привет, малыш!'), findsOneWidget);
    expect(find.text('Выбери мир'), findsOneWidget);
  });
}
