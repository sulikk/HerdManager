import 'dart:io';
import 'package:flutter/material.dart';
import 'package:herd_management/services/animal_service.dart';
import 'package:image_picker/image_picker.dart';
import '/../models/animal_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AddAnimalScreen extends StatefulWidget {

  final Animal? animalToEdit;

  const AddAnimalScreen({super.key, this.animalToEdit});

  @override
  _AddAnimalScreenState createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();


  final _earTagController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _originController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _earTagController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _originController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.animalToEdit != null) {
      _earTagController.text = widget.animalToEdit!.earTagNumber;
      _breedController.text = widget.animalToEdit!.breed;
      _weightController.text = widget.animalToEdit!.weight?.toString() ?? '';
      _originController.text = widget.animalToEdit!.origin ?? '';
      _notesController.text = widget.animalToEdit!.notes ?? '';
      _selectedDate = widget.animalToEdit!.birthDate;
      _imagePath = widget.animalToEdit!.imagePath;
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (photo != null) {
      setState(() {
        _imagePath = photo.path;
      });
    }
  }

  void _openScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              AppBar(
                title: Text("Zeskanuj kolczyk"),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        setState(() {
                          _earTagController.text = barcode.rawValue!;
                        });
                        Navigator.pop(context);
                        break;
                      }
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Skieruj aparat na kod kreskowy na kolczyku"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pl', 'PL'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveAnimal() async {
    if (_formKey.currentState!.validate()) {
      final animalData = Animal(
        earTagNumber: _earTagController.text.trim(),
        birthDate: _selectedDate,
        breed: _breedController.text,
        weight: double.tryParse(_weightController.text.replaceAll(',', '.')),
        origin: _originController.text,
        notes: _notesController.text,
        imagePath: _imagePath,
      );

      try {
        if (widget.animalToEdit != null) {
          await AnimalService().update(animalData);
        } else {
          await AnimalService().insert(animalData);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.animalToEdit != null
                  ? 'Zaktualizowano dane zwierzęcia!'
                  : 'Dodano nowe zwierzę!'),
              backgroundColor: Colors.green
          ),
        );

        if (widget.animalToEdit != null) {
          Navigator.pop(context);
        } else {
          _formKey.currentState!.reset();
          _earTagController.clear();
          _breedController.clear();
          _weightController.clear();
          _originController.clear();
          _notesController.clear();
          setState(() {
            _imagePath = null;
            _selectedDate = DateTime.now();
          });
        }

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Błąd zapisu zwierzęcia!',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.animalToEdit != null;

    Widget formContent = SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Dane podstawowe",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _earTagController,
                    readOnly: isEditing,
                    decoration: InputDecoration(
                      labelText: 'Numer kolczyka *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.confirmation_number),
                      fillColor: isEditing ? Colors.grey[100] : null,
                      filled: isEditing,
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'To pole jest wymagane' : null,
                  ),
                ),
                if (!isEditing) ...[
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _openScanner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),

            Row(
              children: [
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(top: 10, bottom: 10, right: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: _imagePath == null
                        ? const Icon(Icons.camera_alt, color: Colors.green)
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Urodzenie: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      TextButton.icon(
                        onPressed: () => _pickDate(context),
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: const Text('Zmień datę'),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            TextFormField(
              controller: _breedController,
              decoration: const InputDecoration(
                labelText: 'Rasa *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets),
              ),
              validator: (value) => value!.isEmpty ? 'Podaj rasę' : null,
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Masa ciała (kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
              ),
            ),
            const SizedBox(height: 15),

            const Text(
              "Dodatkowe informacje",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: 'Pochodzenie / Hodowla',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Uwagi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: _saveAnimal,
              icon: Icon(isEditing ? Icons.edit : Icons.save),
              label: Text(
                isEditing ? 'ZAPISZ ZMIANY' : 'ZAPISZ ZWIERZĘ',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );

    if (isEditing) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Edycja zwierzęcia"),
          backgroundColor: Colors.green,
        ),
        body: formContent,
      );
    } else {
      return Scaffold(body: formContent);
    }
  }
}
