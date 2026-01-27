import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_provider.dart';


class BackupService {
  static const String _dbName = 'herd_management.db';

  Future<void> exportDatabase() async {
    final dbPath = await getDatabasesPath();
    final sourcePath = join(dbPath, _dbName);
    final file = File(sourcePath);

    if (await file.exists()) {

      await Share.shareXFiles(
        [XFile(sourcePath)],
        text: 'Kopia zapasowa - Zarządzanie Stadem',
      );
    } else {
      throw Exception("Nie znaleziono pliku bazy danych!");
    }
  }

  Future<void> importDatabase() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File backupFile = File(result.files.single.path!);

      await DatabaseProvider.instance.close();

      final dbPath = await getDatabasesPath();
      final destinationPath = join(dbPath, _dbName);

      await backupFile.copy(destinationPath);

    } else {
      throw Exception("Nie wybrano pliku.");
    }
  }


}