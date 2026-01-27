import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/../models/animal_model.dart';

class AnimalDetailsScreen extends StatelessWidget {
  final Animal animal;

  const AnimalDetailsScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Szczegóły: ${animal.earTagNumber}"),
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
                  animal.imagePath != null && animal.imagePath!.isNotEmpty
                      ? Image.file(File(animal.imagePath!), fit: BoxFit.cover)
                      : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets, size: 80, color: Colors.grey),
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
                    "Informacje o zwierzęciu",
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
                    animal.earTagNumber,
                  ),
                  _buildDetailRow(Icons.category, "Rasa", animal.breed),
                  _buildDetailRow(
                    Icons.cake,
                    "Data urodzenia",
                    DateFormat('dd.MM.yyyy').format(animal.birthDate),
                  ),
                  _buildDetailRow(
                    Icons.monitor_weight,
                    "Waga",
                    animal.weight != null
                        ? "${animal.weight} kg"
                        : "Nie podano",
                  ),
                  _buildDetailRow(
                    Icons.location_on,
                    "Pochodzenie",
                    animal.origin ?? "Nie podano",
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Opis / Uwagi:",
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
                      animal.notes != null && animal.notes!.isNotEmpty
                          ? animal.notes!
                          : "Brak dodatkowych opisów.",
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
