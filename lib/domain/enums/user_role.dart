import 'package:flutter/material.dart';

import '../../data/enums/enums.dart';

enum UserRole {
  TENANT(
    'Find a place',
    'Tenant / Mess Member',
    'Find a home or mess that matches your needs and budget in seconds.',
    Icons.search,
  ),
  OWNER(
    'Rent out a place',
    'Owner / Mess Manager',
    'List your home or mess, manage applicants, and find reliable tenants.',
    Icons.key,
  );

  const UserRole(this.title, this.subTitle, this.desc, this.icon);

  final String title;
  final String subTitle;
  final String desc;
  final IconData icon;

  Role toData() => switch (this) {
    UserRole.TENANT => Role.TENANT,
    UserRole.OWNER => Role.OWNER,
  };
}
