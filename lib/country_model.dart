import 'package:flutter/material.dart';

class Country {
  final List<int> confirmed;
  final List<num> recovered;
  final List<int> deaths;

  Country({this.confirmed, this.deaths, this.recovered});
}
