import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/treatment_model.dart';

class TreatmentDetailsScreen extends StatelessWidget {
  final Treatment treatment;
  final String? animalImagePath;

  const TreatmentDetailsScreen({
    Key? key,
    required this.treatment,
    this.animalImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Szczegóły leczenia"),
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
                    "Informacje o leczeniu",
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
                    treatment.earTagNumber,
                  ),
                  _buildDetailRow(
                    Icons.medical_services,
                    "Rodzaj leczenia",
                    treatment.type,
                  ),
                  _buildDetailRow(
                    Icons.calendar_today,
                    "Data leczenia",
                    DateFormat('dd.MM.yyyy').format(treatment.date),
                  ),
                  _buildDetailRow(
                    Icons.person,
                    "Lekarz",
                    treatment.doctor ?? "Nie podano",
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
                      treatment.notes != null && treatment.notes!.isNotEmpty
                          ? treatment.notes!
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
