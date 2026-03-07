import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:runa/data/data.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Phase 0 smoke test
//
// Exercises the full cycle without any UI:
//   1. Resolve ~/Runa/ and create it if absent.
//   2. Create a Document with a MarkdownBlock and an InkBlock.
//   3. Save it as a .runa file.
//   4. Load it back from disk.
//   5. Assert the loaded document equals the original.
//
// Remove or replace this function once the application layer is in place.
// ---------------------------------------------------------------------------

Future<void> _runSmoke() async {
  const dirService = DefaultDirectoryService();
  const repo = LocalDocumentRepository();
  const uuid = Uuid();

  // 1. Resolve default directory.
  final runaDir = await dirService.getDefaultDirectory();
  debugPrint('[smoke] Default directory: ${runaDir.path}');

  // 2. Build a document.
  final doc = Document(
    version: '0.1',
    id: uuid.v4(),
    createdAt: DateTime.now().toUtc(),
    updatedAt: DateTime.now().toUtc(),
    blocks: [
      MarkdownBlock(
        id: uuid.v4(),
        content: '# Smoke test\n\nPhase 0 is working.',
      ),
      InkBlock(
        id: uuid.v4(),
        height: 200.0,
        strokes: [
          Stroke(
            id: uuid.v4(),
            color: '#000000FF',
            width: 2.0,
            tool: StrokeTool.pen,
            points: const [
              StrokePoint(x: 10.0, y: 20.0, pressure: 0.5, timestamp: 0),
              StrokePoint(x: 20.0, y: 30.0, pressure: 0.6, timestamp: 16),
            ],
          ),
        ],
      ),
    ],
  );

  // 3. Save.
  final docPath = p.join(runaDir.path, 'smoke_test.runa');
  await repo.save(doc, docPath);
  debugPrint('[smoke] Saved to: $docPath');

  // 4. Load.
  final loaded = await repo.load(docPath);
  debugPrint('[smoke] Loaded: ${loaded.blocks.length} blocks');

  // 5. Assert.
  assert(loaded == doc, 'Round-trip failed: loaded document differs from original');
  assert(loaded.blocks[0] is MarkdownBlock);
  assert(loaded.blocks[1] is InkBlock);
  final ink = loaded.blocks[1] as InkBlock;
  assert(ink.strokes.length == 1);
  assert(ink.strokes[0].points.length == 2);

  debugPrint('[smoke] OK — Phase 0 cycle complete.');
}

// ---------------------------------------------------------------------------
// App entry point
// ---------------------------------------------------------------------------

void main() {
  runApp(const RunaApp());
}

class RunaApp extends StatelessWidget {
  const RunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Runa',
      home: _SmokeScreen(),
    );
  }
}

class _SmokeScreen extends StatefulWidget {
  @override
  State<_SmokeScreen> createState() => _SmokeScreenState();
}

class _SmokeScreenState extends State<_SmokeScreen> {
  String _status = 'Running smoke test…';

  @override
  void initState() {
    super.initState();
    _runSmoke().then((_) {
      setState(() => _status = 'Phase 0 smoke test passed.');
    }).catchError((Object e) {
      setState(() => _status = 'Smoke test FAILED:\n$e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _status,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
