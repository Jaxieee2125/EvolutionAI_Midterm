// lib/widgets/classification_result_card.dart
import 'package:evolution_ai/services/food_classification_service.dart';
import 'package:flutter/material.dart';

class ClassificationResultCard extends StatelessWidget {
  final ClassificationResult result;

  const ClassificationResultCard({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  result.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal.shade900,
                  ),
                ),
                Text(
                  '${(result.confidence * 100).toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: result.confidence,
                backgroundColor: Colors.teal.shade100,
                color: Colors.teal,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}