import 'package:flutter/material.dart';
import '../services/poke_services.dart';

class DetallesPage extends StatelessWidget {
  final String pokemonName;
  const DetallesPage({Key? key, required this.pokemonName}) : super(key: key);

  static const statIcons = {
    'hp': Icons.favorite, // Vida
    'attack': Icons.flash_on, // Ataque
    'defense': Icons.shield, // Defensa
    'special-attack': Icons.bolt, // Ataque especial
    'special-defense': Icons.security, // Defensa especial
    'speed': Icons.directions_run, // Velocidad
  };

  static const statColors = {
    'hp': Colors.red,
    'attack': Colors.orange,
    'defense': Colors.blue,
    'special-attack': Colors.purple,
    'special-defense': Colors.green,
    'speed': Colors.amber,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Pokémon')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: PokemonService.fetchPokemonDetail(pokemonName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                if (data['image'] != null)
                  Image.network(
                    data['image'],
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                const SizedBox(height: 16),
                Text(
                  data['name'].toString().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Estadísticas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...List<Widget>.from(
                  (data['stats'] as List).map((stat) {
                    final statName = stat['name'] as String;
                    final baseStat = stat['base_stat'] as int;
                    final icon = statIcons[statName] ?? Icons.bar_chart;
                    final color = statColors[statName] ?? Colors.blueGrey;
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value:
                                  baseStat /
                                  200, // 200 es un valor máximo de referencia
                              minHeight: 12,
                              backgroundColor: color.withOpacity(0.2),
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            baseStat.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
