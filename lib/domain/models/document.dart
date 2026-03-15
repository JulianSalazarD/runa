import 'package:freezed_annotation/freezed_annotation.dart';

import 'block.dart';

part 'document.freezed.dart';
part 'document.g.dart';

/// A Runa document: an ordered list of [Block]s with metadata.
///
/// Maps 1-to-1 with a `.runa` file on disk.
@freezed
abstract class Document with _$Document {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory Document({
    /// Schema version (e.g. "0.1"). Parsers must check this first and
    /// reject documents with unsupported versions.
    required String version,

    /// Unique document identifier (UUID v4). Immutable after creation.
    required String id,

    /// UTC timestamp of document creation. Immutable after creation.
    required DateTime createdAt,

    /// UTC timestamp of last modification. Updated on every save.
    required DateTime updatedAt,

    /// Ordered list of content blocks (top-to-bottom layout).
    required List<Block> blocks,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
}
