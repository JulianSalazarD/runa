import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:runa/application/application.dart';
import 'package:runa/data/data.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/home/welcome_view.dart';

// ---------------------------------------------------------------------------
// Synchronous fake for DefaultDirectoryService
// ---------------------------------------------------------------------------

/// Returns a fixed [Directory] immediately, avoiding real I/O so that
/// [pumpAndSettle] can properly drain the microtask queue in tests.
class _FakeDefaultDirectoryService extends DefaultDirectoryService {
  _FakeDefaultDirectoryService(this._dir);

  final Directory _dir;

  @override
  Future<Directory> getDefaultDirectory() async => _dir;
}

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeDocumentRepository implements DocumentRepository {
  final Map<String, Document> _store = {};
  final List<String> openedPaths = [];

  void seed(String path, Document doc) => _store[path] = doc;

  @override
  Future<Document> load(String path) async {
    openedPaths.add(path);
    final doc = _store[path];
    if (doc == null) throw DocumentNotFoundException(path: path);
    return doc;
  }

  @override
  Future<void> save(Document doc, String path) async => _store[path] = doc;

  @override
  Future<List<String>> listDocuments(String directory) async =>
      _store.keys.where((k) => k.startsWith(directory)).toList();
}

class _FakeRecentFilesService implements RecentFilesService {
  @override
  Future<List<String>> loadRecents() async => const [];

  @override
  Future<List<RecentEntry>> loadRecentEntries() async => const [];

  @override
  Future<void> addRecent(String path) async {}

  @override
  Future<void> remove(String path) async {}

  @override
  Future<void> clear() async {}
}

class _FakeFileSystemService implements FileSystemService {
  final Map<String, List<DirectoryItem>> _dirs;
  final List<String> createdDirectories = [];

  _FakeFileSystemService([this._dirs = const {}]);

  @override
  Future<List<DirectoryItem>> listDirectory(String path) async =>
      _dirs[path] ?? const [];

  @override
  Stream<FileSystemEvent> watchDirectory(String directory) =>
      const Stream.empty();

  @override
  Future<void> createDirectory(String path) async =>
      createdDirectories.add(path);

  @override
  Future<void> renameEntry(String oldPath, String newPath) async {}

  @override
  Future<void> deleteFile(String path) async {}

  @override
  Future<void> deleteDirectory(String path) async {}

  @override
  Future<List<String>> listRunaFiles(String directory) async => const [];
}

// ---------------------------------------------------------------------------
// Workspace state spy
// ---------------------------------------------------------------------------

/// Renders the current [WorkspaceState.openedDirectoryPath] as plain text so
/// tests can assert on it with [find.text].
class _WorkspaceStateSpy extends ConsumerWidget {
  const _WorkspaceStateSpy();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path =
        ref.watch(workspaceNotifierProvider.select((s) => s.openedDirectoryPath));
    return Text(path ?? '', key: const Key('workspace_spy'));
  }
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Pumps a standalone [WelcomeView] (not inside HomeScreen) with provider
/// overrides that point to a controlled [rootPath] and seeded directory
/// contents.
Future<void> pumpBrowser(
  WidgetTester tester, {
  required String rootPath,
  Map<String, List<DirectoryItem>> dirs = const {},
  _FakeDocumentRepository? repo,
  _FakeFileSystemService? fakeFs,
}) async {
  final effectiveFs = fakeFs ?? _FakeFileSystemService(dirs);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        defaultDirectoryServiceProvider.overrideWith(
          (_) => _FakeDefaultDirectoryService(Directory(rootPath)),
        ),
        fileSystemServiceProvider.overrideWith((_) => effectiveFs),
        recentFilesServiceProvider
            .overrideWith((_) => _FakeRecentFilesService()),
        documentRepositoryProvider
            .overrideWith((_) => repo ?? _FakeDocumentRepository()),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(child: WelcomeView()),
              _WorkspaceStateSpy(),
            ],
          ),
        ),
      ),
    ),
  );
  // Wait for _loadDefaultDir and _load to complete.
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;
  late String rootPath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('runa_browser_test_');
    // DefaultDirectoryService(homeOverride: tempDir.path) will resolve
    // to {tempDir}/Runa as the root path.
    rootPath = p.join(tempDir.path, 'Runa');
    Directory(rootPath).createSync();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('default directory browser — listing', () {
    testWidgets('shows "Documentos" header at root', (tester) async {
      await pumpBrowser(tester, rootPath: rootPath);

      expect(find.text('Documentos'), findsOneWidget);
    });

    testWidgets('empty directory shows "Carpeta vacía"', (tester) async {
      await pumpBrowser(tester, rootPath: rootPath, dirs: {rootPath: []});

      expect(find.text('Carpeta vacía'), findsOneWidget);
    });

    testWidgets('shows folder name for a directory item', (tester) async {
      await pumpBrowser(tester, rootPath: rootPath, dirs: {
        rootPath: [
          DirectoryItem(path: p.join(rootPath, 'proyectos'), isDirectory: true),
        ],
      });

      expect(find.text('proyectos'), findsOneWidget);
    });

    testWidgets('shows document name without extension for a .runa file',
        (tester) async {
      await pumpBrowser(tester, rootPath: rootPath, dirs: {
        rootPath: [
          DirectoryItem(
              path: p.join(rootPath, 'mi_nota.runa'), isDirectory: false),
        ],
      });

      expect(find.text('mi_nota'), findsOneWidget);
    });

    testWidgets('back button is not shown at root', (tester) async {
      await pumpBrowser(tester, rootPath: rootPath);

      expect(find.byTooltip('Atrás'), findsNothing);
    });
  });

  group('default directory browser — navigation', () {
    testWidgets('tapping a folder navigates into it', (tester) async {
      final subDir = p.join(rootPath, 'carpeta');
      await pumpBrowser(tester, rootPath: rootPath, dirs: {
        rootPath: [DirectoryItem(path: subDir, isDirectory: true)],
        subDir: [
          DirectoryItem(
              path: p.join(subDir, 'doc.runa'), isDirectory: false),
        ],
      });

      await tester.tap(find.text('carpeta'));
      await tester.pumpAndSettle();

      // Now inside 'carpeta': document shows, header is folder name.
      expect(find.text('carpeta'), findsOneWidget);
      expect(find.text('doc'), findsOneWidget);
      // Back button is now visible.
      expect(find.byTooltip('Atrás'), findsOneWidget);
    });

    testWidgets('tapping back returns to root listing', (tester) async {
      final subDir = p.join(rootPath, 'carpeta');
      await pumpBrowser(tester, rootPath: rootPath, dirs: {
        rootPath: [DirectoryItem(path: subDir, isDirectory: true)],
        subDir: [],
      });

      await tester.tap(find.text('carpeta'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Atrás'));
      await tester.pumpAndSettle();

      expect(find.text('Documentos'), findsOneWidget);
      expect(find.byTooltip('Atrás'), findsNothing);
    });
  });

  group('default directory browser — open document', () {
    testWidgets('tapping a document opens it via workspaceNotifier',
        (tester) async {
      final docPath = p.join(rootPath, 'nota.runa');
      final fakeRepo = _FakeDocumentRepository()
        ..seed(
          docPath,
          Document(
            version: '0.1',
            id: 'doc-001',
            createdAt: DateTime.utc(2024),
            updatedAt: DateTime.utc(2024),
            blocks: const [],
          ),
        );

      await pumpBrowser(tester, rootPath: rootPath, dirs: {
        rootPath: [DirectoryItem(path: docPath, isDirectory: false)],
      }, repo: fakeRepo);

      await tester.tap(find.text('nota'));
      await tester.pumpAndSettle();

      expect(fakeRepo.openedPaths, contains(docPath));
    });
  });

  group('default directory browser — create folder', () {
    testWidgets('"Nueva carpeta" button is present', (tester) async {
      await pumpBrowser(tester, rootPath: rootPath);

      expect(find.byTooltip('Nueva carpeta'), findsOneWidget);
    });

    testWidgets('tapping "Nueva carpeta" opens a name dialog', (tester) async {
      await pumpBrowser(tester, rootPath: rootPath, dirs: {rootPath: []});

      await tester.tap(find.byTooltip('Nueva carpeta'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Nueva carpeta'), findsWidgets);
    });

    testWidgets('submitting folder name calls createSubdirectory',
        (tester) async {
      final fakeFs = _FakeFileSystemService({rootPath: []});
      await pumpBrowser(tester, rootPath: rootPath, fakeFs: fakeFs);

      await tester.tap(find.byTooltip('Nueva carpeta'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'nueva');
      await tester.pump(); // rebuild so _canConfirm re-evaluates
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      expect(fakeFs.createdDirectories,
          contains(p.join(rootPath, 'nueva')));
    });

    testWidgets('cancelling folder dialog makes no createDirectory call',
        (tester) async {
      final fakeFs = _FakeFileSystemService({rootPath: []});
      await pumpBrowser(tester, rootPath: rootPath, fakeFs: fakeFs);

      await tester.tap(find.byTooltip('Nueva carpeta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(fakeFs.createdDirectories, isEmpty);
    });
  });

  group('default directory browser — create document', () {
    testWidgets('"Nuevo documento" button is present in browser header',
        (tester) async {
      await pumpBrowser(tester, rootPath: rootPath);

      expect(find.byTooltip('Nuevo documento'), findsOneWidget);
    });

    testWidgets('tapping browser "Nuevo documento" opens a name dialog',
        (tester) async {
      await pumpBrowser(tester, rootPath: rootPath, dirs: {rootPath: []});

      await tester.tap(find.byTooltip('Nuevo documento'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('default directory browser — open in editor', () {
    testWidgets('"Abrir en editor" button is present', (tester) async {
      await pumpBrowser(tester, rootPath: rootPath);

      expect(find.byTooltip('Abrir en editor'), findsOneWidget);
    });

    testWidgets('tapping "Abrir en editor" at root sets openedDirectoryPath',
        (tester) async {
      await pumpBrowser(tester, rootPath: rootPath);

      await tester.tap(find.byTooltip('Abrir en editor'));
      await tester.pumpAndSettle();

      expect(find.text(rootPath), findsOneWidget);
    });

    testWidgets('tapping "Abrir en editor" inside subfolder opens subfolder',
        (tester) async {
      final subDir = p.join(rootPath, 'carpeta');
      await pumpBrowser(tester, rootPath: rootPath, dirs: {
        rootPath: [DirectoryItem(path: subDir, isDirectory: true)],
        subDir: [],
      });

      await tester.tap(find.text('carpeta'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Abrir en editor'));
      await tester.pumpAndSettle();

      expect(find.text(subDir), findsOneWidget);
    });
  });
}
