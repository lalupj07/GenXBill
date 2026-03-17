import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class BackupService {
  Future<String?> createBackup() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final fileName =
          'genxbill_backup_${DateFormat('yyyyMMdd_HHmm').format(now)}.zip';
      final backupPath = p.join(backupDir.path, fileName);

      // 1. Identify valid Hive files
      final filesToBackup = appDir.listSync().where((file) {
        return file.path.endsWith('.hive') || file.path.endsWith('.lock');
      }).toList();

      if (filesToBackup.isEmpty) {
        throw Exception('No data files found to backup');
      }

      // 2. Create Zip
      var encoder = ZipFileEncoder();
      encoder.create(backupPath);

      for (var file in filesToBackup) {
        if (file is File) {
          await encoder.addFile(file);
        }
      }

      encoder.close();

      // 3. Share/Save file
      if (Platform.isWindows) {
        // On Windows, let user save relevant file
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Backup File',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['zip'],
        );

        if (result != null) {
          await File(backupPath).copy(result);
          return result;
        }
      } else {
        // Mobile: Share sheet
        // ignore: deprecated_member_use
        await Share.shareXFiles([XFile(backupPath)], text: 'GenXBill Backup');
        return backupPath;
      }
      return null;
    } catch (e) {
      debugPrint('Backup Error: $e');
      rethrow;
    }
  }

  Future<bool> restoreBackup() async {
    try {
      // 1. Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        final zipFile = File(result.files.single.path!);
        final bytes = await zipFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);

        final appDir = await getApplicationDocumentsDirectory();

        // 2. Warning: Close all boxes first?
        // Hive doesn't easily allow "close all and stay alive" without re-init.
        // We will just overwrite. If Windows locks, this might crash.
        // Best practice: Close specific boxes we know of.
        await Hive.close();

        // 3. Extract and Overwrite
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            File(p.join(appDir.path, filename))
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          }
        }

        // 4. Re-open boxes requires a restart or manual re-init.
        // We will return true and let UI suggest restart.
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Restore Error: $e');
      // Attempt to re-open if failed mid-way?
      return false;
    }
  }
}
