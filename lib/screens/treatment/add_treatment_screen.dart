import 'package:flutter/material.dart';
import 'package:herd_management/services/animal_service.dart';
import 'package:herd_management/services/treatment_service.dart';
import 'package:intl/intl.dart';
import '../../models/treatment_model.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../services/sale_service.dart';

class AddTreatmentScreen extends StatefulWidget {
  final Treatment? treatmentToEdit;

  const AddTreatmentScreen({super.key, this.treatmentToEdit});

  @override
  _AddTreatmentScreenState createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends State<AddTreatmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _typeController = TextEditingController();
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String? _selectedEarTag;
  late Future<List<String>> _earTagsFuture;

  @override
  void dispose() {
    _typeController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _earTagsFuture = _loadEarTags();

    if (widget.treatmentToEdit != null) {
      _selectedEarTag = widget.treatmentToEdit!.earTagNumber;
      _selectedDate = widget.treatmentToEdit!.date;
      _typeController.text = widget.treatmentToEdit!.type;
      _doctorController.text = widget.treatmentToEdit!.doctor ?? ' ';
      _notesController.text = widget.treatmentToEdit!.notes ?? '';
    }
  }

  Future<List<String>> _loadEarTags() async {
    final allAnimals = await AnimalService().getAll();

    final allSales = await SaleService().getAll();

    final soldTags = allSales.map((s) => s.earTagNumber).toSet();

    final availableAnimals = allAnimals.where((a) {
      if (widget.treatmentToEdit != null && a.earTagNumber == widget.treatmentToEdit!.earTagNumber) {
        return true;
      }
      return !soldTags.contains(a.earTagNumber);
    }).map((a) => a.earTagNumber).toList();

    return availableAnimals;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
      locale: const Locale('pl', 'PL'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTreatment() async {
    if (!_formKey.currentState!.validate()) return;

    final treatment = Treatment(
      id: widget.treatmentToEdit?.id,
      earTagNumber: _selectedEarTag!,
      date: _selectedDate,
      type: _typeController.text.trim(),
      doctor: _doctorController.text.isNotEmpty ? _doctorController.text.trim() : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
    );

    try {
      if (widget.treatmentToEdit != null) {
        await TreatmentService().update(treatment);
    } else {
        await TreatmentService().insert(treatment);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.treatmentToEdit != null
              ? 'Zaktualizowano dane leczenia!'
              : 'Dodano nowe leczenie!'),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.treatmentToEdit != null) {
        Navigator.pop(context);
      } else {
        _formKey.currentState!.reset();
        _typeController.clear();
        _doctorController.clear();
        _notesController.clear();
        setState(() {
          _selectedEarTag = null;
          _selectedDate = DateTime.now();
        });
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Błąd zapisu leczenia!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.treatmentToEdit != null;

    Widget formContent = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<List<String>>(
              future: _earTagsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                return DropdownSearch<String>(
                  enabled: !isEditing,
                  items: snapshot.data!,
                  selectedItem: _selectedEarTag,
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        labelText: "Szukaj numeru kolczyka",
                      ),
                    ),
                  ),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Numer kolczyka *",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedEarTag = value;
                    });
                  },
                  validator:
                      (value) => value == null ? "Wybierz zwierzę" : null,
                );
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: "Rodzaj leczenia *",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? "Wymagane" : null,
            ),
            const SizedBox(height: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data leczenia: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
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

            const SizedBox(height: 12),

            TextFormField(
              controller: _doctorController,
              decoration: const InputDecoration(
                labelText: "Lekarz weterynarii",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Uwagi",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _saveTreatment,
              icon: Icon(isEditing ? Icons.edit : Icons.save),
              label: Text(isEditing ? "ZAPISZ ZMIANY" : "ZAPISZ LECZENIE"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );

    if (isEditing) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Edycja leczenia"),
          backgroundColor: Colors.green,
        ),
        body: formContent,
      );
    }
    return Scaffold(body: formContent);
  }
}
