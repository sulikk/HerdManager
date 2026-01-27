import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '/../models/sale_model.dart';
import '/../services/sale_service.dart';
import '/../services/animal_service.dart';

class AddSaleScreen extends StatefulWidget {
  final Sale? saleToEdit;

  const AddSaleScreen({super.key, this.saleToEdit});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();



  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String? _selectedEarTag;
  late Future<List<String>> _earTagsFuture;

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _earTagsFuture = _loadEarTags();

    if (widget.saleToEdit != null) {
      _selectedEarTag = widget.saleToEdit!.earTagNumber;
      _selectedDate = widget.saleToEdit!.saleDate;
      _weightController.text = widget.saleToEdit!.weight.toString();
      _priceController.text = widget.saleToEdit!.price.toString();
      _notesController.text = widget.saleToEdit!.notes ?? '';
    }
  }

  Future<List<String>> _loadEarTags() async {
    final allAnimals = await AnimalService().getAll();

    final allSales = await SaleService().getAll();

    final soldTags = allSales.map((s) => s.earTagNumber).toSet();

    final availableAnimals = allAnimals.where((a) {
      if (widget.saleToEdit != null && a.earTagNumber == widget.saleToEdit!.earTagNumber) {
        return true;
      }
      return !soldTags.contains(a.earTagNumber);
    }).map((a) => a.earTagNumber).toList();

    return availableAnimals;
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
      locale: const Locale('pl', 'PL'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) return;

    final sale = Sale(
      id: widget.saleToEdit?.id,
      earTagNumber: _selectedEarTag!,
      saleDate: _selectedDate,
      weight: double.parse(_weightController.text.replaceAll(',', '.')),
      price: double.parse(_priceController.text.replaceAll(',', '.')),
      notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
    );

    try {
      if (widget.saleToEdit != null) {
        await SaleService().update(sale);
      } else {
        await SaleService().insert(sale);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.saleToEdit != null
              ? "Zaktualizowano dane sprzedaży!"
              : "Dodano nową sprzedaż!"),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.saleToEdit != null) {
        Navigator.pop(context);
      } else {
        _formKey.currentState!.reset();
        _weightController.clear();
        _priceController.clear();
        _notesController.clear();
        setState(() {
          _selectedEarTag = null;
          _selectedDate = DateTime.now();
          _earTagsFuture = _loadEarTags();
        });
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Błąd zapisu sprzedaży!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.saleToEdit != null;

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

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data sprzedaży: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
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
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: "Waga przy sprzedaży (kg) *",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? "Wymagane" : null,
            ),

            const SizedBox(height: 12),

            /// ===== CENA =====
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: "Cena sprzedaży (zł) *",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? "Wymagane" : null,
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
              onPressed: _saveSale,
              icon: Icon(isEditing ? Icons.edit : Icons.save),
              label: Text(isEditing ? "ZAPISZ ZMIANY" : "ZAPISZ SPRZEDAŻ"),
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
          title: Text("Edycja sprzedaży"),
          backgroundColor: Colors.green,
        ),
        body: formContent,
      );
    }
    return Scaffold(body: formContent);
  }
}
