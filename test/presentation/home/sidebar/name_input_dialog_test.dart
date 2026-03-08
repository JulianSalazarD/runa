import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/presentation/presentation.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _pump(NameInputDialog dialog) => MaterialApp(home: Scaffold(body: dialog));

// Finders
final _confirmFinder = find.widgetWithText(TextButton, 'Aceptar');
final _cancelFinder = find.widgetWithText(TextButton, 'Cancelar');

TextButton _confirmButton(WidgetTester tester) =>
    tester.widget<TextButton>(_confirmFinder);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NameInputDialog — empty field', () {
    testWidgets('confirm button is disabled when field is empty',
        (tester) async {
      await tester.pumpWidget(_pump(
        const NameInputDialog(title: 'Test', hint: 'hint'),
      ));

      expect(_confirmButton(tester).onPressed, isNull);
    });

    testWidgets('no error text shown when field is empty', (tester) async {
      await tester.pumpWidget(_pump(
        const NameInputDialog(title: 'Test', hint: 'hint'),
      ));

      // TextField shows no error decoration when empty.
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.errorText, isNull);
    });

    testWidgets('confirm button enabled after typing a valid name',
        (tester) async {
      await tester.pumpWidget(_pump(
        const NameInputDialog(title: 'Test', hint: 'hint'),
      ));

      await tester.enterText(find.byType(TextField), 'mi_doc');
      await tester.pump();

      expect(_confirmButton(tester).onPressed, isNotNull);
    });
  });

  // -------------------------------------------------------------------------

  group('NameInputDialog — invalid characters', () {
    for (final ch in ['/', '\\', ':', '*', '?', '"', '<', '>', '|']) {
      testWidgets('shows error for character "$ch"', (tester) async {
        await tester.pumpWidget(_pump(
          const NameInputDialog(title: 'Test', hint: 'hint'),
        ));

        await tester.enterText(find.byType(TextField), 'doc$ch');
        await tester.pump();

        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.decoration?.errorText, isNotNull);
        expect(_confirmButton(tester).onPressed, isNull);
      });
    }
  });

  // -------------------------------------------------------------------------

  group('NameInputDialog — duplicate names', () {
    testWidgets('shows error when name matches an existing entry',
        (tester) async {
      await tester.pumpWidget(_pump(
        const NameInputDialog(
          title: 'Test',
          hint: 'hint',
          existingNames: {'alpha', 'beta'},
        ),
      ));

      await tester.enterText(find.byType(TextField), 'alpha');
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.errorText, contains('Ya existe'));
      expect(_confirmButton(tester).onPressed, isNull);
    });

    testWidgets('confirm is enabled for a name not in existingNames',
        (tester) async {
      await tester.pumpWidget(_pump(
        const NameInputDialog(
          title: 'Test',
          hint: 'hint',
          existingNames: {'alpha', 'beta'},
        ),
      ));

      await tester.enterText(find.byType(TextField), 'gamma');
      await tester.pump();

      expect(_confirmButton(tester).onPressed, isNotNull);
    });

    testWidgets('duplicate check is case-sensitive', (tester) async {
      await tester.pumpWidget(_pump(
        const NameInputDialog(
          title: 'Test',
          hint: 'hint',
          existingNames: {'Alpha'},
        ),
      ));

      await tester.enterText(find.byType(TextField), 'alpha');
      await tester.pump();

      // 'alpha' ≠ 'Alpha' → no duplicate error, button enabled.
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.errorText, isNull);
      expect(_confirmButton(tester).onPressed, isNotNull);
    });
  });

  // -------------------------------------------------------------------------

  group('NameInputDialog — result', () {
    testWidgets('tapping Aceptar pops with the trimmed name', (tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showNameInputDialog(
                  context,
                  title: 'Nuevo documento',
                  hint: 'hint',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '  mi_doc  ');
      await tester.pump();
      await tester.tap(_confirmFinder);
      await tester.pumpAndSettle();

      expect(result, 'mi_doc');
    });

    testWidgets('tapping Cancelar pops with null', (tester) async {
      String? result = 'initial';
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showNameInputDialog(
                  context,
                  title: 'Nuevo documento',
                  hint: 'hint',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(_cancelFinder);
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('pressing Enter submits when name is valid', (tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showNameInputDialog(
                  context,
                  title: 'Nuevo documento',
                  hint: 'hint',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'via_enter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(result, 'via_enter');
    });

    testWidgets('pressing Enter does nothing when name is invalid',
        (tester) async {
      await tester.pumpWidget(_pump(
        const NameInputDialog(
          title: 'Test',
          hint: 'hint',
          existingNames: {'taken'},
        ),
      ));

      await tester.enterText(find.byType(TextField), 'taken');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Dialog is still present (not popped).
      expect(find.byType(NameInputDialog), findsOneWidget);
    });

    testWidgets('initial value pre-fills the text field', (tester) async {
      await tester.pumpWidget(_pump(
        const NameInputDialog(
          title: 'Renombrar',
          hint: 'hint',
          initial: 'mi_archivo',
        ),
      ));

      expect(find.text('mi_archivo'), findsOneWidget);
      // Confirm is enabled because initial value is valid.
      expect(_confirmButton(tester).onPressed, isNotNull);
    });
  });
}
