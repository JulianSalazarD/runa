import 'package:runa/domain/models/document.dart';

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

/// Base class for all errors thrown by [DocumentRepository] implementations.
sealed class DocumentRepositoryException implements Exception {
  const DocumentRepositoryException({required this.path});

  /// The file-system path involved in the failed operation.
  final String path;
}

/// Thrown when the target file does not exist.
final class DocumentNotFoundException extends DocumentRepositoryException {
  const DocumentNotFoundException({required super.path});

  @override
  String toString() => 'DocumentNotFoundException: file not found at "$path"';
}

/// Thrown when the file content cannot be decoded as a valid [Document].
/// Covers: invalid JSON, wrong root type, missing required fields, etc.
final class DocumentParseException extends DocumentRepositoryException {
  const DocumentParseException({required super.path, required this.cause});

  /// Human-readable description of the underlying parse failure.
  final String cause;

  @override
  String toString() =>
      'DocumentParseException: could not parse "$path": $cause';
}

/// Thrown when the document's [version] field is absent or unsupported
/// by this parser. The caller must not attempt to parse such files.
final class DocumentVersionException extends DocumentRepositoryException {
  const DocumentVersionException({
    required super.path,
    required this.version,
  });

  /// The version string found in the file (or `"missing"` if absent).
  final String version;

  @override
  String toString() =>
      'DocumentVersionException: unsupported version "$version" in "$path"';
}

// ---------------------------------------------------------------------------
// Interface
// ---------------------------------------------------------------------------

/// Abstract interface for loading, saving and listing [Document]s.
///
/// Implementations may use local file I/O, a remote API, or an in-memory
/// store. All methods are async and throw [DocumentRepositoryException]
/// subtypes on failure.
abstract interface class DocumentRepository {
  /// Loads and parses a [Document] from the `.runa` file at [path].
  ///
  /// Throws:
  /// - [DocumentNotFoundException] if [path] does not exist.
  /// - [DocumentVersionException] if the version field is missing or unsupported.
  /// - [DocumentParseException] if the file content is not valid JSON or the
  ///   document structure does not match the expected schema.
  Future<Document> load(String path);

  /// Serialises [doc] and writes it to [path], creating parent directories
  /// as needed. Overwrites any existing file at [path].
  Future<void> save(Document doc, String path);

  /// Returns the absolute paths of all `.runa` files directly inside
  /// [directory], sorted alphabetically. Returns an empty list if the
  /// directory does not exist or contains no `.runa` files.
  Future<List<String>> listDocuments(String directory);
}
