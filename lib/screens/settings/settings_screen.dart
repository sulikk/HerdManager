import 'package:flutter/material.dart';

import '../../services/backup_service.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _handleBackup() async {
    setState(() => _isLoading = true);
    try {
      await _backupService.exportDatabase();
    } catch (e) {
      _showMessage("Błąd backupu: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleImport() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("UWAGA!"),
        content: const Text(
            "Import danych nadpisze WSZYSTKIE obecne dane w aplikacji. "
                "Tej operacji nie można cofnąć. Czy chcesz kontynuować?"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Anuluj"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Tak, nadpisz", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _backupService.importDatabase();
      _showMessage("Pomyślnie przywrócono kopię zapasową!");

    } catch (e) {
      if (e.toString().contains("Nie wybrano pliku")) {
      } else {
        _showMessage("Błąd importu: $e", isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                "Kopia zapasowa danych",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.upload_file, color: Colors.blue),
                  title: const Text("Utwórz kopię zapasową"),
                  subtitle: const Text("Zapisz plik bazy danych na Google Drive lub prześlij dalej"),
                  onTap: _handleBackup,
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.download_for_offline, color: Colors.orange),
                  title: const Text("Przywróć dane z kopii"),
                  subtitle: const Text("Wczytaj plik .db i nadpisz obecne dane"),
                  onTap: _handleImport,
                ),
              ),

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Wskazówka: Plik kopii zapasowej nazywa się zazwyczaj 'herd_management.db' lub 'herd_management.db_kopia'.",
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),

          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}