import 'package:flutter/material.dart';

enum PropertyGender {
  MALE('Male', Icons.male_outlined),
  FEMALE('Female', Icons.female_outlined),
  ANY('Any', Icons.groups_outlined);

  const PropertyGender(this.title, this.icon);

  final String title;
  final IconData icon;
}
