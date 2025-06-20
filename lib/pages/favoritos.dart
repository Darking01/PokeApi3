import 'package:flutter/material.dart';
import '../utility/poke_card.dart';
import 'detalles.dart';
import '../utility/custom_loader.dart';

class FavoritosScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoritos;
  final Function(String) onRemove;
  final Function(Map<String, dynamic>)? onTap;

  const FavoritosScreen({
    Key? key,
    required this.favoritos,
    required this.onRemove,
    this.onTap,
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
              : () {
                  // Si no se pasa onTap, muestra detalles por defecto
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(pokemon['name'].toString().toUpperCase()),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pokemon['image'] != null)
                            Image.network(
                              pokemon['image'],
                              width: 140,
                              height: 140,
                              fit: BoxFit.contain,
                            ),
                          const SizedBox(height: 16),
                          const Text('¡Un pokémon salvaje ha aparecido!'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Atrás'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context); // Cierra el diálogo
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetallesPage(pokemonName: pokemon['name']),
                              ),
                            );
                          },
                          child: const Text('Ver estadística'),
                        ),
                      ],
                    ),
                  );
                },
        );
      },
    );
  }
}
