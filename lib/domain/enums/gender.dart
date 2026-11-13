import 'package:flutter/material.dart';

enum Gender {
  MALE('Male', Icons.male_outlined),
  FEMALE('Female', Icons.female_outlined);

  const Gender(this.label, this.icon);

  final String label;
  final IconData icon;
}
