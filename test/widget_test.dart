import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/application/application.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/main.dart';

class _FakeDocumentRepository implements DocumentRepository {
  @override
  Future<Document> load(String path) async => throw DocumentNotFoundException(path: path);

  @override
  Future<void> save(Document doc, String path) async {}

  @override
  Future<List<String>> listDocuments(String directory) async => const [];
}

class _FakeRecentFilesService implements RecentFilesService {
  @override
  Future<List<String>> loadRecents() async => const [];

  @override
  Future<void> addRecent(String path) async {}

  @override
  Future<void> remove(String path) async {}

  @override
  Future<void> clear() async {}
}

class _FakeFileSystemService implements FileSystemService {
  @override
  Future<List<String>> listRunaFiles(String directory) async => const [];

  @override
  Stream<FileSystemEvent> watchDirectory(String directory) =>
      const Stream.empty();

  @override
  Future<void> createDirectory(String path) async {}
}

void main() {
  testWidgets('RunaApp renders welcome screen with action buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentRepositoryProvider
              .overrideWith((_) => _FakeDocumentRepository()),
          recentFilesServiceProvider
              .overrideWith((_) => _FakeRecentFilesService()),
          fileSystemServiceProvider
              .overrideWith((_) => _FakeFileSystemService()),
        ],
        child: const RunaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Abrir carpeta'), findsOneWidget);
    expect(find.text('Nuevo documento'), findsOneWidget);
  });
}
