import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/sale_model.dart';
import '../../services/sale_service.dart';
import '../../services/animal_service.dart';
import 'add_sale_screen.dart';
import 'sale_details_screen.dart';
import '../../widgets/filterable_list_mixin.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  _SaleListScreenState createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen>
    with FilterableListMixin<Sale> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() async {
    final sales = await SaleService().getAll();
    setState(() {
      initFilter(sales);
    });
  }

  bool _saleMatches(Sale s, String q) {
    q = q.toLowerCase();
    return s.earTagNumber.toLowerCase().contains(q) ||
        (s.notes?.toLowerCase().contains(q) ?? false) ||
        s.price.toString().contains(q) ||
        s.weight.toString().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Szukaj sprzedaży...',
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              applySearch(val, _saleMatches);
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
                  case 'price':
                    sortItems((a, b) => a.price.compareTo(b.price));
                    break;
                  case 'weight':
                    sortItems((a, b) => a.weight.compareTo(b.weight));
                    break;
                  case 'saleDate':
                    sortItems((a, b) => a.saleDate.compareTo(b.saleDate));
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
                  PopupMenuItem(value: 'price', child: Text('Sortuj po cenie')),
                  PopupMenuItem(
                    value: 'weight',
                    child: Text('Sortuj po wadze'),
                  ),
                  PopupMenuItem(
                    value: 'saleDate',
                    child: Text('Sortuj po dacie sprzedaży'),
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
                    Icon(Icons.sell_outlined, size: 60, color: Colors.grey),
                    Text(
                      "Brak zapisanych sprzedaży",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: filteredItems.length,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  final sale = filteredItems[index];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.sell, color: Colors.green),
                      ),
                      title: Text(
                        'Nr: ${sale.earTagNumber}',
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
                            Text('Cena: ${sale.price.toStringAsFixed(2)} zł'),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Data: ${DateFormat('dd.MM.yyyy').format(sale.saleDate)}',
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
                                      (context) =>
                                          AddSaleScreen(saleToEdit: sale),
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
                                        "Czy na pewno usunąć sprzedaż zwierzęcia ${sale.earTagNumber}?",
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
                                await SaleService().delete(sale.id!);
                                _refreshList();
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () async {
                        final animal = await AnimalService().getByEarTag(
                          sale.earTagNumber,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SaleDetailsScreen(
                                  sale: sale,
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
