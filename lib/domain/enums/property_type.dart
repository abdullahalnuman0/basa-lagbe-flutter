import 'package:flutter/material.dart';

enum PropertyType {
  HOSTEL('Hostel', Icons.hotel_outlined),
  FLAT('Flat', Icons.apartment_outlined),
  MESS('Mess', Icons.groups_outlined),
  SUBLET('Sublet', Icons.home_work_outlined);

  const PropertyType(this.title, this.icon);

  final String title;
  final IconData icon;
}
