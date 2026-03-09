/// Service for managing file assets associated with a `.runa` document.
///
/// Assets (images, PDFs) are stored in an `_assets/` directory next to the
/// `.runa` file. Paths stored in blocks are relative (e.g. `_assets/foto.png`).
abstract interface class AssetManager {
  /// Copies the file at [sourcePath] to the `_assets/` directory next to
  /// [documentPath]. Returns the relative path (e.g. `_assets/foto.png`).
  ///
  /// If a file with the same name already exists, the copy is skipped and
  /// the existing relative path is returned (deduplication by filename).
  Future<String> copyAsset(String sourcePath, String documentPath);

  /// Returns the natural pixel dimensions `(width, height)` of the image at
  /// [path] by decoding its header.
  ///
  /// Throws if the file does not exist or is not a supported image format.
  Future<(double, double)> readImageSize(String path);

  /// Converts a relative asset path (e.g. `_assets/foto.png`) to an absolute
  /// path on the file system.
  String resolveAsset(String relativePath, String documentPath);

  /// Deletes the asset at [relativePath] from the `_assets/` directory.
  ///
  /// Does nothing if the file does not exist.
  Future<void> deleteAsset(String relativePath, String documentPath);

  /// Lists all files in the `_assets/` directory next to [documentPath] as
  /// relative paths (e.g. `_assets/foto.png`), sorted alphabetically.
  ///
  /// Returns an empty list if the directory does not exist.
  Future<List<String>> listAssets(String documentPath);
}
