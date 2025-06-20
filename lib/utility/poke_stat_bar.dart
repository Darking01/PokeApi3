import 'package:flutter/material.dart';

class PokeStatBar extends StatelessWidget {
  final String statName;
  final int baseStat;
  final IconData icon;
  final Color color;

  const PokeStatBar({
    Key? key,
    required this.statName,
    required this.baseStat,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              statName.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: baseStat / 200,
              minHeight: 12,
              backgroundColor: color.withOpacity(0.2),
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            baseStat.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
