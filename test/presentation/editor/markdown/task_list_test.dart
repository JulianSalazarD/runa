import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/presentation/editor/markdown/task_list_extension.dart';
import 'package:runa/presentation/editor/markdown_preview_widget.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

const _taskList = '- [x] Done\n- [ ] Pending\n- [x] Also done';

void main() {
  group('Task list — rendering', () {
    testWidgets('checked and unchecked checkboxes render', (tester) async {
      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(content: _taskList)),
      );
      await tester.pumpAndSettle();
      final checkboxes =
          tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
      expect(checkboxes.length, 3);
      expect(checkboxes[0].value, isTrue);  // [x] Done
      expect(checkboxes[1].value, isFalse); // [ ] Pending
      expect(checkboxes[2].value, isTrue);  // [x] Also done
      expect(tester.takeException(), isNull);
    });

    testWidgets('checkboxes are read-only when no callback provided',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(content: _taskList)),
      );
      await tester.pumpAndSettle();
      final cb = tester.widgetList<Checkbox>(find.byType(Checkbox)).first;
      expect(cb.onChanged, isNull);
    });
  });

  group('Task list — toggle callback', () {
    testWidgets(
        'tapping checkbox invokes onCheckboxToggled with correct index',
        (tester) async {
      int? tappedIdx;
      bool? tappedValue;
      await tester.pumpWidget(
        _wrap(
          MarkdownPreviewWidget(
            content: _taskList,
            onCheckboxToggled: (idx, val) {
              tappedIdx = idx;
              tappedValue = val;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Tap the second checkbox (index 1, currently unchecked).
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();
      expect(tappedIdx, 1);
      expect(tappedValue, isTrue); // Was unchecked → now checked
    });
  });

  group('toggleCheckboxAt — unit', () {
    test('toggles unchecked to checked', () {
      const src = '- [ ] Task A\n- [x] Task B';
      expect(toggleCheckboxAt(src, 0, true), '- [x] Task A\n- [x] Task B');
    });

    test('toggles checked to unchecked', () {
      const src = '- [x] Task A\n- [ ] Task B';
      expect(toggleCheckboxAt(src, 0, false), '- [ ] Task A\n- [ ] Task B');
    });

    test('index out of bounds returns source unchanged', () {
      const src = '- [x] Only one';
      expect(toggleCheckboxAt(src, 5, false), src);
    });

    test('mixed list toggles correct item', () {
      const src = '- [ ] A\n- [ ] B\n- [x] C';
      expect(toggleCheckboxAt(src, 2, false), '- [ ] A\n- [ ] B\n- [ ] C');
    });
  });
}
