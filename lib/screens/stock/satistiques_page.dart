import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:raj_eat/main.dart';

class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({Key? key}) : super(key: key);

  @override
  _StatistiquesPageState createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage> {
  Map<String, int> cartNameStats = {};

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  // Méthode pour récupérer les statistiques des 'cartName' depuis Firestore
  Future<void> fetchStatistics() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('order').get();
    // Collecter les fréquences des 'cartName'
    for (var doc in querySnapshot.docs) {
      String cartName = doc['cartName'];
      for (var prod in cartName.split(",")) {
        cartNameStats
            .addEntries({prod: (cartNameStats[prod] ?? 0) + 1}.entries);
      }
      // Incrémenter le nombre d'occurrences pour chaque 'cartName'
    }

    // Mise à jour de l'état pour refléter les modifications dans l'interface utilisateur
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiques des plats"),
      ),
      body: cartNameStats.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: cartNameStats.values.isNotEmpty
                      ? cartNameStats.values.reduce((a, b) => a > b ? a : b) + 5
                      : 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final cartName =
                              cartNameStats.keys.elementAt(value.toInt());
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space:
                                8.0, // Espacement entre les barres et les titres
                            child: Text(
                              cartName.substring(0, 10) +
                                  "...", // Affiche le nom complet sans troncature
                              style: const TextStyle(
                                color: Colors.black, // Couleur du texte
                                fontWeight: FontWeight.bold, // Mettre en gras
                                fontSize: 10, // Taille du texte
                              ),
                            ),
                          );
                        },
                        reservedSize: 42,
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.black, // Couleur du texte
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 32,
                        interval: 1,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _createBarGroups(),
                ),
              ),
            ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    List<BarChartGroupData> barGroups = [];
    int index = 0;

    cartNameStats.forEach((cartName, count) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: cartNameStats[cartName]!.toDouble(),
              color: Colors.blueAccent, // Utilisation de 'color'
              width: 20,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
      );
      index++;
    });

    return barGroups;
  }
}
