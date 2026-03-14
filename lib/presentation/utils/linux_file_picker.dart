import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Wraps [FilePicker] with a [kdialog] fallback for KDE Linux systems where
/// `zenity` is not installed.
///
/// Throws a [LinuxFilePickerException] when all backends fail, so callers can
/// show a meaningful error message to the user.
class LinuxFilePicker {
  LinuxFilePicker._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  static Future<String?> saveFile({
    required String defaultName,
    required String extension,
    required String fallbackDir,
  }) async {
    String? filePickerError;
    try {
      return await FilePicker.platform.saveFile(
        fileName: defaultName,
        allowedExtensions: [extension],
        type: FileType.custom,
      );
    } catch (e) {
      filePickerError = '$e';
      debugPrint('[LinuxFilePicker] file_picker.saveFile failed: $e');
    }
    return _kdialogSave(defaultName, extension, fallbackDir,
        filePickerError: filePickerError);
  }

  static Future<List<String>?> pickFiles({
    required List<String> extensions,
  }) async {
    String? filePickerError;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
      );
      if (result == null) return null;
      final paths =
          result.files.map((f) => f.path).whereType<String>().toList();
      return paths.isEmpty ? null : paths;
    } catch (e) {
      filePickerError = '$e';
      debugPrint('[LinuxFilePicker] file_picker.pickFiles failed: $e');
    }
    return _kdialogOpen(extensions, filePickerError: filePickerError);
  }

  static Future<String?> pickDirectory() async {
    String? filePickerError;
    try {
      return await FilePicker.platform.getDirectoryPath();
    } catch (e) {
      filePickerError = '$e';
      debugPrint('[LinuxFilePicker] file_picker.getDirectoryPath failed: $e');
    }
    return _kdialogDirectory(filePickerError: filePickerError);
  }

  // ---------------------------------------------------------------------------
  // kdialog helpers
  // ---------------------------------------------------------------------------

  /// Environment variables that GUI apps need to find the display server.
  static Map<String, String> get _guiEnv {
    final env = Map<String, String>.from(Platform.environment);
    // Ensure Wayland / X11 vars are forwarded to the child process.
    for (final key in [
      'DISPLAY',
      'WAYLAND_DISPLAY',
      'XDG_RUNTIME_DIR',
      'DBUS_SESSION_BUS_ADDRESS',
      'QT_QPA_PLATFORM',
      'HOME',
    ]) {
      final val = Platform.environment[key];
      if (val != null) env[key] = val;
    }
    return env;
  }

  static Future<String?> _kdialogSave(
      String defaultName, String extension, String fallbackDir,
      {String? filePickerError}) async {
    final startPath =
        p.join(Platform.environment['HOME'] ?? fallbackDir, defaultName);
    final result = await _runKdialog(
        ['--getsavefilename', startPath, '*.$extension'],
        label: 'saveFile',
        filePickerError: filePickerError);
    return result?.isNotEmpty == true ? result : null;
  }

  static Future<List<String>?> _kdialogOpen(List<String> extensions,
      {String? filePickerError}) async {
    final filter = extensions.map((e) => '*.$e').join(' ');
    final result = await _runKdialog(
        ['--getopenfilename', Platform.environment['HOME'] ?? '/', filter],
        label: 'pickFiles',
        filePickerError: filePickerError);
    if (result == null || result.isEmpty) return null;
    return [result];
  }

  static Future<String?> _kdialogDirectory({String? filePickerError}) async {
    final result = await _runKdialog(
        ['--getexistingdirectory', Platform.environment['HOME'] ?? '/'],
        label: 'pickDirectory',
        filePickerError: filePickerError);
    return result?.isNotEmpty == true ? result : null;
  }

  /// Runs `kdialog` with [args], logs everything, and returns trimmed stdout
  /// on success or throws [LinuxFilePickerException] on total failure.
  static Future<String?> _runKdialog(List<String> args,
      {required String label, String? filePickerError}) async {
    // Detect kdialog binary.
    final which = await Process.run('which', ['kdialog']);
    final kdialogPath = (which.stdout as String).trim();
    debugPrint('[LinuxFilePicker] which kdialog → '
        '${kdialogPath.isEmpty ? "(not found)" : kdialogPath}');

    if (kdialogPath.isEmpty) {
      const msg = 'No se encontró zenity ni kdialog en el sistema.\n'
          'Instala uno de ellos:\n'
          '  • Arch/CachyOS: sudo pacman -S kdialog\n'
          '  • o: sudo pacman -S zenity';
      debugPrint('[LinuxFilePicker] $msg');
      throw LinuxFilePickerException(msg);
    }

    try {
      debugPrint('[LinuxFilePicker] running: kdialog ${args.join(' ')}');
      final result = await Process.run(
        kdialogPath,
        args,
        environment: _guiEnv,
      );
      debugPrint('[LinuxFilePicker] kdialog.$label '
          'exit=${result.exitCode} '
          'stdout="${(result.stdout as String).trim()}" '
          'stderr="${(result.stderr as String).trim()}"');

      if (result.exitCode == 0) {
        return (result.stdout as String).trim();
      }
      // exitCode 1 = user cancelled (not an error).
      return null;
    } catch (e) {
      debugPrint('[LinuxFilePicker] kdialog.$label exception: $e');
      throw LinuxFilePickerException(
          'file_picker: $filePickerError\nkdialog: $e');
    }
  }
}

class LinuxFilePickerException implements Exception {
  LinuxFilePickerException(this.message);
  final String message;
  @override
  String toString() => message;
}
