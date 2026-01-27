import 'package:flutter/material.dart';
import '../../models/animal_model.dart';
import 'add_animal_screen.dart';
import 'animal_details_screen.dart';
import '../../services/animal_service.dart';
import '../../widgets/filterable_list_mixin.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});

  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen>
    with FilterableListMixin<Animal> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() async {
    final animals = await AnimalService().getAll();
    setState(() {
      initFilter(animals);
    });
  }

  bool _animalMatches(Animal a, String q) {
    return a.earTagNumber.toLowerCase().contains(q) ||
        a.breed.toLowerCase().contains(q) ||
        (a.notes?.toLowerCase().contains(q) ?? false) ||
        (a.origin?.toLowerCase().contains(q) ?? false) ||
        (a.weight?.toString().contains(q) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Szukaj zwierzęcia...',
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              applySearch(val, _animalMatches);
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
                  case 'breed':
                    sortItems((a, b) => a.breed.compareTo(b.breed));
                    break;
                  case 'weight':
                    sortItems(
                      (a, b) => (a.weight ?? 0).compareTo(b.weight ?? 0),
                    );
                    break;
                  case 'age':
                    sortItems((a, b) => a.birthDate.compareTo(b.birthDate));
                    break;
                  case 'origin':
                    sortItems(
                      (a, b) => (a.origin ?? '').compareTo(b.origin ?? ''),
                    );
                    break;
                  case 'birthDate':
                    sortItems((a, b) => a.birthDate.compareTo(b.birthDate));
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
                  PopupMenuItem(value: 'breed', child: Text('Sortuj po rasie')),
                  PopupMenuItem(
                    value: 'weight',
                    child: Text('Sortuj po wadze'),
                  ),
                  PopupMenuItem(value: 'age', child: Text('Sortuj po wieku')),
                  PopupMenuItem(
                    value: 'origin',
                    child: Text('Sortuj po pochodzeniu'),
                  ),
                  PopupMenuItem(
                    value: 'birthDate',
                    child: Text('Sortuj po dacie urodzenia'),
                  ),
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
                    Icon(Icons.inbox, size: 60, color: Colors.grey),
                    Text(
                      "Brak zapisanych zwierząt.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: filteredItems.length,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  final animal = filteredItems[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.pets, color: Colors.green),
                      ),
                      title: Text(
                        "Nr: ${animal.earTagNumber}",
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
                            Text('Rasa: ${animal.breed}'),
                            Row(
                              children: [
                                const Icon(
                                  Icons.cake,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text('Wiek: ${animal.age}'),
                                const SizedBox(width: 12),
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
                                  builder: (context) =>
                                      AddAnimalScreen(animalToEdit: animal),
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
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Usuwanie"),
                                  content: Text(
                                    "Czy na pewno usunąć zwierzę ${animal.earTagNumber}?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text("Anuluj"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        "Usuń",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await AnimalService().delete(animal.earTagNumber);
                                _refreshList();
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    AnimalDetailsScreen(animal: animal),
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
