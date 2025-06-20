import 'package:flutter/material.dart';
import '../utility/poke_card.dart';
import 'detalles.dart';

class FavoritosScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoritos;
  final Function(String) onRemove;
  final Function(Map<String, dynamic>)? onTap; // <-- Añade esto

  const FavoritosScreen({
    Key? key,
    required this.favoritos,
    required this.onRemove,
    this.onTap, // <-- Añade esto
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (favoritos.isEmpty) {
      return const Center(child: Text('No tienes favoritos aún.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: favoritos.length,
      itemBuilder: (context, index) {
        final pokemon = favoritos[index];

        return PokemonCard(
          pokemon: pokemon,
          onDeleteTap: () => onRemove(pokemon['name']),
          onTap: onTap != null
              ? () => onTap!(pokemon)
              : null, // <-- Usa el callback recibido
        );
      },
    );
  }
}
