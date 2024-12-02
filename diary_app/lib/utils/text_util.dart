import 'package:flutter/material.dart';

Widget buildDetailSection(String title, String content,
    {double fontSize = 13, double spacing = 10, Color? color}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
          color: color ?? Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        content,
        style: TextStyle(
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: spacing),
    ],
  );
}
