import 'package:flutter/material.dart';
import 'package:herd_management/screens/treatment/add_treatment_screen.dart';
import 'package:herd_management/services/animal_service.dart';
import 'package:herd_management/services/treatment_service.dart';
import 'package:intl/intl.dart';
import '../../models/treatment_model.dart';
import 'treatment_details_screen.dart';
import '../../widgets/filterable_list_mixin.dart';

class TreatmentListScreen extends StatefulWidget {
  const TreatmentListScreen({super.key});

  @override
  _TreatmentListScreenState createState() => _TreatmentListScreenState();
}

class _TreatmentListScreenState extends State<TreatmentListScreen>
    with FilterableListMixin<Treatment> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() async {
    final treatments = await TreatmentService().getAll();
    setState(() {
      initFilter(treatments);
    });
  }

  bool _treatmentMatches(Treatment t, String q) {
    q = q.toLowerCase();
    return t.earTagNumber.toLowerCase().contains(q) ||
        t.type.toLowerCase().contains(q) ||
        (t.doctor?.toLowerCase().contains(q) ?? false) ||
        (t.notes?.toLowerCase().contains(q) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Szukaj leczenia...',
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              applySearch(val, _treatmentMatches);
            });
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'earTag':
                    sortItems(
                      (a, b) => a.earTagNumber.compareTo(b.earTagNumber),
                    );
                    break;
                  case 'type':
                    sortItems((a, b) => a.type.compareTo(b.type));
                    break;
                  case 'doctor':
                    sortItems(
                      (a, b) => (a.doctor ?? '').compareTo(b.doctor ?? ''),
                    );
                    break;
                  case 'date':
                    sortItems((a, b) => a.date.compareTo(b.date));
                    break;
                  case 'notes':
                    sortItems(
                      (a, b) => (a.notes ?? '').compareTo(b.notes ?? ''),
                    );
                    break;
                }
              });
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(
                    value: 'earTag',
                    child: Text('Sortuj po numerze kolczyka'),
                  ),
                  PopupMenuItem(
                    value: 'type',
                    child: Text('Sortuj po rodzaju leczenia'),
                  ),
                  PopupMenuItem(
                    value: 'doctor',
                    child: Text('Sortuj po lekarzu'),
                  ),
                  PopupMenuItem(value: 'date', child: Text('Sortuj po dacie')),
                  PopupMenuItem(
                    value: 'notes',
                    child: Text('Sortuj po uwagach'),
                  ),
                ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),

      body:
          filteredItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 60,
                      color: Colors.grey,
                    ),
                    Text(
                      "Brak zapisanych leczeń",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: filteredItems.length,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  final treatment = filteredItems[index];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(
                          Icons.medical_services,
                          color: Colors.green,
                        ),
                      ),
                      title: Text(
                        'Nr: ${treatment.earTagNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rodzaj leczenia: ${treatment.type}'),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Data: ${DateFormat('dd.MM.yyyy').format(treatment.date)}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: -10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AddTreatmentScreen(
                                        treatmentToEdit: treatment,
                                      ),
                                ),
                              ).then((_) => _refreshList());
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade300,
                            ),
                            onPressed: () async {
                              bool? confirm = await showDialog(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: const Text("Usuwanie"),
                                      content: Text(
                                        "Czy na pewno usunąć leczenie ${treatment.type} dla zwierzęcia ${treatment.earTagNumber}?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, false),
                                          child: const Text("Anuluj"),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, true),
                                          child: const Text(
                                            "Usuń",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirm == true) {
                                await TreatmentService().delete(treatment.id!);
                                _refreshList();
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () async {
                        final animal = await AnimalService().getByEarTag(
                          treatment.earTagNumber,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TreatmentDetailsScreen(
                                  treatment: treatment,
                                  animalImagePath: animal?.imagePath,
                                ),
                          ),
                        ).then((_) => _refreshList());
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshList,
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
