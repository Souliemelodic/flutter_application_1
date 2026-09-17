// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('two plus two equals four', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('2'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('='));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('calculator-display'))).data,
      '4',
    );
  });

testWidgets('5 plus two equals 5', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('5'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('='));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('calculator-display'))).data,
      '10',
    );
  });

testWidgets('10 plus two equals 10', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('10'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('10'));
    await tester.tap(find.text('='));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('calculator-display'))).data,
      '20',
    );
  });

  testWidgets('calculator supports multiplication', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('2'));
    await tester.tap(find.text('x'));
    await tester.tap(find.text('3'));
    await tester.tap(find.text('='));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('calculator-display'))).data,
      '6',
    );
  });

testWidgets('4 times 4', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('4'));
    await tester.tap(find.text('x'));
    await tester.tap(find.text('4'));
    await tester.tap(find.text('='));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('calculator-display'))).data,
      '16',
    );
  });
testWidgets('5 times 4', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('5'));
    await tester.tap(find.text('x'));
    await tester.tap(find.text('4'));
    await tester.tap(find.text('='));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('calculator-display'))).data,
      '20',
    );
  });

testWidgets('4 divided by 2', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('4'));
    await tester.tap(find.text('/'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('='));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('calculator-display'))).data,
      '2',
    );
  });
testWidgets('20 divided by 4', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('20'));
    await tester.tap(find.text('/'));
    await tester.tap(find.text('4'));
    await tester.tap(find.text('='));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('calculator-display'))).data,
      '5',
    );
  });



}