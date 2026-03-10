import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/presentation/editor/markdown_preview_widget.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );

const _dartFence = '```dart\nvoid main() {}\n```';
const _unknownFence = '```xyzlang\nhello world\n```';
const _noLangFence = '```\nplain code\n```';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CodeBlockBuilder — syntax highlighting', () {
    testWidgets('dart fence renders HighlightView', (tester) async {
      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(content: _dartFence)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HighlightView), findsOneWidget);
    });

    testWidgets('unknown language renders fallback without error',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(content: _unknownFence)),
      );
      await tester.pumpAndSettle();

      // No HighlightView — fallback plain text container instead.
      expect(find.byType(HighlightView), findsNothing);
      // The code text is still visible.
      expect(find.textContaining('hello world'), findsOneWidget);
      // Must not throw.
      expect(tester.takeException(), isNull);
    });

    testWidgets('fence with no language renders fallback without error',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(content: _noLangFence)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HighlightView), findsNothing);
      expect(find.textContaining('plain code'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('CodeBlockBuilder — copy button', () {
    testWidgets('copy button writes code to clipboard', (tester) async {
      // Capture clipboard writes via the SystemChannels mock.
      final List<String> clipboard = [];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            final data = call.arguments as Map;
            clipboard.add(data['text'] as String);
          }
          return null;
        },
      );

      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(content: _dartFence)),
      );
      await tester.pumpAndSettle();

      // Tap the copy icon button (key set in _Header).
      await tester.tap(find.byKey(const ValueKey('copy_button')));
      await tester.pumpAndSettle();

      expect(clipboard, isNotEmpty);
      expect(clipboard.last, contains('void main'));

      // Advance past the 2-second feedback timer.
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('copy button shows check icon as feedback', (tester) async {
      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(content: _dartFence)),
      );
      await tester.pumpAndSettle();

      // Before tap — copy icon is shown.
      expect(find.byIcon(Icons.copy), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);

      await tester.tap(find.byKey(const ValueKey('copy_button')));
      await tester.pump(); // single frame to process setState

      // After tap — check icon is shown temporarily.
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsNothing);

      // Advance past the 2-second feedback timer to avoid pending-timer errors.
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('CodeBlockBuilder — dark theme', () {
    testWidgets('dark theme renders HighlightView with dark theme selected',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MarkdownPreviewWidget(content: _dartFence),
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpAndSettle();

      // HighlightView must be present when language is supported.
      expect(find.byType(HighlightView), findsOneWidget);
      // No exception.
      expect(tester.takeException(), isNull);
    });
  });
}
