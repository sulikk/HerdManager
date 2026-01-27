import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/../models/sale_model.dart';

class SaleDetailsScreen extends StatelessWidget {
  final Sale sale;
  final String? animalImagePath;

  const SaleDetailsScreen({super.key, required this.sale, this.animalImagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sprzedaż: ${sale.earTagNumber}"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[200],
              child:
                  animalImagePath != null && animalImagePath!.isNotEmpty
                      ? Image.file(File(animalImagePath!), fit: BoxFit.cover)
                      : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets, size: 80, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              "Brak zdjęcia",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Informacje o sprzedaży",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const Divider(),

                  _buildDetailRow(
                    Icons.confirmation_number,
                    "Numer kolczyka",
                    sale.earTagNumber,
                  ),
                  _buildDetailRow(
                    Icons.calendar_today,
                    "Data sprzedaży",
                    DateFormat('dd.MM.yyyy').format(sale.saleDate),
                  ),
                  _buildDetailRow(
                    Icons.monitor_weight,
                    "Waga przy sprzedaży",
                    "${sale.weight} kg",
                  ),
                  _buildDetailRow(
                    Icons.attach_money,
                    "Cena sprzedaży",
                    "${sale.price.toStringAsFixed(2)} zł",
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Uwagi:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      sale.notes != null && sale.notes!.isNotEmpty
                          ? sale.notes!
                          : "Brak dodatkowych uwag.",
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
