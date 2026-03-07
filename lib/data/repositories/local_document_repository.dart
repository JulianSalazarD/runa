import 'dart:convert';
import 'dart:io';

import 'package:runa/domain/domain.dart';

const _supportedVersions = {'0.1'};
const _runaExtension = '.runa';
const _jsonEncoder = JsonEncoder.withIndent('  ');

/// [DocumentRepository] implementation backed by the local file system.
///
/// Each [Document] is stored as a pretty-printed JSON file with the `.runa`
/// extension. The [version] field is checked before deserialisation; files
/// with unknown versions are rejected with [DocumentVersionException].
class LocalDocumentRepository implements DocumentRepository {
  const LocalDocumentRepository();

  @override
  Future<Document> load(String path) async {
    final file = File(path);

    if (!await file.exists()) {
      throw DocumentNotFoundException(path: path);
    }

    final String content;
    try {
      content = await file.readAsString();
    } on FileSystemException catch (e) {
      throw DocumentParseException(path: path, cause: e.message);
    }

    // Parse JSON ---------------------------------------------------------------
    final Object? decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException catch (e) {
      throw DocumentParseException(path: path, cause: e.message);
    }

    if (decoded is! Map<String, dynamic>) {
      throw DocumentParseException(
        path: path,
        cause: 'root must be a JSON object, got ${decoded.runtimeType}',
      );
    }
    final json = decoded;

    // Version check ------------------------------------------------------------
    final version = json['version'];
    if (version is! String || !_supportedVersions.contains(version)) {
      throw DocumentVersionException(
        path: path,
        version: version?.toString() ?? 'missing',
      );
    }

    // Deserialise --------------------------------------------------------------
    try {
      return Document.fromJson(json);
    } on Object catch (e) {
      throw DocumentParseException(path: path, cause: e.toString());
    }
  }

  @override
  Future<void> save(Document doc, String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final content = _jsonEncoder.convert(doc.toJson());
    await file.writeAsString(content);
  }

  @override
  Future<List<String>> listDocuments(String directory) async {
    final dir = Directory(directory);
    if (!await dir.exists()) return const [];

    final paths = <String>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith(_runaExtension)) {
        paths.add(entity.path);
      }
    }
    paths.sort();
    return paths;
  }
}
