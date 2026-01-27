import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:herd_management/screens/dashboard/statistics_screen.dart';
import 'package:herd_management/screens/sale/add_sale_screen.dart';
import 'package:herd_management/screens/sale/sale_list_screen.dart';
import 'package:herd_management/screens/settings/settings_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/animal/animal_list_screen.dart';
import 'screens/animal/add_animal_screen.dart';
import 'screens/treatment/treatment_list_screen.dart';
import 'screens/treatment/add_treatment_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(HerdManagementApp());
}

class HerdManagementApp extends StatelessWidget {
  const HerdManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ewidencja bydła',
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pl', 'PL'),
      ],

      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: false,
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: MainTabs(),
    );
  }
}

class MainTabs extends StatefulWidget {
  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    "Lista zwierząt",
    "Lista leczeń",
    "Lista sprzedaży",
    "Dodaj nowe zwierzę",
    "Dodaj nowe leczenie",
    "Dodaj nową sprzedaż",
    "Statystyki stada",
    "Ustawienia"
  ];

  final List<Widget> _pages = [
    AnimalListScreen(),
    TreatmentListScreen(),
    SaleListScreen(),
    AddAnimalScreen(),
    AddTreatmentScreen(),
    AddSaleScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        elevation: 2,
      ),
      body: _pages[_selectedIndex],

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Lista zwierząt'),
              selected: _selectedIndex == 0,
              onTap: () => _onSelectItem(0),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Lista leczeń'),
              selected: _selectedIndex == 1,
              onTap: () => _onSelectItem(1),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Lista sprzedaży'),
              selected: _selectedIndex == 2,
              onTap: () => _onSelectItem(2),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Dodaj zwierzę'),
              selected: _selectedIndex == 3,
              onTap: () => _onSelectItem(3),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Dodaj leczenie'),
              selected: _selectedIndex == 4,
              onTap: () => _onSelectItem(4),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Dodaj sprzedaż'),
              selected: _selectedIndex == 5,
              onTap: () => _onSelectItem(5),
            ),
            ListTile(
              leading: const Icon(Icons.query_stats),
              title: const Text('Statystyki'),
              selected: _selectedIndex == 6,
              onTap: () => _onSelectItem(6),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ustawienia'),
              selected: _selectedIndex == 7,
              onTap: () => _onSelectItem(7),
            ),
          ],
        ),
      ),
    );
  }
}
