import 'package:flutter/material.dart';
import '../services/food_classification_service.dart';

class ClassificationResultCard extends StatelessWidget {
  final ClassificationResult result;
  const ClassificationResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal:16, vertical:8),
      child: ListTile(
        title: Text(result.label),
        subtitle: LinearProgressIndicator(value: result.score.clamp(0,1)),
        trailing: Text('${(result.score*100).toStringAsFixed(1)}%'),
      ),
    );
  }
}
