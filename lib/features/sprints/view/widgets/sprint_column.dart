import 'package:flutter/material.dart';

class SprintColumn {
  final String id;
  final String title;
  final Color color;

  const SprintColumn({
    required this.id,
    required this.title,
    required this.color,
  });
}

const columns = [
  SprintColumn(
      id: 'not_started',
      title: 'NOT STARTED',
      color: Color(0xFF9E9E9E)),
  SprintColumn(
      id: 'wip',
      title: 'WIP',
      color: Color(0xFF1976D2)),
  SprintColumn(
      id: 'internal_testing',
      title: 'INTERNAL TESTING',
      color: Color(0xFFFF9800)),
  SprintColumn(
      id: 'pending_zoho',
      title: 'PENDING ZOHO',
      color: Color(0xFF9C27B0)),
  SprintColumn(
      id: 'pending_client',
      title: 'PENDING CLIENT',
      color: Color(0xFFE91E63)),
  SprintColumn(
      id: 'released_uat',
      title: 'RELEASED FOR UAT',
      color: Color(0xFF00BCD4)),
  SprintColumn(
      id: 'uat_approved',
      title: 'UAT APPROVED',
      color: Color(0xFF4CAF50)),
  SprintColumn(
      id: 'closed',
      title: 'CLOSED',
      color: Color(0xFF4CAF50)),
];
