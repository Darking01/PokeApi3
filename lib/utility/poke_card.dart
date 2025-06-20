import 'package:flutter/material.dart';
import 'image_ui.dart';

class PokemonCard extends StatelessWidget {
  final Map<String, dynamic> pokemon;
  final bool isFavorito;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onDeleteTap;

  const PokemonCard({
    Key? key,
    required this.pokemon,
    this.isFavorito = false,
    this.onTap,
    this.onFavoriteTap,
    this.onDeleteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // Fondo de carta
            Positioned.fill(
              child: Image.asset(
                AppImages.cartaPokemon,
                fit: BoxFit.cover,
              ),
            ),
            // Imagen del Pokémon encima
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (pokemon['image'] != null)
                    Image.network(
                      pokemon['image'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  const SizedBox(height: 12),
                  // Fondo semitransparente para el nombre
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      pokemon['name'].toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: onDeleteTap != null
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDeleteTap,
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: isFavorito ? Colors.red : Colors.grey,
                      ),
                      onPressed: onFavoriteTap,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
