import 'package:entire_transform_gesture/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('flip buttons transform the image', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    final transformFinder = find.byKey(const ValueKey('image-transform'));
    expect(find.text('Lật ngang'), findsOneWidget);
    expect(find.text('Lật dọc'), findsOneWidget);

    List<double> matrixValues() {
      return tester
          .widget<Transform>(transformFinder)
          .transform
          .storage
          .toList();
    }

    final originalTransform = matrixValues();

    await tester.tap(find.text('Lật ngang'));
    await tester.pump();
    expect(matrixValues(), isNot(equals(originalTransform)));

    await tester.tap(find.text('Lật ngang'));
    await tester.pump();
    final restoredTransform = matrixValues();
    for (var index = 0; index < originalTransform.length; index++) {
      expect(
        restoredTransform[index],
        closeTo(originalTransform[index], 1e-10),
      );
    }

    await tester.tap(find.text('Lật dọc'));
    await tester.pump();
    expect(matrixValues(), isNot(equals(originalTransform)));
  });

  testWidgets('flip mode selects image or screen axes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    final transformFinder = find.byKey(const ValueKey('image-transform'));
    List<double> matrixValues() {
      return tester
          .widget<Transform>(transformFinder)
          .transform
          .storage
          .toList();
    }

    final center = tester.getCenter(transformFinder);
    final leftPointer = await tester.startGesture(
      center + const Offset(-40, 0),
      pointer: 1,
    );
    final rightPointer = await tester.startGesture(
      center + const Offset(40, 0),
      pointer: 2,
    );
    await tester.pump();
    await leftPointer.moveTo(center + const Offset(0, -40));
    await rightPointer.moveTo(center + const Offset(0, 40));
    await tester.pump();
    await leftPointer.up();
    await rightPointer.up();
    await tester.pump();

    await tester.tap(find.text('Lật ngang'));
    await tester.pump();
    final imageAxisFlip = matrixValues();

    await tester.tap(find.text('Lật ngang'));
    await tester.pump();
    await tester.tap(find.text('Theo màn hình'));
    await tester.pump();
    await tester.tap(find.text('Lật ngang'));
    await tester.pump();
    expect(matrixValues(), isNot(equals(imageAxisFlip)));
  });
}
