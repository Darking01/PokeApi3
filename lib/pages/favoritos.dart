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

    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 4 : 2;
    final double imageSize = screenWidth / (crossAxisCount * 1.2);

    return GridView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: screenWidth * 0.04,
        mainAxisSpacing: screenWidth * 0.04,
        childAspectRatio: 1,
      ),
      itemCount: favoritos.length,
      itemBuilder: (context, index) {
        final pokemon = favoritos[index];

        return PokemonCard(
          pokemon: pokemon,
          imageSize: imageSize, // <-- Nuevo parámetro para tamaño relativo
          onDeleteTap: () => onRemove(pokemon['name']),
          onTap: onTap != null
              ? () => onTap!(pokemon)
              : () {
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
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.contain,
                            ),
                          SizedBox(height: screenWidth * 0.04),
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
                            Navigator.pop(context);
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
