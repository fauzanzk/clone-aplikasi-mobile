import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final String category; // 'TRANSACTION', 'PROMO', 'INFO'
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  bool isRead;
  final String? deepLink;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.isRead = false,
    this.deepLink,
  });
}
