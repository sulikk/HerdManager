import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/animal_model.dart';
import '../../models/sale_model.dart';
import '../../models/treatment_model.dart';
import '../../services/animal_service.dart';
import '../../services/sale_service.dart';
import '../../services/treatment_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Animal> allAnimals = [];
  List<Sale> allSales = [];
  List<Treatment> allTreatments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final animals = await AnimalService().getAll();
    final sales = await SaleService().getAll();
    final treatments = await TreatmentService().getAll();
    setState(() {
      allAnimals = animals;
      allSales = sales;
      allTreatments = treatments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          allAnimals.isEmpty && allSales.isEmpty && allTreatments.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Średnia cena za kilogram",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    _buildInfoCard(
                      '${_averagePricePerKg().toStringAsFixed(2)} zł/kg',
                      Icons.attach_money,
                      Colors.orange,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Zysk w bieżącym roku (miesięczny)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Card(
                      child: SizedBox(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildIncomeBarChart(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Podział zwierząt po wieku",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Card(
                      child: SizedBox(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildAgePieChart(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Podział zwierząt według rasy",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Card(
                      child: SizedBox(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildBreedPieChart(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Leczenia w czasie (trend miesięczny)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Card(
                      child: SizedBox(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildTreatmentsLineChart(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoCard(String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  double _averagePricePerKg() {
    if (allSales.isEmpty) return 0;
    double totalPrice = 0;
    double totalWeight = 0;
    for (var sale in allSales) {
      final animal = allAnimals.firstWhere(
        (a) => a.earTagNumber == sale.earTagNumber,
        orElse:
            () => Animal(
              earTagNumber: '',
              birthDate: DateTime.now(),
              breed: '',
              weight: 0,
            ),
      );
      if (animal.weight != null && animal.weight! > 0) {
        totalPrice += sale.price;
        totalWeight += sale.weight;
      }
    }
    return totalWeight > 0 ? totalPrice / totalWeight : 0;
  }

  Widget _buildIncomeBarChart() {
    final now = DateTime.now();
    final monthlyIncome = List.generate(12, (i) {
      return allSales
          .where(
            (s) => s.saleDate.year == now.year && s.saleDate.month == i + 1,
          )
          .fold(0.0, (prev, s) => prev + s.price);
    });

    double maxY = monthlyIncome.reduce(
      (curr, next) => curr > next ? curr : next,
    );
    if (maxY == 0) maxY = 100;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(0)} zł',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  '${value ~/ 1000}k',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 1 || index > 12) return const SizedBox.shrink();

                final monthName = DateFormat.MMM(
                  'pl',
                ).format(DateTime(2024, index));
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    monthName,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine:
              (value) =>
                  FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(12, (i) {
          return BarChartGroupData(
            x: i + 1,
            barRods: [
              BarChartRodData(
                toY: monthlyIncome[i],
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 12,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAgePieChart() {
    int small = allAnimals.where((a) => _animalAgeInMonths(a) < 6).length;
    int medium =
        allAnimals
            .where(
              (a) => _animalAgeInMonths(a) >= 6 && _animalAgeInMonths(a) < 18,
            )
            .length;

    int large = allAnimals.where((a) => _animalAgeInMonths(a) >= 18).length;

    const titleStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
    );

    if (allAnimals.isEmpty) return const Center(child: Text("Brak danych"));

    final sections = [
      PieChartSectionData(
        value: small.toDouble(),
        color: Colors.green,
        title: 'Małe\ndo 6 msc\n$small szt.',
        radius: 60,
        titleStyle: titleStyle,
      ),
      PieChartSectionData(
        value: medium.toDouble(),
        color: Colors.orange,
        title: 'Średnie\n6-18 msc\n$medium szt.',
        radius: 60,
        titleStyle: titleStyle,
      ),
      PieChartSectionData(
        value: large.toDouble(),
        color: Colors.red,
        title: 'Duże\n od 18 msc\n$large szt.',
        radius: 60,
        titleStyle: titleStyle,
      ),
    ];

    final activeSections = sections.where((s) => s.value > 0).toList();

    if (activeSections.isEmpty) {
      return const Center(child: Text("Brak danych w przedziałach"));
    }

    return PieChart(
      PieChartData(
        sections: activeSections,
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        borderData: FlBorderData(show: false),
        pieTouchData: PieTouchData(enabled: true),
      ),
    );
  }

  int _animalAgeInMonths(Animal a) {
    return DateTime.now().difference(a.birthDate).inDays ~/ 30;
  }

  Widget _buildBreedPieChart() {
    final Map<String, int> breedCounts = {};
    for (var a in allAnimals) {
      breedCounts[a.breed] = (breedCounts[a.breed] ?? 0) + 1;
    }

    if (breedCounts.isEmpty) return const Center(child: Text("Brak ras"));

    final colors = List.generate(
      breedCounts.length,
      (i) => Colors.primaries[i % Colors.primaries.length],
    );

    final sections =
        breedCounts.entries.map((e) {
          final index = breedCounts.keys.toList().indexOf(e.key);

          return PieChartSectionData(
            value: e.value.toDouble(),
            title: '${e.key}\n${e.value} szt.',
            color: colors[index],
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.black, blurRadius: 2),
              ],
            ),
          );
        }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
        pieTouchData: PieTouchData(enabled: true),
      ),
    );
  }

  Widget _buildTreatmentsLineChart() {
    final now = DateTime.now();
    final monthlyCounts = List.generate(12, (i) {
      return allTreatments
          .where((t) => t.date.year == now.year && t.date.month == i + 1)
          .length
          .toDouble();
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine:
              (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
        ),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0)
                  return Container();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 1 || index > 12) return const SizedBox.shrink();

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    DateFormat.MMM('pl').format(DateTime(2024, index)),
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 1,
        maxX: 12,
        minY: 0,
        maxY: (monthlyCounts.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              monthlyCounts.length,
              (i) => FlSpot(i + 1.0, monthlyCounts[i]),
            ),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter:
                  (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.blue,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.blue.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
