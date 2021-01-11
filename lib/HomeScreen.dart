import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'country_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'indcicator.dart';

Future<Country> futureCountry;
Future<Country> fetchData() async {
  final response =
      await http.get('https://pomber.github.io/covid19/timeseries.json');

  if (response.statusCode == 200) {
    Map<String, dynamic> map = jsonDecode(response.body);

    List<dynamic> countryData = map['Jordan'];

    List<int> confirmed = [];
    List<num> recovered = [];
    List<int> deaths = [];
    countryData.forEach((element) {
      confirmed.add(element["confirmed"]);
      recovered.add(element["recovered"]);
      deaths.add(element["deaths"]);
    });

    Country country =
        Country(confirmed: confirmed, deaths: deaths, recovered: recovered);

    return country;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    futureCountry = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Covid-19 cases in Jordan'),
          backgroundColor: Colors.indigo,
        ),
        body: PieChartSample2(),
      ),
    );
  }
}

class PieChartSample2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State {
  int touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Country>(
        future: futureCountry,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int confirmedNumber = 0;
            int recoveredNumber = 0;
            int deathsNumber = 0;

            snapshot.data.confirmed.forEach((element) {
              confirmedNumber += element;
            });
            snapshot.data.recovered.forEach((element) {
              recoveredNumber += element;
            });
            snapshot.data.deaths.forEach((element) {
              deathsNumber += element;
            });

            return AspectRatio(
              aspectRatio: 1.3,
              child: Card(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      height: 18,
                    ),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                              pieTouchData: PieTouchData(
                                  touchCallback: (pieTouchResponse) {
                                setState(() {
                                  if (pieTouchResponse.touchInput
                                          is FlLongPressEnd ||
                                      pieTouchResponse.touchInput is FlPanEnd) {
                                    touchedIndex = -1;
                                  } else {
                                    touchedIndex =
                                        pieTouchResponse.touchedSectionIndex;
                                  }
                                });
                              }),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              sections: showingSections(confirmedNumber,
                                  recoveredNumber, deathsNumber)),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Indicator(
                          color: Colors.green[500],
                          text: 'Recovered',
                          isSquare: true,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Indicator(
                          color: Color(0xfff8b250),
                          text: 'Confirmed',
                          isSquare: true,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Indicator(
                          color: Colors.red,
                          text: 'Deaths',
                          isSquare: true,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        SizedBox(
                          height: 18,
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      int confirmedNumber, int recoveredNumber, int deathsNumber) {
    return List.generate(3, (i) {
      double recoveredPercent = (recoveredNumber / confirmedNumber) * 100;
      double deathsPercent = (deathsNumber / confirmedNumber) * 100;
      double confirmedPercent =
          (100 - (recoveredPercent.toInt() + deathsPercent.toInt())).toDouble();

      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 40 : 35;
      final double radius = isTouched ? 80 : 70;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green[500],
            value: recoveredNumber.toDouble(),
            title: recoveredPercent.toInt().toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: confirmedNumber.toDouble(),
            title: confirmedPercent.toInt().toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.red[700],
            value: deathsNumber.toDouble(),
            title: deathsPercent.toInt().toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );

        default:
          return PieChartSectionData();
      }
    });
  }
}
